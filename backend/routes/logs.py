from flask import Blueprint

logs_bp = Blueprint("logs", __name__)

@logs_bp.post("/logs")
def create_log():
    pass  # TODO: hitung D1-D5, panggil AI (D6/D7), simpan ke DB

@logs_bp.get("/logs")
def get_logs_by_week():
    pass  # TODO: filter ?week=YYYY-Www dari gerdhero.daily_logs

@logs_bp.get("/logs/<string:date>")
def get_log_by_date(date: str):
    pass  # TODO: ambil satu baris berdasarkan log_date