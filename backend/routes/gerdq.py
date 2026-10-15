from __future__ import annotations

from flask import Blueprint, g, jsonify

from connection.supabase import get_table
from middleware.auth import require_auth
from routes.helpers import first_row, json_error, request_body, response_error
from services.proses_gerdq import hitung_skor_gerdq


gerdq_bp = Blueprint("gerdq", __name__)


@gerdq_bp.post("/gerdq")
@require_auth
def submit_gerdq():
    body = request_body()
    if body is None or not isinstance(body.get("answers"), list):
        return json_error("answers harus berupa array berisi 6 angka.")
    answers = body["answers"]
    if len(answers) != 6 or any(type(value) is not int or value not in range(4) for value in answers):
        return json_error("answers harus berisi tepat 6 angka dengan nilai 0 sampai 3.")

    score, evaluation = hitung_skor_gerdq(answers)
    db_result = "likely_gerd" if score >= 8 else "no_gerd"
    payload = {
        "user_id": g.user_id,
        "score": score,
        "answers": answers,
        "result": db_result,
    }
    try:
        response = get_table(g.supabase, "gerdq_scores").insert(payload).execute()
        error = response_error(response)
        if error:
            return json_error(error, 400, "Database Error")
        row = first_row(response) or payload
    except Exception as error:
        return json_error(str(error), 502, "Database Error")

    return jsonify({
        "success": True,
        "data": {**row, "evaluation": evaluation},
    }), 201


@gerdq_bp.get("/gerdq/latest")
@require_auth
def get_latest_gerdq():
    try:
        response = (
            get_table(g.supabase, "gerdq_scores")
            .select("*")
            .eq("user_id", g.user_id)
            .order("created_at", desc=True)
            .limit(1)
            .execute()
        )
        row = first_row(response)
    except Exception as error:
        return json_error(str(error), 502, "Database Error")
    if row is None:
        return json_error("Belum ada hasil GERD-Q.", 404, "Not Found")
    score = row.get("score", 0)
    evaluation = (
        "Kemungkinan menderita GERD"
        if isinstance(score, (int, float)) and score >= 8
        else "Kemungkinan tidak menderita GERD"
    )
    return jsonify({"success": True, "data": {**row, "evaluation": evaluation}})
