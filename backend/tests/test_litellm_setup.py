"""Smoke test untuk verifikasi setup LiteLLM Router di GERDHero backend.

Jalankan dari direktori backend dengan:
    python tests/test_litellm_setup.py

Tidak memerlukan pytest — dijalankan langsung dengan Python.
Semua test memanggil API nyata, jadi butuh koneksi internet dan GEMINI_API_KEY valid.
"""

from __future__ import annotations

import json
import os
import sys

# Tambahkan backend root ke path agar import bekerja tanpa install package
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Windows PowerShell sering memakai cp1252, sedangkan output test memakai
# marker Unicode. Paksa stdout UTF-8 agar script dapat dijalankan langsung.
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")


def test_router_initializes() -> None:
    """Router harus berhasil diinisialisasi dari konfigurasi .env."""
    from connection.api import get_router

    router = get_router()
    assert router is not None, "Router mengembalikan None"
    print("✅ Router berhasil dibuat")


def test_model_fallback_order() -> None:
    """Model harus mengikuti urutan quota-friendly yang telah ditentukan."""
    from config import get_settings
    from connection.api import _build_fallback_list, _build_model_list

    settings = get_settings()
    assert len(settings.gemini_api_keys) == 5
    assert len(settings.groq_api_keys) == 4
    deployments = _build_model_list()
    models = [deployment["litellm_params"]["model"] for deployment in deployments]
    assert "gemini/gemini-2.5-flash-lite" in models
    assert "gemini/gemini-3.1-flash-lite" in models
    assert "gemini/gemini-3.5-flash-lite" in models
    assert "groq/llama-3.1-8b-instant" in models
    assert models.count("gemini/gemini-2.5-flash-lite") == 5
    assert models.count("gemini/gemini-3.1-flash-lite") == 5
    assert models.count("gemini/gemini-3.5-flash-lite") == 5
    assert models.count("groq/llama-3.1-8b-instant") == 4
    assert models.count("groq/openai/gpt-oss-20b") == 4

    fallback = _build_fallback_list(deployments)
    assert fallback
    assert fallback[0]["gerdhero-primary"] == [
        "gerdhero-gemini-31-lite",
        "gerdhero-gemini-35-lite",
        "gerdhero-groq",
        "gerdhero-groq-safe",
    ]
    assert fallback[1] == {"gerdhero-groq": ["gerdhero-groq-safe"]}
    print("✅ Urutan model Gemini dan Groq sesuai konfigurasi")


def test_generate_text_returns_string() -> None:
    """generate_text harus mengembalikan string non-kosong dari Gemini."""
    from connection.api import generate_text

    result = generate_text("Halo, balas dengan satu kata saja: 'oke'")
    assert isinstance(result, str), f"Bukan string: {type(result)}"
    assert result.strip(), "generate_text mengembalikan string kosong"
    print(f"✅ generate_text OK — respons: {result.strip()[:80]!r}")


def test_generate_text_json_mode() -> None:
    """json_mode=True harus mengembalikan JSON yang dapat di-parse tanpa markdown fence."""
    from connection.api import generate_text

    result = generate_text(
        'Balas HANYA dengan JSON object: {"status": "ok"}',
        json_mode=True,
    )
    parsed = json.loads(result)
    assert isinstance(parsed, dict), f"Hasil parse bukan dict: {result!r}"
    print(f"✅ json_mode OK — parsed keys: {list(parsed.keys())}")


