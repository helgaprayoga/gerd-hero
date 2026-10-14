from flask import Blueprint

report_bp = Blueprint("report", __name__)

@report_bp.post("/generate")
def generate_report():
    pass  # TODO: generate PDF (reportlab), simpan ke gerdhero.reports

@report_bp.get("/<string:report_id>/download")
def download_report(report_id: str):
    pass  # TODO: serve PDF file / redirect ke storage URL