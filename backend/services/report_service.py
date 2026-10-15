"""Generate the A-H clinical monitoring report without calling AI."""

from __future__ import annotations

from collections import Counter
from datetime import date, datetime
from io import BytesIO
from typing import Any
from xml.sax.saxutils import escape


def _text(value: Any, fallback: str = "-") -> str:
    if value is None or value == "":
        return fallback
    if isinstance(value, bool):
        return "Ya" if value else "Tidak"
    return str(value)


def _date_text(value: Any) -> str:
    if not value:
        return "-"
    try:
        parsed = date.fromisoformat(str(value)[:10])
        return parsed.strftime("%d %b %Y")
    except (TypeError, ValueError):
        return _text(value)


def _percent(value: Any) -> str:
    if value is None:
        return "-"
    try:
        return f"{float(value) * 100:.0f}%"
    except (TypeError, ValueError):
        return "-"


def _paragraph(value: Any, paragraph, style) -> Any:
    return paragraph(escape(_text(value)).replace("\n", "<br/>"), style)


def _rows(logs: list[dict[str, Any]], key: str) -> Counter[str]:
    values: Counter[str] = Counter()
    for log in logs:
        raw = log.get(key)
        if isinstance(raw, list):
            values.update(str(item) for item in raw if item)
        elif isinstance(raw, dict):
            values.update(str(name) for name, active in raw.items() if active in (True, 1, "1"))
    return values


def _cell(value: Any, paragraph, style) -> Any:
    return _paragraph(value, paragraph, style)


