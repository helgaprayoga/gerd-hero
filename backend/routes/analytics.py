from __future__ import annotations

from datetime import date, datetime, timedelta, timezone

from flask import Blueprint, current_app, g, jsonify, request

from connection.supabase import get_table
from middleware.auth import require_auth
from routes.helpers import first_row, json_error
from services.ai_service import generate_period_analysis
from services.analytics_service import (
    get_complication_attention,
    get_gerd_trend,
    get_influencing_factors,
    get_period_statistics,
    get_top_triggers,
)


analytics_bp = Blueprint("analytics", __name__)
_CACHE_TTL = timedelta(hours=1)


def _period() -> tuple[str, date, date]:
    period_type = request.args.get("period", "weekly")
    anchor_text = request.args.get("date", date.today().isoformat())
    anchor = date.fromisoformat(anchor_text)
    if period_type == "weekly":
        start = anchor - timedelta(days=anchor.weekday())
        return period_type, start, start + timedelta(days=6)
    if period_type == "monthly":
        start = anchor.replace(day=1)
        if start.month == 12:
            next_month = start.replace(year=start.year + 1, month=1)
        else:
            next_month = start.replace(month=start.month + 1)
        return period_type, start, next_month - timedelta(days=1)
    if period_type == "custom":
        start = date.fromisoformat(request.args["start"])
        end = date.fromisoformat(request.args["end"])
        if start > end:
            raise ValueError("start tidak boleh setelah end.")
        return period_type, start, end
    raise ValueError("period harus weekly, monthly, atau custom.")


def _period_payload(period_type: str, start: date, end: date) -> dict[str, str]:
    return {
        "type": period_type,
        "start": start.isoformat(),
        "end": end.isoformat(),
    }


def _cache_query(period_type: str, start: date, end: date):
    return (
        get_table(g.supabase, "analytics_cache")
        .select("*")
        .eq("user_id", g.user_id)
        .eq("period_type", period_type)
        .eq("period_start", start.isoformat())
        .eq("period_end", end.isoformat())
        .gt("expires_at", datetime.now(timezone.utc).isoformat())
        .limit(1)
        .execute()
    )


def _cached_result(row: dict, period: dict[str, str]) -> dict | None:
    cache_data = row.get("cache_data")
    required_sections = {
        "trend",
        "top_triggers",
        "influencing_factors",
        "complication_attention",
        "ai_analysis",
    }
    if not isinstance(cache_data, dict) or not required_sections.issubset(cache_data):
        return None
    result = {**cache_data, "period": period, "cached": True}
    result.setdefault("summary", result["ai_analysis"].get("summary_points", []))
    result.setdefault("recommendations", result["ai_analysis"].get("recommendations", []))
    return result


def _build_result(
    *,
    period: dict[str, str],
    logs: list[dict],
    user_context: dict,
) -> dict:
    deterministic = {
        "trend": get_gerd_trend(logs),
        "top_triggers": get_top_triggers(logs),
        "influencing_factors": get_influencing_factors(logs),
        "complication_attention": get_complication_attention(logs),
        **get_period_statistics(logs),
    }
    ai_context = {
        "period": period,
        **deterministic,
        "profile": {
            "nickname": user_context.get("nickname"),
            "bmi": user_context.get("bmi"),
            "smoking": user_context.get("smoking"),
            "alcohol": user_context.get("alcohol"),
            "coffee": user_context.get("coffee"),
        },
    }
    ai_analysis = generate_period_analysis(ai_context)
    return {
        **deterministic,
        "period": period,
        "ai_analysis": ai_analysis,
        # Compatibility fields for older clients.
        "summary": ai_analysis["summary_points"],
        "recommendations": ai_analysis["recommendations"],
        "log_count": len(logs),
        "cached": False,
    }


def _save_cache(result: dict, period_type: str, start: date, end: date) -> None:
    ai_analysis = result.get("ai_analysis") or {}
    cache_data = {key: value for key, value in result.items() if key not in {"cached", "period"}}
    payload = {
        "user_id": g.user_id,
        "period_type": period_type,
        "period_start": start.isoformat(),
        "period_end": end.isoformat(),
        "cache_data": cache_data,
        "ai_summary": "\n".join(ai_analysis.get("summary_points") or []),
        "ai_recommendations": ai_analysis.get("recommendations") or [],
        "expires_at": (datetime.now(timezone.utc) + _CACHE_TTL).isoformat(),
    }
    get_table(g.supabase, "analytics_cache").upsert(
        payload,
        on_conflict="user_id,period_type,period_start,period_end",
    ).execute()


@analytics_bp.get("/analytics")
@require_auth
def get_analytics():
    try:
        period_type, period_start, period_end = _period()
        period = _period_payload(period_type, period_start, period_end)

        # Cache is keyed by the complete period and invalidated by the daily
        # log trigger. This avoids an AI request every time the page opens.
        try:
            cache_response = _cache_query(period_type, period_start, period_end)
            cached = _cached_result(first_row(cache_response) or {}, period)
            if cached is not None:
                return jsonify({"success": True, "data": cached})
        except Exception as cache_error:
            current_app.logger.warning("Analytics cache tidak terbaca: %s", cache_error)

        logs_response = (
            get_table(g.supabase, "daily_logs")
            .select("*")
            .eq("user_id", g.user_id)
            .gte("log_date", period_start.isoformat())
            .lte("log_date", period_end.isoformat())
            .order("log_date", desc=False)
            .execute()
        )
        logs = [row for row in (logs_response.data or []) if isinstance(row, dict)]
        user_response = (
            get_table(g.supabase, "users")
            .select("*")
            .eq("id", g.user_id)
            .limit(1)
            .execute()
        )
        user = first_row(user_response) or {}
        extended_response = (
            get_table(g.supabase, "user_profiles_extended")
            .select("*")
            .eq("user_id", g.user_id)
            .limit(1)
            .execute()
        )
        extended = first_row(extended_response) or {}
        result = _build_result(
            period=period,
            logs=logs,
            user_context={**user, **extended},
        )

        try:
            _save_cache(result, period_type, period_start, period_end)
        except Exception as cache_error:
            # Analytics must remain available if cache permissions/schema are
            # temporarily unavailable.
            current_app.logger.warning("Analytics cache tidak tersimpan: %s", cache_error)
    except (KeyError, TypeError, ValueError) as error:
        return json_error(str(error))
    except Exception as error:
        return json_error(str(error), 502, "Database or AI Error")

    return jsonify({"success": True, "data": result})
