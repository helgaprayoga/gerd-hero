"""Gemini-backed analysis with a deterministic fallback.

The service deliberately keeps statistics and thresholds outside the model.
Gemini is used only to explain already collected data in user-friendly text.
"""

from __future__ import annotations

import json
import logging
from datetime import date
from pathlib import Path
from typing import Any

from connection.api import generate_text


_FALLBACK_PATH = Path(__file__).resolve().parent.parent / "templates" / "ai_fallback.json"
_ANALYTICS_FALLBACK_PATH = (
    Path(__file__).resolve().parent.parent / "templates" / "analytics_fallback.json"
)
_LOGGER = logging.getLogger(__name__)
_ANALYTICS_FALLBACK_SUMMARY = (
    "Layanan analisis sedang tidak tersedia. Catatan harian Anda telah "
    "berhasil disimpan. Silakan cek kembali nanti untuk analisis pemicu."
)


def _load_analytics_fallback() -> dict[str, Any]:
    with _ANALYTICS_FALLBACK_PATH.open("r", encoding="utf-8") as fallback_file:
        return json.load(fallback_file)


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


def _calculate_age(birth_date: Any, reference_date: Any) -> int | None:
    """Calculate age server-side so the model never has to infer it."""
    if not birth_date:
        return None
    try:
        birth = date.fromisoformat(str(birth_date)[:10])
        reference = date.fromisoformat(str(reference_date)[:10])
    except (TypeError, ValueError):
        return None

    return reference.year - birth.year - (
        (reference.month, reference.day) < (birth.month, birth.day)
    )


def _age_personalisation(age: int | None) -> dict[str, Any]:
    """Return an age-aware language profile without inventing a user's age."""
    if age is None:
        return {
            "kelompok_usia": "18-35",
            "gaya_bahasa": (
                "ringan, conversational, dan relevan untuk rutinitas dewasa muda"
            ),
            "usia_tidak_tersedia": True,
        }
    if age < 18:
        return {
            "kelompok_usia": "di bawah 18",
            "gaya_bahasa": "sederhana, jelas, dan mudah dipahami",
            "usia_tidak_tersedia": False,
        }
    if age <= 35:
        return {
            "kelompok_usia": "18-35",
            "gaya_bahasa": (
                "ringan, conversational, dan relevan untuk rutinitas dewasa muda"
            ),
            "usia_tidak_tersedia": False,
        }
    if age <= 55:
        return {
            "kelompok_usia": "36-55",
            "gaya_bahasa": "praktis, personal, dan berorientasi pada rutinitas kesehatan",
            "usia_tidak_tersedia": False,
        }
    return {
        "kelompok_usia": "56+",
        "gaya_bahasa": "sederhana, jelas, tenang, dan tidak terlalu teknis",
        "usia_tidak_tersedia": False,
    }


