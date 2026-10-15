"""Gemini-backed analysis with a deterministic fallback.

The service deliberately keeps statistics and thresholds outside the model.
Gemini is used only to explain already collected data in user-friendly text.
"""

from __future__ import annotations

import json
import logging
from pathlib import Path
from typing import Any

from connection.api import generate_text


_FALLBACK_PATH = Path(__file__).resolve().parent.parent / "templates" / "ai_fallback.json"
_LOGGER = logging.getLogger(__name__)


def _load_fallback() -> dict[str, Any]:
    """Load the fallback response from the versioned JSON template."""
    with _FALLBACK_PATH.open("r", encoding="utf-8") as fallback_file:
        return json.load(fallback_file)


def _parse_json_response(response: str) -> dict[str, Any]:
    """Parse JSON returned by Gemini, including fenced JSON responses."""
    content = response.strip()
    if content.startswith("```"):
        lines = content.splitlines()
        if lines and lines[0].startswith("```"):
            lines = lines[1:]
        if lines and lines[-1].strip() == "```":
            lines = lines[:-1]
        content = "\n".join(lines).strip()

    parsed = json.loads(content)
    if not isinstance(parsed, dict):
        raise ValueError("Respons AI harus berupa object JSON")
    return parsed


def _fallback_daily_result(log_data: dict[str, Any] | None = None) -> dict[str, Any]:
    """Return a useful deterministic result when Gemini is unavailable."""
    fallback = _load_fallback()
    log_data = log_data or {}
    triggers = log_data.get("triggers")
    active_triggers = (
        [name for name, value in triggers.items() if value in (1, True)]
        if isinstance(triggers, dict)
        else []
    )
    if active_triggers:
        trigger_analysis = [
            {
                "pemicu": name,
                "penjelasan_korelasi": (
                    f"{name} tercatat pada hari yang sama dengan gejala. "
                    "Hal ini berpotensi berkaitan, tetapi bukan diagnosis."
                ),
            }
            for name in active_triggers
        ]
        summary = (
            "Pemicu aktif dan gejala tercatat pada log yang sama. "
            "Korelasi ini bersifat pemantauan mandiri, bukan diagnosis."
        )
    else:
        trigger_analysis = fallback["analisis_pemicu_gejala"]
        summary = fallback["ringkasan_analisis"]
    return {
        "analisis_pemicu_gejala": trigger_analysis,
        "ringkasan_analisis": summary,
        "rekomendasi": fallback["rekomendasi"],
        "analysis_source": "fallback",
    }


def _normalise_daily_result(result: dict[str, Any]) -> dict[str, Any]:
    """Ensure the public daily-analysis contract is always complete."""
    fallback = _load_fallback()
    trigger_analysis = result.get("analisis_pemicu_gejala")
    if not isinstance(trigger_analysis, list) or not trigger_analysis:
        trigger_analysis = fallback["analisis_pemicu_gejala"]
    summary = result.get("ringkasan_analisis")
    if not isinstance(summary, str) or not summary.strip():
        summary = fallback["ringkasan_analisis"]
    recommendations = result.get("rekomendasi")
    if not isinstance(recommendations, list):
        recommendations = fallback["rekomendasi"]
    return {
        "analisis_pemicu_gejala": trigger_analysis,
        "ringkasan_analisis": summary,
        "rekomendasi": recommendations,
        "analysis_source": result.get("analysis_source", "gemini"),
    }


def generate_daily_analysis(log_data: dict[str, Any]) -> dict[str, Any]:
    """Generate D6 analysis and return D7 fallback when Gemini is unavailable."""
    prompt = (
        "Analisis data log GERD berikut secara hati-hati. Gunakan bahasa Indonesia. "
        "Jangan mendiagnosis dan gunakan frasa 'berpotensi berkaitan'. "
        "Kembalikan JSON object tanpa markdown dengan keys: "
        "analisis_pemicu_gejala (array object pemicu dan penjelasan_korelasi), "
        "ringkasan_analisis (string), rekomendasi (array string).\n\n"
        f"DATA_LOG:\n{json.dumps(log_data, ensure_ascii=False, default=str)}"
    )

    try:
        parsed = _parse_json_response(generate_text(prompt))
        if not isinstance(parsed.get("analisis_pemicu_gejala"), list) or not parsed[
            "analisis_pemicu_gejala"
        ]:
            return _fallback_daily_result(log_data)
        result = _normalise_daily_result(parsed)
        result["analysis_source"] = "gemini"
        return result
    except Exception:
        _LOGGER.exception("Analisis AI harian gagal; menggunakan fallback template")
        return _fallback_daily_result(log_data)


def generate_analytics_summary(period_data: dict[str, Any]) -> str:
    """Generate E3 period summary, or return the safe fallback summary."""
    fallback_summary = _load_fallback()["ringkasan_analisis"]
    prompt = (
        "Buat ringkasan analitik GERD dalam bahasa Indonesia berdasarkan data berikut. "
        "Jangan mendiagnosis, jangan menyatakan hubungan sebab-akibat pasti, dan "
        "jawab hanya dengan teks ringkas maksimal 3 kalimat.\n\n"
        f"DATA_PERIODE:\n{json.dumps(period_data, ensure_ascii=False, default=str)}"
    )

    try:
        result = generate_text(prompt).strip()
        return result or fallback_summary
    except Exception:
        return fallback_summary


def generate_habit_recommendations(context: dict[str, Any]) -> list[str]:
    """Generate E5 recommendations from deterministic analytics context."""
    fallback = _load_fallback().get("rekomendasi", [])
    prompt = (
        "Buat 3 sampai 5 rekomendasi kebiasaan praktis dalam bahasa Indonesia "
        "berdasarkan konteks GERD berikut. Jangan mendiagnosis dan jangan memberi "
        "instruksi perubahan obat. Jawab sebagai JSON object dengan key "
        "rekomendasi yang berisi array string.\n\n"
        f"KONTEKS:\n{json.dumps(context, ensure_ascii=False, default=str)}"
    )
    try:
        parsed = _parse_json_response(generate_text(prompt))
        recommendations = parsed.get("rekomendasi")
        if isinstance(recommendations, list):
            return [str(item) for item in recommendations if item][:5] or fallback
    except Exception:
        return fallback
    return fallback
