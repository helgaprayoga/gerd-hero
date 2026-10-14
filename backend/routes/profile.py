from __future__ import annotations

from flask import Blueprint, g, jsonify

from connection.supabase import get_table
from middleware.auth import require_auth
from routes.helpers import first_row, json_error, request_body, response_error


profile_bp = Blueprint("profile", __name__)


def _profile_payload(user: dict, extended: dict | None) -> dict:
    return {**user, "extended": extended or {}}


def _get_profile_rows():
    user_response = (
        get_table(g.supabase, "users")
        .select("*")
        .eq("id", g.user_id)
        .limit(1)
        .execute()
    )
    extended_response = (
        get_table(g.supabase, "user_profiles_extended")
        .select("*")
        .eq("user_id", g.user_id)
        .limit(1)
        .execute()
    )
    return first_row(user_response), first_row(extended_response)


@profile_bp.get("/profile")
@require_auth
def get_profile():
    try:
        user, extended = _get_profile_rows()
    except Exception as error:
        return json_error(str(error), 502, "Database Error")
    if user is None:
        return json_error("Profil pengguna belum tersedia.", 404, "Not Found")
    return jsonify({"success": True, "data": _profile_payload(user, extended)})


@profile_bp.put("/profile")
@require_auth
def update_profile():
    body = request_body()
    if body is None:
        return json_error("Body request harus berupa JSON object.")

    try:
        current_user, _ = _get_profile_rows()
        if current_user is None:
            return json_error("Profil pengguna belum tersedia.", 404, "Not Found")
        height_input = body.get("height", current_user.get("height"))
        weight_input = body.get("weight", current_user.get("weight"))
        height = height_input
        weight = weight_input
        height = float(height) if height is not None else None
        weight = float(weight) if weight is not None else None
        if height is not None and height <= 0:
            raise ValueError("height harus lebih besar dari 0")
        if weight is not None and weight <= 0:
            raise ValueError("weight harus lebih besar dari 0")
        bmi = round(weight / ((height / 100) ** 2), 1) if height and weight else None
    except (TypeError, ValueError) as error:
        return json_error(str(error))

    gender = body.get("gender")
    if gender is not None and gender not in {"male", "female", "other"}:
        return json_error("gender harus male, female, atau other.")

    user_fields = ("email", "name", "nickname", "birth_date", "gender", "height", "weight")
    user_update = {key: body[key] for key in user_fields if key in body}
    if height is not None:
        user_update["height"] = height
    if weight is not None:
        user_update["weight"] = weight
        if "height" in body or "weight" in body:
            user_update["bmi"] = bmi

    extended_input = body.get("extended", {})
    if not isinstance(extended_input, dict):
        return json_error("extended harus berupa JSON object.")
    extended_fields = (
        "smoking", "alcohol", "work_pattern", "coffee",
        "medical_history", "routine_meds",
    )
    extended_update = {
        key: extended_input[key] for key in extended_fields if key in extended_input
    }
    # Accept flat extended fields as well for simpler mobile clients.
    extended_update.update({
        key: body[key] for key in extended_fields if key in body
    })

    try:
        if user_update:
            response = (
                get_table(g.supabase, "users")
                .update(user_update)
                .eq("id", g.user_id)
                .execute()
            )
            if response_error(response):
                return json_error(response_error(response), 400, "Database Error")
        if extended_update:
            extended_update["user_id"] = g.user_id
            response = get_table(g.supabase, "user_profiles_extended").upsert(
                extended_update, on_conflict="user_id"
            ).execute()
            if response_error(response):
                return json_error(response_error(response), 400, "Database Error")
        user, extended = _get_profile_rows()
    except Exception as error:
        return json_error(str(error), 502, "Database Error")

    return jsonify({"success": True, "data": _profile_payload(user or {}, extended)})