def test_daily_analysis_contract() -> None:
    """Daily summary harus memiliki semua section yang dirender oleh Flutter."""
    from services.ai_service import build_daily_summary_prompt, generate_daily_analysis

    dummy_log = {
        "symptoms": ["Heartburn"],
        "triggers": {"spicy": True, "caffeine": False},
        "stress_level": 3,
        "sleep_duration_minutes": 360,
        "log_date": "2026-10-15",
        "gerd_level": 0.72,
        "indicators": {"jeda_makan_tidur": {"jam": 3.5}},
    }
    profile = {
        "users": {"birth_date": "1998-04-10", "bmi": 27.1},
        "extended": {
            "smoking": "tidak",
            "alcohol": "tidak",
            "work_pattern": "duduk lama",
            "coffee": True,
        },
    }
    prompt = build_daily_summary_prompt(dummy_log, profile)
    assert "gemini" not in prompt.lower()
    assert '"usia": 28' in prompt
    assert '"kelompok_usia": "18-35"' in prompt
    assert '"bmi": 27.1' in prompt
    assert "duduk lama" in prompt
    assert '"ringkasan_analisis"' not in prompt

    missing_age_prompt = build_daily_summary_prompt(dummy_log, {"users": {}})
    assert '"usia": null' in missing_age_prompt
    assert '"kelompok_usia": "18-35"' in missing_age_prompt
    assert '"usia_tidak_tersedia": true' in missing_age_prompt

    result = generate_daily_analysis(dummy_log, profile)
    required_keys = {
        "analisis_pemicu_gejala",
        "kebiasaan_mendukung_gejala",
        "data_diri_mendukung",
        "rekomendasi",
        "analysis_source",
    }
    missing = required_keys - result.keys()
    assert not missing, f"Key wajib tidak ada: {missing}"
    assert isinstance(result["analisis_pemicu_gejala"], list)
    assert isinstance(result["kebiasaan_mendukung_gejala"], list)
    assert isinstance(result["data_diri_mendukung"], list)
    assert isinstance(result["rekomendasi"], list)
    assert "ringkasan_analisis" not in result
    print(f"✅ generate_daily_analysis OK — keys: {list(result.keys())}")


def test_fallback_on_invalid_key() -> None:
    """Dengan API key tidak valid, generate_daily_analysis harus gracefully fallback ke JSON lokal."""
    import os
    from unittest.mock import patch

    # Patch settings sementara dengan key invalid
    invalid_keys = {
        **{
            name: "invalid_key_for_test"
            for name in (
                "GEMINI_API_KEY",
                "GEMINI_API_KEY_2",
                "GEMINI_API_KEY_3",
                "GEMINI_API_KEY_4",
                "GEMINI_API_KEY_5",
                "GROQ_API_KEY",
                "GROQ_API_KEY_2",
                "GROQ_API_KEY_3",
                "GROQ_API_KEY_4",
            )
        }
    }
    with patch.dict(os.environ, invalid_keys):
        # Reset cached router so it rebuilds with the patched env
        import connection.api as api_module
        original_router = api_module._router
        api_module._router = None

        # Reset lru_cache config
        from config import get_settings
        get_settings.cache_clear()

        try:
            from services.ai_service import generate_daily_analysis

            result = generate_daily_analysis({"symptoms": ["test"]})
            required_keys = {
                "analisis_pemicu_gejala",
                "kebiasaan_mendukung_gejala",
                "data_diri_mendukung",
                "rekomendasi",
                "analysis_source",
            }
            missing = required_keys - result.keys()
            assert not missing, f"Fallback tidak memiliki key wajib: {missing}"
            assert "ringkasan_analisis" not in result
            print(f"✅ Fallback JSON OK saat key invalid — keys: {list(result.keys())}")
        finally:
            # Restore original state
            api_module._router = original_router
            get_settings.cache_clear()


if __name__ == "__main__":
    tests = [
        test_router_initializes,
        test_model_fallback_order,
        test_generate_text_returns_string,
        test_generate_text_json_mode,
        test_daily_analysis_contract,
        test_fallback_on_invalid_key,
    ]

    passed = 0
    failed = 0
    for test_fn in tests:
        print(f"\n▶  {test_fn.__name__}")
        try:
            test_fn()
            passed += 1
        except Exception as exc:
            print(f"❌ GAGAL: {exc}")
            failed += 1

    print(f"\n{'=' * 48}")
    print(f"Hasil: {passed}/{len(tests)} test lolos")
    if failed:
        print(f"       {failed} test gagal — periksa error di atas.")
    sys.exit(failed)