def build_daily_summary_prompt(
    log_data: dict[str, Any], profile_data: dict[str, Any] | None = None
) -> str:
    """Build the structured, read-only context used by the daily summary AI."""
    profile_data = profile_data or {}
    user = profile_data.get("users") or profile_data.get("user") or {}
    extended = profile_data.get("extended") or {}
    log_date = log_data.get("log_date") or date.today().isoformat()
    gerd_level = log_data.get("gerd_level")
    age = _calculate_age(user.get("birth_date"), log_date)
    age_personalisation = _age_personalisation(age)

    context = {
        "tanggal": log_date,
        "gejala": {
            "dipilih": log_data.get("symptoms") or [],
            "tanpa_gejala": bool(log_data.get("no_symptoms", False)),
            "deskripsi": log_data.get("symptom_description"),
            # This value is deterministic and must not be recalculated by AI.
            "gerd_level": gerd_level,
            "gerd_level_persen": (
                round(float(gerd_level) * 100, 2)
                if gerd_level is not None
                else None
            ),
        },
        "pemicu_harian": log_data.get("triggers") or {},
        "pola_harian": {
            "frekuensi_makan": log_data.get("meal_frequency"),
            "jam_makan": log_data.get("meal_times") or [],
            "tingkat_stres": log_data.get("stress_level"),
            "jam_tidur": log_data.get("sleep_time"),
            "jam_bangun": log_data.get("wake_time"),
            "durasi_tidur_menit": log_data.get("sleep_duration_minutes"),
            "jeda_makan_tidur_jam": log_data.get(
                "last_meal_to_sleep_gap_hours"
            ),
            "minum_obat": log_data.get("took_medication", False),
            "obat": log_data.get("medications") or [],
        },
        "indikator_deterministik": log_data.get("indicators") or {},
        "profil_pengguna": {
            "usia": age,
            **age_personalisation,
            "bmi": user.get("bmi"),
            "gender": user.get("gender"),
            "merokok": extended.get("smoking"),
            "alkohol": extended.get("alcohol"),
            "pola_kerja": extended.get("work_pattern"),
            "kopi": extended.get("coffee"),
            "riwayat_penyakit": extended.get("medical_history") or [],
            "obat_rutin": extended.get("routine_meds") or [],
        },
    }

    return (
        "Analisis ringkasan log harian GERD berikut secara hati-hati dalam "
        "bahasa Indonesia. Level GERD sudah dihitung oleh sistem hanya dari "
        "gejala menggunakan Certainty Factor. Jangan menghitung ulang, "
        "mengubah, atau menentukan level GERD.\n\n"
        "Hubungkan gejala dengan pemicu harian, pola kebiasaan, dan data diri "
        "yang tersedia. Gunakan hanya data yang diberikan; jangan menebak "
        "nilai yang kosong. Gunakan frasa 'berpotensi berkaitan', bukan "
        "hubungan sebab-akibat pasti. Jangan mendiagnosis, jangan menyatakan "
        "pengguna aman, dan jangan menampilkan proses reasoning internal.\n"
        "Sesuaikan gaya bahasa dengan kelompok usia pada profil pengguna. "
        "Jika usia tidak tersedia, gunakan gaya bahasa kelompok 18-35 hanya "
        "sebagai default gaya komunikasi; jangan menyatakan atau mengarang "
        "bahwa pengguna berusia 18-35. Gunakan sapaan personal 'kamu' bila "
        "sesuai dan berikan rekomendasi yang praktis untuk rutinitas pengguna.\n"
        "Buat satu object untuk setiap pemicu aktif; jangan menggabungkan "
        "beberapa pemicu menjadi satu string. Masukkan pola stres, tidur, "
        "makan, merokok, alkohol, pola kerja, dan kopi ke bagian kebiasaan. "
        "Masukkan hanya usia dan BMI ke bagian data diri.\n\n"
        "Kembalikan JSON object tanpa markdown dengan struktur tepat berikut:\n"
        "{\n"
        '  "analisis_pemicu_gejala": [{"pemicu": "", "nilai": "", '
        '"bukti": "", "penjelasan_korelasi": ""}],\n'
        '  "kebiasaan_mendukung_gejala": [{"kebiasaan": "", '
        '"nilai": "", "bukti": "", "penjelasan": ""}],\n'
        '  "data_diri_mendukung": [{"faktor": "", "nilai": "", '
        '"label": "", "penjelasan": ""}],\n'
        '  "rekomendasi": ["" ]\n'
        "}\n\n"
        "Aturan output: keluarkan hanya faktor yang didukung data; gunakan "
        "array kosong jika tidak ada; setiap penjelasan harus singkat, "
        "empatik, dan tidak menghakimi.\n\n"
        f"DATA_TERSTRUKTUR:\n{json.dumps(context, ensure_ascii=False, default=str)}"
    )


def _normalise_daily_result(result: dict[str, Any]) -> dict[str, Any]:
    """Ensure the public daily-summary contract is always complete."""
    fallback = _load_fallback()
    list_fields = (
        "analisis_pemicu_gejala",
        "kebiasaan_mendukung_gejala",
        "data_diri_mendukung",
        "rekomendasi",
    )
    normalised = {}
    for field in list_fields:
        value = result.get(field, fallback.get(field, []))
        normalised[field] = value if isinstance(value, list) else fallback.get(field, [])

    return normalised


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
    else:
        trigger_analysis = fallback["analisis_pemicu_gejala"]
    return {
        "analisis_pemicu_gejala": trigger_analysis,
        "kebiasaan_mendukung_gejala": fallback.get("kebiasaan_mendukung_gejala", []),
        "data_diri_mendukung": fallback.get("data_diri_mendukung", []),
        "rekomendasi": fallback["rekomendasi"],
        "analysis_source": "fallback",
    }


def generate_daily_analysis(
    log_data: dict[str, Any], profile_data: dict[str, Any] | None = None
) -> dict[str, Any]:
    """Generate D6 summary using daily log and profile context."""
    prompt = build_daily_summary_prompt(log_data, profile_data)
    try:
        parsed = _parse_json_response(generate_text(prompt, json_mode=True))
        if not isinstance(parsed.get("analisis_pemicu_gejala"), list) or not parsed[
            "analisis_pemicu_gejala"
        ]:
            return _fallback_daily_result(log_data)
        result = _normalise_daily_result(parsed)
        result["analysis_source"] = "llm"
        return result
    except Exception:
        _LOGGER.exception("Analisis AI harian gagal; menggunakan fallback template")
        return _fallback_daily_result(log_data)


