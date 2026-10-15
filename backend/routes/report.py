from __future__ import annotations

from datetime import date, timedelta, datetime, timezone
from io import BytesIO
from uuid import uuid4

from flask import Blueprint, g, jsonify, request, send_file

from connection.supabase import get_storage_admin_client, get_table
from middleware.auth import require_auth
from routes.helpers import first_row, json_error, request_body, response_error
from services.report_service import generate_pdf
from services.time_service import application_today


report_bp = Blueprint("report", __name__)


def _report_data(user: dict, logs: list[dict], gerdq: dict | None, start: date, end: date) -> dict:
    total_days = (end - start).days + 1
    symptomatic_logs = [
        log for log in logs
        if log.get("symptoms") or float(log.get("gerd_level") or 0) > 0
    ]
    levels = [float(log["gerd_level"]) for log in logs if log.get("gerd_level") is not None]
    return {
        "period": {
            "start": start.isoformat(),
            "end": end.isoformat(),
            "days": total_days,
        },
        "profile": {
            "name": user.get("name"),
            "nickname": user.get("nickname"),
            "email": user.get("email"),
            "birth_date": user.get("birth_date"),
            "gender": user.get("gender"),
            "height": user.get("height"),
            "weight": user.get("weight"),
            "bmi": user.get("bmi"),
            "extended": user.get("profile") or {},
        },
        "summary": {
            "logged_days": len(logs),
            "missing_days": max(total_days - len(logs), 0),
            "symptomatic_days": len(symptomatic_logs),
            "average_gerd_level": round(sum(levels) / len(levels), 4) if levels else None,
            "maximum_gerd_level": max(levels) if levels else None,
        },
        "gerdq": gerdq,
        "daily_history": logs,
    }


def _report_period(body: dict | None) -> tuple[date, date]:
    body = body or {}
    start_value = body.get("period_start", body.get("start_date"))
    end_value = body.get("period_end", body.get("end_date"))
    end = date.fromisoformat(end_value) if end_value else application_today()
    start = date.fromisoformat(start_value) if start_value else end - timedelta(days=6)
    if end > application_today():
        raise ValueError("period_end tidak boleh di masa depan.")
    if start > end:
        raise ValueError("period_start tidak boleh setelah period_end.")
    if (end - start).days + 1 > 90:
        raise ValueError("Periode laporan maksimal 90 hari.")
    return start, end


def _load_report_data(start: date, end: date):
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
    user["profile"] = first_row(extended_response) or {}
    logs_response = (
        get_table(g.supabase, "daily_logs")
        .select("*")
        .eq("user_id", g.user_id)
        .gte("log_date", start.isoformat())
        .lte("log_date", end.isoformat())
        .order("log_date", desc=False)
        .execute()
    )
    gerdq_response = (
        get_table(g.supabase, "gerdq_scores")
        .select("*")
        .eq("user_id", g.user_id)
        .order("created_at", desc=True)
        .limit(1)
        .execute()
    )
    return user, logs_response.data or [], first_row(gerdq_response)


@report_bp.post("/preview")
@require_auth
def preview_report():
    body = request_body()
    if body is not None and not isinstance(body, dict):
        return json_error("Body request harus berupa JSON object.")
    try:
        start, end = _report_period(body)
        user, logs, gerdq = _load_report_data(start, end)
        if not user:
            return json_error("Profil pengguna belum tersedia.", 404, "Not Found")
        return jsonify({
            "success": True,
            "data": _report_data(user, logs, gerdq, start, end),
        })
    except (TypeError, ValueError) as error:
        return json_error(str(error))
    except Exception as error:
        return json_error(str(error), 502, "Database Error")


@report_bp.post("/preview-pdf")
@require_auth
def preview_pdf_report():
    body = request_body()
    if body is not None and not isinstance(body, dict):
        return json_error("Body request harus berupa JSON object.")
    try:
        start, end = _report_period(body)
        user, logs, gerdq = _load_report_data(start, end)
        if not user:
            return json_error("Profil pengguna belum tersedia.", 404, "Not Found")
        pdf_bytes = generate_pdf(
            user,
            logs,
            gerdq,
            {"start": start.isoformat(), "end": end.isoformat()},
        )
        return send_file(
            BytesIO(pdf_bytes),
            mimetype="application/pdf",
            as_attachment=False,
            download_name="GERDHero_preview.pdf",
        )
    except (TypeError, ValueError) as error:
        return json_error(str(error))
    except Exception as error:
        return json_error(str(error), 502, "Report Preview Failed")


@report_bp.post("/generate")
@require_auth
def generate_report():
    body = request_body()
    if body is not None and not isinstance(body, dict):
        return json_error("Body request harus berupa JSON object.")
    try:
        start, end = _report_period(body)
        user, logs, gerdq = _load_report_data(start, end)
        if not user:
            return json_error("Profil pengguna belum tersedia.", 404, "Not Found")
        pdf_bytes = generate_pdf(
            user,
            logs,
            gerdq,
            {"start": start.isoformat(), "end": end.isoformat()},
        )
        report_number = f"GERD-{application_today():%Y%m%d}-{uuid4().hex[:8].upper()}"
        storage_path = f"{g.user_id}/{report_number}.pdf"
        # The `reports` bucket must exist in Supabase Storage.
        get_storage_admin_client().storage.from_("reports").upload(
            storage_path,
            pdf_bytes,
            {"content-type": "application/pdf", "upsert": "true"},
        )
        report_data = _report_data(user, logs, gerdq, start, end)
        response = get_table(g.supabase, "reports").insert({
            "user_id": g.user_id,
            "report_number": report_number,
            "period_start": start.isoformat(),
            "period_end": end.isoformat(),
            "report_data": report_data,
            "pdf_url": storage_path,
            "pdf_generated_at": datetime.now(timezone.utc).isoformat(),
        }).execute()
        error = response_error(response)
        if error:
            return json_error(error, 400, "Database Error")
        row = first_row(response) or {
            "report_number": report_number,
            "pdf_url": storage_path,
        }
    except (TypeError, ValueError) as error:
        return json_error(str(error))
    except Exception as error:
        return json_error(
            f"Gagal membuat laporan: {error}. Pastikan bucket Storage 'reports' sudah dibuat.",
            502,
            "Report Generation Failed",
        )

    return jsonify({
        "success": True,
        "data": {
            "report_id": row.get("id"),
            "report_number": row.get("report_number", report_number),
            "period_start": row.get("period_start", start.isoformat()),
            "period_end": row.get("period_end", end.isoformat()),
            "download_url": f"/api/report/{row.get('id')}/download" if row.get("id") else None,
        },
    }), 201


@report_bp.get("/<string:report_id>/download")
@require_auth
def download_report(report_id: str):
    try:
        response = (
            get_table(g.supabase, "reports")
            .select("id,report_number,pdf_url")
            .eq("id", report_id)
            .eq("user_id", g.user_id)
            .limit(1)
            .execute()
        )
        row = first_row(response)
        if row is None:
            return json_error("Laporan tidak ditemukan.", 404, "Not Found")
        if not row.get("pdf_url"):
            return json_error("File PDF belum tersedia.", 404, "Not Found")
        pdf_bytes = get_storage_admin_client().storage.from_("reports").download(row["pdf_url"])
    except Exception as error:
        return json_error(str(error), 502, "Download Failed")

    filename = f"{row.get('report_number', report_id)}.pdf"
    return send_file(
        BytesIO(pdf_bytes),
        mimetype="application/pdf",
        as_attachment=True,
        download_name=filename,
    )
