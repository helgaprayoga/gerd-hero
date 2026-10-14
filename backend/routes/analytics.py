from __future__ import annotations

from datetime import date, timedelta

from flask import Blueprint, current_app, g, jsonify, request

from connection.supabase import get_table
from middleware.auth import require_auth
from routes.helpers import first_row, json_error
from services.ai_service import generate_analytics_summary, generate_habit_recommendations
from services.analytics_service import (
    get_gerd_trend,
    get_habit_recommendation_context,
    get_influencing_factors,
    get_top_triggers,
)


analytics_bp = Blueprint("analytics", __name__)


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


@analytics_bp.get("/analytics")
@require_auth
def get_analytics():
    try:
        period_type, period_start, period_end = _period()
        logs_response = (
            get_table(g.supabase, "daily_logs")
            .select("*")
            .eq("user_id", g.user_id)
            .gte("log_date", period_start.isoformat())
            .lte("log_date", period_end.isoformat())
            .order("log_date", desc=False)
            .execute()
        )
        logs = logs_response.data or []
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
        user_context = {**user, **extended}

        deterministic = {
            "trend": get_gerd_trend(logs),
            "top_triggers": get_top_triggers(logs),
            "influencing_factors": get_influencing_factors(logs),
        }
        context = get_habit_recommendation_context(logs, user_context)
        summary_input = {**deterministic, "period": {
            "type": period_type,
            "start": period_start.isoformat(),
            "end": period_end.isoformat(),
        }}
        summary = generate_analytics_summary(summary_input)
        recommendations = generate_habit_recommendations(context)
        result = {
            **deterministic,
            "summary": summary,
            "recommendations": recommendations,
            "period": summary_input["period"],
            "log_count": len(logs),
        }

        # Cache failure should not make analytics unavailable.
        try:
            get_table(g.supabase, "analytics_cache").upsert({
                "user_id": g.user_id,
                "period_type": period_type,
                "period_start": period_start.isoformat(),
                "period_end": period_end.isoformat(),
                "cache_data": deterministic,
                "ai_summary": summary,
                "ai_recommendations": recommendations,
            }, on_conflict="user_id,period_type,period_start,period_end").execute()
        except Exception as cache_error:
            current_app.logger.warning("Analytics cache tidak tersimpan: %s", cache_error)
    except (KeyError, TypeError, ValueError) as error:
        return json_error(str(error))
    except Exception as error:
        return json_error(str(error), 502, "Database or AI Error")

    return jsonify({"success": True, "data": result})
