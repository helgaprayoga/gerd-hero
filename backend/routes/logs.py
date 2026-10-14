from __future__ import annotations

from datetime import date as date_type, datetime, timedelta
from typing import Any

from flask import Blueprint, g, jsonify, request

from connection.supabase import get_table
from middleware.auth import require_auth
from routes.helpers import first_row, json_error, request_body, response_error
from services.ai_service import generate_daily_analysis
from services.proses_gejala import gejala_dict, hitung_skor_gerd
from services.proses_harian import proses_indikator_harian


logs_bp = Blueprint("logs", __name__)


def _minutes(value: str) -> int:
    return datetime.strptime(value, "%H:%M").hour * 60 + datetime.strptime(value, "%H:%M").minute


def _sleep_duration(sleep_time: str | None, wake_time: str | None) -> int | None:
    if not sleep_time or not wake_time:
        return None
    duration = _minutes(wake_time) - _minutes(sleep_time)
    return duration if duration > 0 else duration + 24 * 60


def _validate_log(body: dict[str, Any]):
    log_date = date_type.fromisoformat(body["log_date"])
    if log_date > date_type.today():
        raise ValueError("log_date tidak boleh di masa depan.")

    symptoms = body.get("symptoms", [])
    if not isinstance(symptoms, list) or any(not isinstance(item, str) for item in symptoms):
        raise ValueError("symptoms harus berupa array string.")
    no_symptoms = body.get("no_symptoms", False)
    if type(no_symptoms) is not bool:
        raise ValueError("no_symptoms harus berupa boolean.")
    if no_symptoms:
        symptoms = []

    triggers = body.get("triggers")
    meal_times = body.get("meal_times")
    meal_frequency = body.get("meal_frequency")
    sleep_time = body.get("sleep_time")
    wake_time = body.get("wake_time")
    if not isinstance(triggers, dict):
        raise ValueError("triggers wajib berupa object.")
    if not isinstance(meal_times, list) or not meal_times:
        raise ValueError("meal_times wajib berupa array yang tidak kosong.")
    if type(meal_frequency) is not int or meal_frequency <= 0:
        raise ValueError("meal_frequency harus berupa integer lebih besar dari 0.")
    if meal_frequency != len(meal_times):
        raise ValueError("meal_frequency harus sama dengan jumlah meal_times.")
    if not isinstance(sleep_time, str) or not isinstance(wake_time, str):
        raise ValueError("sleep_time dan wake_time wajib berformat HH:MM.")

    # Reuse the strict D5 validation for the five trigger flags.
    indicators_input = {
        "frekuensi_makan": meal_frequency,
        "jam_makan": meal_times,
        "jam_tidur": sleep_time,
        "pemicu": triggers,
    }
    stress_level = body.get("stress_level")
    if stress_level is not None and (type(stress_level) is not int or stress_level not in range(1, 6)):
        raise ValueError("stress_level harus bernilai 1 sampai 5.")

    medications = body.get("medications", [])
    took_medication = body.get("took_medication", False)
    if not isinstance(medications, list) or type(took_medication) is not bool:
        raise ValueError("medications harus array dan took_medication harus boolean.")
    if not took_medication:
        medications = []

    sleep_duration = body.get("sleep_duration_minutes")
    if sleep_duration is None:
        sleep_duration = _sleep_duration(sleep_time, wake_time)
    if type(sleep_duration) is not int or sleep_duration < 0:
        raise ValueError("sleep_duration_minutes harus integer >= 0.")

    return {
        "log_date": log_date,
        "symptoms": symptoms,
        "no_symptoms": no_symptoms,
        "triggers": triggers,
        "meal_frequency": meal_frequency,
        "meal_times": meal_times,
        "sleep_time": sleep_time,
        "wake_time": wake_time,
        "sleep_duration_minutes": sleep_duration,
        "stress_level": stress_level,
        "medications": medications,
        "took_medication": took_medication,
        "symptom_description": body.get("symptom_description"),
        "indicators_input": indicators_input,
    }


def _previous_day(client, user_id: str, log_date: date_type) -> dict[str, Any] | None:
    response = (
        get_table(client, "daily_logs")
        .select("meal_frequency, meal_times")
        .eq("user_id", user_id)
        .eq("log_date", (log_date - timedelta(days=1)).isoformat())
        .limit(1)
        .execute()
    )
    row = first_row(response)
    if not row:
        return None
    return {
        "frekuensi_makan": row.get("meal_frequency"),
        "jam_makan": row.get("meal_times") or [],
    }


def _update_streak(client, user_id: str, log_date: date_type, current_user: dict | None):
    user = current_user or {}
    previous_date = user.get("last_log_date")
    try:
        previous_date = date.fromisoformat(previous_date) if previous_date else None
    except ValueError:
        previous_date = None
    current_streak = int(user.get("streak_days") or 0)
    if previous_date == log_date:
        streak = max(current_streak, 1)
    elif previous_date == log_date - timedelta(days=1):
        streak = current_streak + 1
    else:
        streak = 1
    client_table = get_table(client, "users")
    client_table.update({"streak_days": streak, "last_log_date": log_date.isoformat()}).eq(
        "id", user_id
    ).execute()
    return streak


