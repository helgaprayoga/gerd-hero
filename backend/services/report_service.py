"""PDF report generation for clinical review (feature F2)."""

from __future__ import annotations

import json
from io import BytesIO
from typing import Any
from xml.sax.saxutils import escape

def _text(value: Any) -> str:
    if value is None or value == "":
        return "-"
    if isinstance(value, (dict, list)):
        value = json.dumps(value, ensure_ascii=False, default=str)
    return escape(str(value))


def _section(
    title: str,
    value: Any,
    paragraph,
    spacer,
    centimeter,
    section_style,
    body_style,
) -> list[Any]:
    return [
        paragraph(escape(title), section_style),
        paragraph(_text(value), body_style),
        spacer(1, 0.2 * centimeter),
    ]


def generate_pdf(
    user: dict[str, Any],
    logs: list[dict[str, Any]],
    gerdq: dict[str, Any] | None,
    period: dict[str, Any],
) -> bytes:
    """Generate an A4 PDF and return its bytes without writing local files."""
    try:
        from reportlab.lib import colors
        from reportlab.lib.enums import TA_CENTER
        from reportlab.lib.pagesizes import A4
        from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
        from reportlab.lib.units import cm
        from reportlab.platypus import (
            Paragraph,
            SimpleDocTemplate,
            Spacer,
            Table,
            TableStyle,
        )
    except ImportError as error:
        raise RuntimeError(
            "reportlab belum terpasang. Jalankan: pip install -r requirements.txt"
        ) from error

    output = BytesIO()
    styles = getSampleStyleSheet()
    title_style = ParagraphStyle(
        "ReportTitle", parent=styles["Title"], alignment=TA_CENTER, spaceAfter=14
    )
    section_style = ParagraphStyle(
        "ReportSection", parent=styles["Heading2"], textColor=colors.HexColor("#176B87")
    )
    body_style = styles["BodyText"]

    document = SimpleDocTemplate(
        output,
        pagesize=A4,
        rightMargin=1.6 * cm,
        leftMargin=1.6 * cm,
        topMargin=1.5 * cm,
        bottomMargin=1.5 * cm,
    )
    story: list[Any] = [
        Paragraph("GERDHero — Laporan Pemantauan", title_style),
        Paragraph(
            f"Periode: {_text(period.get('start') or period.get('period_start'))} "
            f"s/d {_text(period.get('end') or period.get('period_end'))}",
            styles["Normal"],
        ),
        Spacer(1, 0.35 * cm),
    ]
    section_args = (Paragraph, Spacer, cm, section_style, body_style)
    story.extend(_section("A. Identitas Pengguna", user, *section_args))
    story.extend(_section("B. Ringkasan Pemantauan", {"jumlah_log": len(logs), "periode": period}, *section_args))
    story.extend(_section("C. Riwayat Gejala", [log.get("symptoms", []) for log in logs], *section_args))
    story.extend(_section("D. Skor GERD-Q", gerdq or {}, *section_args))
    story.extend(_section("E. Pemicu yang Dilaporkan", [log.get("triggers", {}) for log in logs], *section_args))
    story.extend(_section("F. Pola Hidup", user.get("profile", {}), *section_args))

    rows = [["Tanggal", "Level GERD", "Stres", "Durasi tidur (menit)"]]
    for log in logs:
        rows.append([
            _text(log.get("log_date")),
            _text(log.get("gerd_level")),
            _text(log.get("stress_level")),
            _text(log.get("sleep_duration_minutes")),
        ])
    table = Table(rows, repeatRows=1, colWidths=[4 * cm, 3.2 * cm, 3 * cm, 4.2 * cm])
    table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#176B87")),
        ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
        ("GRID", (0, 0), (-1, -1), 0.4, colors.grey),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("FONTSIZE", (0, 0), (-1, -1), 8),
    ]))
    story.extend([Paragraph("G. Riwayat & Kebiasaan Harian", section_style), table, Spacer(1, 0.2 * cm)])
    story.extend(_section("H. Obat & Suplemen", [log.get("medications", []) for log in logs], *section_args))

    document.build(story)
    return output.getvalue()
