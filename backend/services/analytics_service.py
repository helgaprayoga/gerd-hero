"""Deterministic calculations for analytics features E1–E6.

The values in this module are the source of truth for charts, rankings, and
attention flags. AI receives these values only to explain them in friendly
language; it never calculates or changes the statistics.
"""

from __future__ import annotations

from collections import Counter
from statistics import mean
from typing import Any, Iterable


DEFAULT_SYMPTOM_THRESHOLD = 0.30

_ATTENTION_SYMPTOMS = {
    "nyeri dada": "Nyeri dada",
    "chest pain": "Nyeri dada",
    "kesulitan menelan": "Kesulitan menelan",
    "sulit menelan": "Kesulitan menelan",
    "difficulty swallowing": "Kesulitan menelan",
    "keringat dingin": "Keringat dingin",
    "cold sweat": "Keringat dingin",
}


def _number(value: Any, default: float | None = None) -> float | None:
    try:
        return float(value)
    except (TypeError, ValueError):
        return default


def _trigger_names(triggers: Any) -> Iterable[str]:
    if isinstance(triggers, dict):
        return (str(name) for name, active in triggers.items() if active in (1, True, "1", "true"))
    if isinstance(triggers, list):
        return (str(item) for item in triggers if item)
    return ()


def _symptomatic(log: dict[str, Any], threshold: float) -> bool:
    level = _normalised_level(log.get("gerd_level"))
    return level is not None and level > threshold


def _normalised_level(value: Any) -> float | None:
    level = _number(value)
    if level is None:
        return None
    # Migration 002 stores the Certainty Factor in the 0–1 range. This small
    # compatibility guard also keeps analytics safe for legacy 0–100 rows.
    if level > 1:
        level /= 100
    return round(max(0.0, min(level, 1.0)), 4)


