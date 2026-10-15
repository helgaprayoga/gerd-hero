"""Small helpers shared by Flask route modules."""

from __future__ import annotations

from datetime import date
from typing import Any

from flask import jsonify, request


def json_error(message: str, status: int = 400, error: str = "Bad Request"):
    return jsonify({"success": False, "error": error, "message": message}), status


def request_body() -> dict[str, Any] | None:
    body = request.get_json(silent=True)
    return body if isinstance(body, dict) else None


def response_data(response: Any) -> Any:
    return getattr(response, "data", None)


def first_row(response: Any) -> dict[str, Any] | None:
    data = response_data(response)
    if isinstance(data, list):
        return data[0] if data else None
    return data if isinstance(data, dict) else None


def response_error(response: Any) -> str | None:
    error = getattr(response, "error", None)
    if not error:
        return None
    return str(getattr(error, "message", error))


def parse_iso_date(value: Any, field: str = "date") -> date:
    if not isinstance(value, str):
        raise ValueError(f"{field} harus berformat YYYY-MM-DD")
    try:
        return date.fromisoformat(value)
    except ValueError as error:
        raise ValueError(f"{field} harus berformat YYYY-MM-DD") from error


def parse_optional_float(value: Any, field: str) -> float | None:
    if value is None or value == "":
        return None
    try:
        number = float(value)
    except (TypeError, ValueError) as error:
        raise ValueError(f"{field} harus berupa angka") from error
    return number
