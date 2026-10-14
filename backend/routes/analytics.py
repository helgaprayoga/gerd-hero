from flask import Blueprint

analytics_bp = Blueprint("analytics", __name__)

@analytics_bp.get("/analytics")
def get_analytics():
    pass  # TODO: hitung E1-E5, panggil AI ringkasan (E3)