def generate_pdf(
    user: dict[str, Any],
    logs: list[dict[str, Any]],
    gerdq: dict[str, Any] | None,
    period: dict[str, Any],
) -> bytes:
    """Build the same A-H PDF used by preview and export."""
    try:
        from reportlab.lib import colors
        from reportlab.lib.enums import TA_CENTER, TA_LEFT
        from reportlab.lib.pagesizes import A4
        from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
        from reportlab.lib.units import cm
        from reportlab.platypus import (
            PageBreak,
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
    teal = colors.HexColor("#20A99D")
    dark = colors.HexColor("#17202A")
    light = colors.HexColor("#F4F7F8")
    border = colors.HexColor("#D9E2E5")
    title = ParagraphStyle("ReportTitle", parent=styles["Title"], fontSize=15, leading=19, textColor=dark, alignment=TA_LEFT, spaceAfter=8)
    section = ParagraphStyle("ReportSection", parent=styles["Heading2"], fontSize=9, leading=11, textColor=dark, spaceBefore=8, spaceAfter=5)
    body = ParagraphStyle("ReportBody", parent=styles["BodyText"], fontSize=8, leading=10, textColor=dark)
    small = ParagraphStyle("ReportSmall", parent=body, fontSize=7, leading=8)
    muted = ParagraphStyle("ReportMuted", parent=small, textColor=colors.HexColor("#69777D"))
    header = ParagraphStyle("TableHeader", parent=small, fontName="Helvetica-Bold", alignment=TA_CENTER)

    def section_title(name: str) -> list[Any]:
        return [Paragraph(escape(name), section), Table([[""]], colWidths=[17.5 * cm], rowHeights=[0.06 * cm], style=TableStyle([("BACKGROUND", (0, 0), (-1, -1), teal)])), Spacer(1, 0.12 * cm)]

    def card(rows: list[list[Any]], widths: list[float] | None = None) -> Table:
        table = Table(rows, colWidths=widths, repeatRows=1 if len(rows) > 1 else 0, hAlign="LEFT")
        table.setStyle(TableStyle([
            ("BACKGROUND", (0, 0), (-1, -1), light),
            ("BOX", (0, 0), (-1, -1), 0.5, border),
            ("INNERGRID", (0, 0), (-1, -1), 0.35, border),
            ("VALIGN", (0, 0), (-1, -1), "TOP"),
            ("LEFTPADDING", (0, 0), (-1, -1), 7),
            ("RIGHTPADDING", (0, 0), (-1, -1), 7),
            ("TOPPADDING", (0, 0), (-1, -1), 6),
            ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
        ]))
        return table

    profile = user.get("profile") or {}
    start = period.get("start") or period.get("period_start")
    end = period.get("end") or period.get("period_end")
    total_days = (date.fromisoformat(str(end)) - date.fromisoformat(str(start))).days + 1
    symptomatic = [log for log in logs if log.get("symptoms") or float(log.get("gerd_level") or 0) > 0]
    levels = [float(log["gerd_level"]) for log in logs if log.get("gerd_level") is not None]
    symptoms = _rows(logs, "symptoms")
    triggers = _rows(logs, "triggers")

    story: list[Any] = [
        Paragraph("GERDHero — LAPORAN PEMANTAUAN", title),
        Paragraph(f"Periode: {_date_text(start)} s/d {_date_text(end)}", body),
        Spacer(1, 0.25 * cm),
    ]

    story.extend(section_title("A. IDENTITAS PENGGUNA"))
    story.append(card([
        [_cell("Nama Lengkap", Paragraph, muted), _cell("Tanggal Lahir / Usia", Paragraph, muted)],
        [_cell(user.get("name") or user.get("nickname"), Paragraph, body), _cell(_date_text(user.get("birth_date")), Paragraph, body)],
        [_cell("Jenis Kelamin", Paragraph, muted), _cell("Tinggi / Berat Badan", Paragraph, muted)],
        [_cell(user.get("gender"), Paragraph, body), _cell(f"{_text(user.get('height'))} cm / {_text(user.get('weight'))} kg", Paragraph, body)],
        [_cell("Indeks Massa Tubuh (BMI)", Paragraph, muted), _cell(user.get("bmi"), Paragraph, body)],
    ], [8.75 * cm, 8.75 * cm]))

    story.extend(section_title("B. RINGKASAN PEMANTAUAN"))
    average = sum(levels) / len(levels) if levels else None
    story.append(card([
        [_cell("Hari tercatat", Paragraph, muted), _cell("Hari bergejala", Paragraph, muted), _cell("Rata-rata level GERD", Paragraph, muted), _cell("Arah tren", Paragraph, muted)],
        [_cell(f"{len(logs)} / {total_days}", Paragraph, body), _cell(len(symptomatic), Paragraph, body), _cell(_percent(average), Paragraph, body), _cell("Belum tersedia", Paragraph, body)],
    ], [4.35 * cm] * 4))

    story.extend(section_title("C. RIWAYAT GEJALA"))
    symptom_rows = [[_cell("Gejala", Paragraph, header), _cell("Jumlah Hari", Paragraph, header), _cell("Terakhir", Paragraph, header)]]
    for name, count in symptoms.most_common():
        last = next((log.get("log_date") for log in reversed(logs) if name in (log.get("symptoms") or [])), None)
        symptom_rows.append([_cell(name, Paragraph, small), _cell(f"{count} dari {len(logs)} hari", Paragraph, small), _cell(_date_text(last), Paragraph, small)])
    story.append(card(symptom_rows or [[_cell("Belum ada gejala", Paragraph, small)]], [7 * cm, 5 * cm, 5.5 * cm]))

    story.extend(section_title("D. SKOR GERD-Q"))
    story.append(card([[
        _cell("Tanggal", Paragraph, header), _cell("Skor Total", Paragraph, header), _cell("Kesan Pemantauan", Paragraph, header),
    ], [
        _cell(_date_text(gerdq.get("created_at") if gerdq else None), Paragraph, small),
        _cell(f"{_text(gerdq.get('score') if gerdq else None)} / 18", Paragraph, small),
        _cell("Kemungkinan GERD" if gerdq and gerdq.get("result") == "likely_gerd" else "Kemungkinan tidak GERD" if gerdq else "Belum tersedia", Paragraph, small),
    ]], [4.2 * cm, 3.5 * cm, 9.8 * cm]))

    story.extend([PageBreak(), Paragraph("GERDHero — LAPORAN PEMANTAUAN (LANJUTAN)", title)])
    story.extend(section_title("E. PEMICU YANG DILAPORKAN"))
    trigger_rows = [[_cell("Faktor Pemicu", Paragraph, header), _cell("Frekuensi Terpapar", Paragraph, header)]]
    for name, count in triggers.most_common():
        trigger_rows.append([_cell(name, Paragraph, small), _cell(f"{count} hari dari {len(logs)} hari", Paragraph, small)])
    story.append(card(trigger_rows, [10 * cm, 7.5 * cm]))

    story.extend(section_title("F. POLA HIDUP"))
    story.append(card([
        [_cell("Konsistensi Frekuensi Makan", Paragraph, muted), _cell("Konsistensi Jam Makan", Paragraph, muted)],
        [_cell(_text(next((log.get("meal_frequency_consistent") for log in logs if log.get("meal_frequency_consistent") is not None), None)), Paragraph, body), _cell(_text(next((log.get("meal_time_consistent") for log in logs if log.get("meal_time_consistent") is not None), None)), Paragraph, body)],
        [_cell("Jeda Makan-Tidur", Paragraph, muted), _cell("Rata-rata Durasi Tidur", Paragraph, muted)],
        [_cell(_text(next((log.get("last_meal_to_sleep_gap_hours") for log in logs if log.get("last_meal_to_sleep_gap_hours") is not None), None)), Paragraph, body), _cell(_text(round(sum(log.get("sleep_duration_minutes", 0) or 0 for log in logs) / len(logs)) if logs else None) + " menit", Paragraph, body)],
        [_cell("Rata-rata Tingkat Stres", Paragraph, muted), _cell("Catatan", Paragraph, muted)],
        [_cell(round(sum(log.get("stress_level", 0) or 0 for log in logs) / len(logs), 1) if logs else None, Paragraph, body), _cell("Ringkasan berdasarkan log tersimpan.", Paragraph, body)],
    ], [8.75 * cm, 8.75 * cm]))

    story.extend(section_title("G. RIWAYAT & KEBIASAAN HARIAN"))
    story.append(card([
        [_cell("Tanggal", Paragraph, header), _cell("Level GERD", Paragraph, header), _cell("Stres", Paragraph, header), _cell("Durasi Tidur", Paragraph, header)],
        *[[_cell(_date_text(log.get("log_date")), Paragraph, small), _cell(_percent(log.get("gerd_level")), Paragraph, small), _cell(log.get("stress_level"), Paragraph, small), _cell(f"{_text(log.get('sleep_duration_minutes'))} menit", Paragraph, small)] for log in logs],
    ], [4.2 * cm, 4 * cm, 3.5 * cm, 5.8 * cm]))

    story.extend(section_title("H. OBAT & SUPLEMEN YANG DIKONSUMSI"))
    medicine_rows = [[_cell("Tanggal", Paragraph, header), _cell("Jenis Obat", Paragraph, header), _cell("Status", Paragraph, header)]]
    for log in logs:
        medicine_rows.append([_cell(_date_text(log.get("log_date")), Paragraph, small), _cell(", ".join(str(item) for item in (log.get("medications") or [])) or "-", Paragraph, small), _cell("Digunakan" if log.get("took_medication") else "Tidak digunakan", Paragraph, small)])
    story.append(card(medicine_rows, [4.2 * cm, 9 * cm, 4.3 * cm]))
    story.extend([Spacer(1, 0.25 * cm), Paragraph("Laporan ini merupakan ringkasan pemantauan mandiri dan bukan diagnosis medis.", muted)])

    def footer(canvas, document):
        canvas.saveState()
        canvas.setStrokeColor(border)
        canvas.line(1.6 * cm, 1.1 * cm, 19.4 * cm, 1.1 * cm)
        canvas.setFont("Helvetica", 7)
        canvas.setFillColor(colors.HexColor("#69777D"))
        canvas.drawString(1.6 * cm, 0.75 * cm, "GERDHero • SALINAN PASIEN")
        canvas.drawRightString(19.4 * cm, 0.75 * cm, f"Halaman {canvas.getPageNumber()} dari 2")
        canvas.restoreState()

    document = SimpleDocTemplate(output, pagesize=A4, rightMargin=1.6 * cm, leftMargin=1.6 * cm, topMargin=1.4 * cm, bottomMargin=1.6 * cm)
    document.build(story, onFirstPage=footer, onLaterPages=footer)
    return output.getvalue()
