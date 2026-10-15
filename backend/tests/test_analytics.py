"""Deterministic analytics and period-AI contract tests.

Run from ``backend`` with:
    python tests/test_analytics.py
"""

from __future__ import annotations

import json
import os
import sys
from unittest.mock import patch

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

from services.ai_service import generate_period_analysis
from services.analytics_service import (
    get_complication_attention,
    get_gerd_trend,
    get_influencing_factors,
    get_period_statistics,
    get_top_triggers,
)


LOGS = [
    {
        "log_date": "2026-10-05",
        "gerd_level": 0.8,
        "symptoms": ["Heartburn", "Nyeri dada"],
        "triggers": {"kafein": True, "pedas": True},
        "last_meal_to_sleep_gap_hours": 1.0,
        "stress_level": 4,
        "sleep_duration_minutes": 300,
    },
    {
        "log_date": "2026-10-06",
        "gerd_level": 0.2,
        "symptoms": [],
        "triggers": {"kafein": False, "pedas": False},
        "last_meal_to_sleep_gap_hours": 3.0,
        "stress_level": 2,
        "sleep_duration_minutes": 450,
    },
    {
        "log_date": "2026-10-07",
        "gerd_level": 0.6,
        "symptoms": ["Kesulitan menelan"],
        "triggers": {"kafein": True, "pedas": False},
        "last_meal_to_sleep_gap_hours": 1.5,
        "stress_level": 3,
        "sleep_duration_minutes": 330,
    },
]


def test_deterministic_sections() -> None:
    trend = get_gerd_trend(LOGS)
    assert [item["gerd_level"] for item in trend] == [0.8, 0.2, 0.6]
    assert trend[0]["gerd_level_percent"] == 80

    triggers = get_top_triggers(LOGS)
    assert triggers[0]["pemicu"] == "kafein"
    assert triggers[0]["frekuensi"] == 2
    assert triggers[0]["total_hari_bergejala"] == 2
    assert triggers[0]["persen_hari_bergejala"] == 100

    stats = get_period_statistics(LOGS)
    assert stats["log_count"] == 3
    assert stats["symptomatic_day_count"] == 2
    assert stats["average_gerd_level_percent"] == 53.33

    factors = get_influencing_factors(LOGS)
    assert factors["menaikkan"]
    assert factors["menaikkan"][0]["selisih_persen_poin"] > 0

    attention = get_complication_attention(LOGS)
    assert attention["level"] == "perlu_diperhatikan"
    assert {item["label"] for item in attention["flags"]} == {
        "Nyeri dada",
        "Kesulitan menelan",
    }


def test_period_ai_contract() -> None:
    fake_response = json.dumps(
        {
            "summary_points": ["Satu", "Dua", "Tiga"],
            "attention_explanation": "Pantau gejala yang berulang.",
            "recommendations": [
                {"judul": "Jeda makan", "penjelasan": "Beri jeda sebelum tidur."}
            ],
        }
    )
    with patch("services.ai_service.generate_text", return_value=fake_response):
        result = generate_period_analysis({"log_count": 3, "trend": []})
    assert result["analysis_source"] == "llm"
    assert result["summary_points"] == ["Satu", "Dua", "Tiga"]
    assert result["recommendations"][0]["judul"] == "Jeda makan"


def test_period_ai_empty_data_uses_local_fallback() -> None:
    result = generate_period_analysis({"log_count": 0})
    assert result["analysis_source"] == "fallback"
    assert len(result["summary_points"]) == 3


if __name__ == "__main__":
    tests = [
        test_deterministic_sections,
        test_period_ai_contract,
        test_period_ai_empty_data_uses_local_fallback,
    ]
    failed = 0
    for test in tests:
        try:
            test()
            print(f"✅ {test.__name__}")
        except Exception as error:
            failed += 1
            print(f"❌ {test.__name__}: {error}")
    print(f"Hasil: {len(tests) - failed}/{len(tests)} test lolos")
    raise SystemExit(failed)
