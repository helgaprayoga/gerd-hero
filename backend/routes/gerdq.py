from flask import Blueprint

gerdq_bp = Blueprint("gerdq", __name__)

@gerdq_bp.post("/gerdq")
def submit_gerdq():
    pass  # TODO: hitung skor (services/proses_gerdq.py), simpan ke DB

@gerdq_bp.get("/gerdq/latest")
def get_latest_gerdq():
    pass  # TODO: ambil baris terbaru dari gerdhero.gerdq_scores