def get_gerd_trend(logs: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """E1: Return date/level pairs sorted chronologically for a line chart."""
    trend = []
    for log in logs:
        level = _normalised_level(log.get("gerd_level"))
        if level is None:
            continue
        trend.append({
            "tanggal": log.get("log_date"),
            "gerd_level": level,
            "gerd_level_percent": round(level * 100, 2),
        })
    return sorted(trend, key=lambda item: str(item["tanggal"]))


def get_top_triggers(
    logs: list[dict[str, Any]],
    threshold: float = DEFAULT_SYMPTOM_THRESHOLD,
) -> list[dict[str, Any]]:
    """E2: Count triggers only on symptomatic days."""
    symptomatic_logs = [log for log in logs if _symptomatic(log, threshold)]
    if not symptomatic_logs:
        return []

    counts = Counter(
        trigger
        for log in symptomatic_logs
        for trigger in _trigger_names(log.get("triggers"))
    )
    total_days = len(symptomatic_logs)
    return [
        {
            "pemicu": trigger,
            "frekuensi": count,
            "total_hari_bergejala": total_days,
            "persen_hari_bergejala": round(count / total_days * 100, 2),
        }
        for trigger, count in counts.most_common()
    ]


def get_influencing_factors(logs: list[dict[str, Any]]) -> dict[str, list[dict[str, Any]]]:
    """E4: Compare average GERD levels for common lifestyle factors.

    This is correlation context, not a medical diagnosis. Factors without
    observations in both groups are omitted.
    """
    factor_values: dict[str, tuple[list[float], list[float]]] = {}

    def add_factor(name: str, active: bool, level: float) -> None:
        active_values, inactive_values = factor_values.setdefault(name, ([], []))
        (active_values if active else inactive_values).append(level)

    for log in logs:
        level = _normalised_level(log.get("gerd_level"))
        if level is None:
            continue
        triggers = set(_trigger_names(log.get("triggers")))
        known_triggers = triggers | {
            str(name) for name in (log.get("triggers") or {})
            if isinstance(log.get("triggers"), dict)
        }
        for trigger in known_triggers:
            add_factor(f"Pemicu: {trigger}", trigger in triggers, level)
        gap = _number(log.get("last_meal_to_sleep_gap_hours"))
        if gap is not None:
            add_factor("Jeda makan-tidur < 2 jam", gap < 2, level)
        stress = _number(log.get("stress_level"))
        if stress is not None:
            add_factor("Stres tinggi (>= 3)", stress >= 3, level)
        sleep = _number(log.get("sleep_duration_minutes"))
        if sleep is not None:
            add_factor("Tidur kurang dari 6 jam", sleep < 360, level)

    menaikkan = []
    menurunkan = []
    for name, (active, inactive) in factor_values.items():
        if not active or not inactive:
            continue
        active_average = mean(active)
        inactive_average = mean(inactive)
        difference = round(active_average - inactive_average, 4)
        item = {
            "faktor": name,
            "rata_rata_saat_aktif": round(active_average, 4),
            "rata_rata_saat_tidak_aktif": round(inactive_average, 4),
            "selisih": difference,
            "selisih_persen_poin": round(difference * 100, 2),
        }
        (menaikkan if difference > 0 else menurunkan).append(item)

    menaikkan.sort(key=lambda item: item["selisih"], reverse=True)
    menurunkan.sort(key=lambda item: item["selisih"])
    return {"menaikkan": menaikkan, "menurunkan": menurunkan}


def get_period_statistics(
    logs: list[dict[str, Any]],
    threshold: float = DEFAULT_SYMPTOM_THRESHOLD,
) -> dict[str, Any]:
    """Return deterministic period statistics used by the UI and period AI."""
    levels = [
        level for level in (_normalised_level(log.get("gerd_level")) for log in logs)
        if level is not None
    ]
    symptomatic_days = sum(1 for log in logs if _symptomatic(log, threshold))
    average = round(mean(levels), 4) if levels else None
    return {
        "log_count": len(logs),
        "symptomatic_day_count": symptomatic_days,
        "average_gerd_level": average,
        "average_gerd_level_percent": round(average * 100, 2) if average is not None else None,
        "minimum_gerd_level": min(levels) if levels else None,
        "maximum_gerd_level": max(levels) if levels else None,
    }


def _symptom_label(value: Any) -> str | None:
    text = str(value or "").strip().lower()
    if not text:
        return None
    for keyword, label in _ATTENTION_SYMPTOMS.items():
        if keyword in text:
            return label
    return None


def get_complication_attention(logs: list[dict[str, Any]]) -> dict[str, Any]:
    """Flag persistent attention symptoms without diagnosing complications."""
    counts: Counter[str] = Counter()
    for log in logs:
        symptoms = log.get("symptoms")
        if not isinstance(symptoms, list):
            continue
        # Count days, not duplicate symptom entries accidentally submitted in
        # a single log row.
        for symptom in set(symptoms):
            label = _symptom_label(symptom)
            if label:
                counts[label] += 1

    flags = [
        {
            "kode": label.lower().replace(" ", "_"),
            "label": label,
            "jumlah_hari": count,
        }
        for label, count in counts.most_common()
    ]
    if flags:
        level = "perlu_diperhatikan"
        message = (
            "Ada gejala yang perlu dipantau lebih dekat selama periode ini. "
            "Informasi ini bukan diagnosis; pertimbangkan konsultasi dengan "
            "tenaga medis, terutama bila gejala berat atau berulang."
        )
    else:
        level = "tidak_terdeteksi"
        message = "Belum ada gejala perhatian khusus yang tercatat pada periode ini."

    return {"level": level, "flags": flags, "message": message}


def get_habit_recommendation_context(
    logs: list[dict[str, Any]], user: dict[str, Any]
) -> dict[str, Any]:
    """E5: Build compact deterministic context for an AI habit prompt."""
    levels = [_normalised_level(log.get("gerd_level")) for log in logs]
    levels = [level for level in levels if level is not None]
    return {
        "user": {
            "nickname": user.get("nickname"),
            "bmi": user.get("bmi"),
            "smoking": user.get("smoking"),
            "alcohol": user.get("alcohol"),
            "coffee": user.get("coffee"),
        },
        "jumlah_hari": len(logs),
        "rata_rata_gerd_level": round(mean(levels), 4) if levels else None,
        "pemicu_teratas": get_top_triggers(logs)[:5],
        "faktor_berpengaruh": get_influencing_factors(logs),
    }
