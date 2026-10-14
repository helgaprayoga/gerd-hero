"""Deterministic calculations for analytics features E1–E5."""

from __future__ import annotations

from collections import Counter
from statistics import mean
from typing import Any, Iterable


DEFAULT_SYMPTOM_THRESHOLD = 0.30


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
    level = _number(log.get("gerd_level"))
    return level is not None and level > threshold


def get_gerd_trend(logs: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """E1: Return date/level pairs sorted chronologically for a line chart."""
    trend = []
    for log in logs:
        level = _number(log.get("gerd_level"))
        if level is None:
            continue
        trend.append({
            "tanggal": log.get("log_date"),
            "gerd_level": round(max(0.0, min(level, 1.0)), 4),
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
        level = _number(log.get("gerd_level"))
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
        }
        (menaikkan if difference > 0 else menurunkan).append(item)

    menaikkan.sort(key=lambda item: item["selisih"], reverse=True)
    menurunkan.sort(key=lambda item: item["selisih"])
    return {"menaikkan": menaikkan, "menurunkan": menurunkan}


def get_habit_recommendation_context(
    logs: list[dict[str, Any]], user: dict[str, Any]
) -> dict[str, Any]:
    """E5: Build compact deterministic context for an AI habit prompt."""
    levels = [_number(log.get("gerd_level")) for log in logs]
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