@logs_bp.post("/logs")
@require_auth
def create_log():
    body = request_body()
    if body is None:
        return json_error("Body request harus berupa JSON object.")
    try:
        validated = _validate_log(body)
        previous = _previous_day(g.supabase, g.user_id, validated["log_date"])
        indicators = proses_indikator_harian(validated["indicators_input"], previous)
        symptom_inputs = {name: 1 if name in validated["symptoms"] else 0 for name in gejala_dict}
        gerd_level = round(hitung_skor_gerd(symptom_inputs, gejala_dict), 4)
        ai_input = {
            "symptoms": validated["symptoms"],
            "triggers": validated["triggers"],
            "meal_frequency": validated["meal_frequency"],
            "meal_times": validated["meal_times"],
            "stress_level": validated["stress_level"],
            "sleep_time": validated["sleep_time"],
            "wake_time": validated["wake_time"],
            "sleep_duration_minutes": validated["sleep_duration_minutes"],
            "indicators": indicators,
        }
        ai_analysis = generate_daily_analysis(ai_input)
        payload = {
            "user_id": g.user_id,
            "log_date": validated["log_date"].isoformat(),
            "symptoms": validated["symptoms"],
            "no_symptoms": validated["no_symptoms"],
            "symptom_description": validated["symptom_description"],
            "triggers": validated["triggers"],
            "meal_frequency": validated["meal_frequency"],
            "meal_times": validated["meal_times"],
            "meal_time_consistent": indicators["konsistensi_jam_makan"]["nilai"],
            "meal_frequency_consistent": indicators["konsistensi_frekuensi_makan"]["nilai"],
            "last_meal_to_sleep_gap_hours": indicators["jeda_makan_tidur"]["jam"],
            "stress_level": validated["stress_level"],
            "sleep_time": validated["sleep_time"],
            "wake_time": validated["wake_time"],
            "sleep_duration_minutes": validated["sleep_duration_minutes"],
            "medications": validated["medications"],
            "took_medication": validated["took_medication"],
            "gerd_level": gerd_level,
            "ai_analysis": {"indicators": indicators, **ai_analysis},
        }
        response = get_table(g.supabase, "daily_logs").upsert(
            payload, on_conflict="user_id,log_date"
        ).execute()
        error = response_error(response)
        if error:
            return json_error(error, 400, "Database Error")
        row = first_row(response) or payload
        user_response = get_table(g.supabase, "users").select(
            "streak_days,last_log_date"
        ).eq("id", g.user_id).limit(1).execute()
        streak = _update_streak(g.supabase, g.user_id, validated["log_date"], first_row(user_response))
    except (KeyError, TypeError, ValueError) as error:
        return json_error(str(error))
    except Exception as error:
        return json_error(str(error), 502, "Database or AI Error")

    return jsonify({"success": True, "data": {**row, "streak_days": streak}}), 201


@logs_bp.get("/logs")
@require_auth
def get_logs_by_week():
    week = request.args.get("week")
    if not week:
        return json_error("Query parameter week wajib diisi dengan format YYYY-Www.")
    try:
        year_text, week_text = week.split("-W")
        start = date.fromisocalendar(int(year_text), int(week_text), 1)
        end = start + timedelta(days=6)
    except (ValueError, IndexError):
        return json_error("week harus berformat YYYY-Www.")
    try:
        response = (
            get_table(g.supabase, "daily_logs")
            .select("*")
            .eq("user_id", g.user_id)
            .gte("log_date", start.isoformat())
            .lte("log_date", end.isoformat())
            .order("log_date", desc=False)
            .execute()
        )
        return jsonify({"success": True, "data": response.data or [], "period": {
            "start": start.isoformat(), "end": end.isoformat(), "week": week
        }})
    except Exception as error:
        return json_error(str(error), 502, "Database Error")


@logs_bp.get("/logs/<string:date>")
@require_auth
def get_log_by_date(date: str):
    try:
        parsed_date = date_type.fromisoformat(date)
    except ValueError:
        return json_error("date harus berformat YYYY-MM-DD.")
    try:
        response = (
            get_table(g.supabase, "daily_logs")
            .select("*")
            .eq("user_id", g.user_id)
            .eq("log_date", parsed_date.isoformat())
            .limit(1)
            .execute()
        )
        row = first_row(response)
    except Exception as error:
        return json_error(str(error), 502, "Database Error")
    if row is None:
        return json_error("Log pada tanggal tersebut tidak ditemukan.", 404, "Not Found")
    return jsonify({"success": True, "data": row})
