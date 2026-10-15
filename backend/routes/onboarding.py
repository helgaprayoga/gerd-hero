from __future__ import annotations

from flask import Blueprint, g, jsonify

from connection.supabase import get_table
from middleware.auth import require_auth
from routes.helpers import first_row, json_error, request_body, response_error


onboarding_bp = Blueprint("onboarding", __name__)
_VALID_STATUSES = {"pending", "completed", "skipped"}


def _next_step(profile_status: str, gerdq_status: str) -> str:
    if profile_status == "pending":
        return "profile"
    if gerdq_status == "pending":
        return "gerdq"
    return "home"


def _status_payload(row: dict) -> dict:
    profile_status = row.get("profile_onboarding_status", "pending")
    gerdq_status = row.get("gerdq_onboarding_status", "pending")
    completed = profile_status != "pending" and gerdq_status != "pending"
    return {
        "profile_status": profile_status,
        "gerdq_status": gerdq_status,
        "onboarding_completed": completed,
        "onboarding_completed_at": row.get("onboarding_completed_at"),
        "next_step": _next_step(profile_status, gerdq_status),
    }


def _update_status(field: str):
    body = request_body()
    if body is None or body.get("status") not in _VALID_STATUSES:
        return json_error("status harus pending, completed, atau skipped.")

    status = body["status"]
    try:
        current_response = (
            get_table(g.supabase, "users")
            .select("profile_onboarding_status,gerdq_onboarding_status")
            .eq("id", g.user_id)
            .limit(1)
            .execute()
        )
        current = first_row(current_response)
        if current is None:
            return json_error("Profil pengguna belum tersedia.", 404, "Not Found")

        update = {field: status}
        other_field = (
            "gerdq_onboarding_status"
            if field == "profile_onboarding_status"
            else "profile_onboarding_status"
        )
        if status != "pending" and current.get(other_field) != "pending":
            from datetime import datetime, timezone

            update["onboarding_completed_at"] = datetime.now(timezone.utc).isoformat()
        elif status == "pending":
            update["onboarding_completed_at"] = None

        response = (
            get_table(g.supabase, "users")
            .update(update)
            .eq("id", g.user_id)
            .execute()
        )
        error = response_error(response)
        if error:
            return json_error(error, 400, "Database Error")

        updated_response = (
            get_table(g.supabase, "users")
            .select(
                "profile_onboarding_status,gerdq_onboarding_status,"
                "onboarding_completed_at"
            )
            .eq("id", g.user_id)
            .limit(1)
            .execute()
        )
        updated = first_row(updated_response)
        if updated is None:
            return json_error("Status onboarding tidak ditemukan.", 404, "Not Found")
        return jsonify({"success": True, "data": _status_payload(updated)})
    except Exception as error:
        return json_error(str(error), 502, "Database Error")


@onboarding_bp.get("/onboarding/status")
@require_auth
def get_onboarding_status():
    try:
        response = (
            get_table(g.supabase, "users")
            .select(
                "profile_onboarding_status,gerdq_onboarding_status,"
                "onboarding_completed_at"
            )
            .eq("id", g.user_id)
            .limit(1)
            .execute()
        )
        row = first_row(response)
    except Exception as error:
        return json_error(str(error), 502, "Database Error")
    if row is None:
        return json_error("Profil pengguna belum tersedia.", 404, "Not Found")
    return jsonify({"success": True, "data": _status_payload(row)})


@onboarding_bp.put("/onboarding/profile")
@require_auth
def update_profile_onboarding():
    return _update_status("profile_onboarding_status")


@onboarding_bp.put("/onboarding/gerdq")
@require_auth
def update_gerdq_onboarding():
    return _update_status("gerdq_onboarding_status")
