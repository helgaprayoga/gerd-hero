from __future__ import annotations

from typing import Any

from flask import Blueprint, jsonify, request

from connection.supabase import supabase
from routes.helpers import json_error, request_body


auth_bp = Blueprint("auth", __name__)


def _user_data(user: Any) -> dict[str, Any] | None:
    if user is None:
        return None
    return {
        "id": getattr(user, "id", None),
        "email": getattr(user, "email", None),
        "created_at": getattr(user, "created_at", None),
    }


def _session_data(session: Any) -> dict[str, Any] | None:
    if session is None:
        return None
    return {
        "access_token": getattr(session, "access_token", None),
        "refresh_token": getattr(session, "refresh_token", None),
        "token_type": getattr(session, "token_type", "bearer"),
        "expires_in": getattr(session, "expires_in", None),
        "expires_at": getattr(session, "expires_at", None),
    }


def _auth_response(response: Any) -> dict[str, Any]:
    return {
        "user": _user_data(getattr(response, "user", None)),
        "session": _session_data(getattr(response, "session", None)),
    }


@auth_bp.post("/register")
def register():
    body = request_body()
    if body is None:
        return json_error("Body request harus berupa JSON object.")

    email = body.get("email")
    password = body.get("password")
    if not isinstance(email, str) or "@" not in email:
        return json_error("email tidak valid.")
    if not isinstance(password, str) or len(password) < 6:
        return json_error("password minimal 6 karakter.")

    options = {
        "data": {
            key: body[key]
            for key in ("name", "nickname")
            if body.get(key) is not None
        }
    }
    try:
        response = supabase.auth.sign_up({
            "email": email.strip().lower(),
            "password": password,
            "options": options,
        })
    except Exception as error:
        return json_error(str(error), 400, "Registration Failed")

    return jsonify({"success": True, "data": _auth_response(response)}), 201


@auth_bp.post("/login")
def login():
    body = request_body()
    if body is None:
        return json_error("Body request harus berupa JSON object.")

    email = body.get("email")
    password = body.get("password")
    if not isinstance(email, str) or not isinstance(password, str):
        return json_error("email dan password wajib diisi.")

    try:
        response = supabase.auth.sign_in_with_password({
            "email": email.strip().lower(),
            "password": password,
        })
    except Exception:
        return json_error("Email atau password salah.", 401, "Authentication Failed")

    return jsonify({"success": True, "data": _auth_response(response)})