def _normalise_period_analysis(result: dict[str, Any]) -> dict[str, Any]:
    fallback = _load_analytics_fallback()
    raw_points = result.get("summary_points")
    points = [str(item).strip()[:180] for item in raw_points or [] if str(item).strip()]
    if len(points) < 3:
        points = fallback["summary_points"]
    points = points[:3]

    raw_recommendations = result.get("recommendations")
    recommendations: list[dict[str, str]] = []
    if isinstance(raw_recommendations, list):
        for item in raw_recommendations[:5]:
            if isinstance(item, dict):
                title = str(item.get("judul") or item.get("title") or "Rekomendasi")
                explanation = str(item.get("penjelasan") or item.get("description") or "")
                if explanation.strip():
                    recommendations.append({"judul": title, "penjelasan": explanation})
            elif str(item).strip():
                recommendations.append({"judul": "Langkah yang bisa dicoba", "penjelasan": str(item)})
    if not recommendations:
        recommendations = fallback["recommendations"]

    explanation = str(result.get("attention_explanation") or "").strip()
    return {
        "summary_points": points,
        "attention_explanation": explanation or fallback["attention_explanation"],
        "recommendations": recommendations,
    }


def generate_period_analysis(period_data: dict[str, Any]) -> dict[str, Any]:
    """Explain deterministic period analytics in a stable JSON contract."""
    fallback = _load_analytics_fallback()
    if not period_data.get("log_count"):
        return {**fallback, "analysis_source": "fallback"}
    prompt = (
        "Anda adalah asisten analitik GERD yang membantu pengguna memahami "
        "catatan hariannya. Analisis hanya berdasarkan DATA_PERIODE.\n\n"
        "Aturan wajib:\n"
        "1. Jangan mendiagnosis.\n"
        "2. Jangan menyatakan hubungan sebab-akibat pasti. Gunakan frasa "
        "'berpotensi berkaitan', 'tercatat bersama', atau 'tampak beriringan'.\n"
        "3. Jangan menghitung ulang atau mengubah gerd_level.\n"
        "4. Jangan membuat angka, persentase, pemicu, atau gejala yang tidak ada.\n"
        "5. Jangan memberi instruksi untuk mengubah atau menghentikan obat.\n"
        "6. Gunakan bahasa Indonesia yang empatik, singkat, dan tidak menghakimi.\n"
        "7. Jika data kurang, nyatakan bahwa pola belum cukup untuk disimpulkan.\n"
        "8. Ringkasan periode harus tepat 3 poin, maksimal 180 karakter per poin.\n\n"
        "Isi summary_points dengan: (1) tren indeks gejala, (2) pemicu teratas "
        "beserta angka yang tersedia, (3) faktor peningkat/pereda atau hal yang "
        "perlu diperhatikan. Buat 3–5 rekomendasi praktis berdasarkan data.\n\n"
        "Kembalikan JSON tanpa markdown dengan struktur:\n"
        "{\n"
        '  "summary_points": ["poin 1", "poin 2", "poin 3"],\n'
        '  "attention_explanation": "penjelasan singkat",\n'
        '  "recommendations": [{"judul": "", "penjelasan": ""}]\n'
        "}\n\n"
        f"DATA_PERIODE:\n{json.dumps(period_data, ensure_ascii=False, default=str)}"
    )
    try:
        parsed = _parse_json_response(generate_text(prompt, json_mode=True))
        result = _normalise_period_analysis(parsed)
        result["analysis_source"] = "llm"
        return result
    except Exception:
        _LOGGER.exception("Analisis AI periode gagal; menggunakan fallback template")
        return {**fallback, "analysis_source": "fallback"}


def generate_analytics_summary(period_data: dict[str, Any]) -> str:
    """Backward-compatible plain-text period summary."""
    result = generate_period_analysis(period_data)
    return " ".join(result.get("summary_points", [])) or _ANALYTICS_FALLBACK_SUMMARY


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
        parsed = _parse_json_response(generate_text(prompt, json_mode=True))
        recommendations = parsed.get("rekomendasi")
        if isinstance(recommendations, list):
            return [str(item) for item in recommendations if item][:5] or fallback
    except Exception:
        return fallback
    return fallback
