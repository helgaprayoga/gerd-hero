"""Backfill ``daily_logs.ai_analysis`` for logs imported outside the API.

This is an administrative one-off utility. Normal application log creation
already persists AI analysis through ``POST /api/logs`` and does not need this
script.

Run from the backend directory:

    .venv\\Scripts\\python.exe scripts\\backfill_daily_ai.py

The script uses the Supabase service key locally, skips rows that already have
an analysis, and never prints API keys or other credentials.
"""

from __future__ import annotations

import argparse
import sys
import time
from datetime import date
from pathlib import Path
from typing import Any

# Allow execution as ``python scripts/backfill_daily_ai.py`` from backend.
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from supabase import create_client

from config import get_settings
from routes.helpers import first_row
from services.ai_service import generate_daily_analysis


DEFAULT_USER_ID = "05745cc6-6b35-4975-b4f0-aa422d57dbee"


def _parse_date(value: str | None) -> str | None:
    if value is None:
        return None
    try:
        return date.fromisoformat(value).isoformat()
    except ValueError as error:
        raise argparse.ArgumentTypeError(
            f"Tanggal harus berformat YYYY-MM-DD: {value}"
        ) from error


def _has_analysis(value: Any) -> bool:
    return isinstance(value, dict) and bool(value)


def _load_profile_context(client: Any, user_id: str) -> dict[str, dict[str, Any]]:
    user_response = (
        client.schema("gerdhero")
        .table("users")
        .select("birth_date, bmi, gender, height, weight")
        .eq("id", user_id)
        .limit(1)
        .execute()
    )
    extended_response = (
        client.schema("gerdhero")
        .table("user_profiles_extended")
        .select("smoking, alcohol, work_pattern, coffee, medical_history, routine_meds")
        .eq("user_id", user_id)
        .limit(1)
        .execute()
    )
    return {
        "users": first_row(user_response) or {},
        "extended": first_row(extended_response) or {},
    }


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Isi ai_analysis untuk daily_logs yang masih kosong."
    )
    parser.add_argument("--user-id", default=DEFAULT_USER_ID)
    parser.add_argument("--start", type=_parse_date, help="Tanggal awal opsional.")
    parser.add_argument("--end", type=_parse_date, help="Tanggal akhir opsional.")
    parser.add_argument(
        "--force",
        action="store_true",
        help="Proses ulang baris yang sudah memiliki ai_analysis.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Tampilkan jumlah baris tanpa memanggil AI atau mengubah database.",
    )
    parser.add_argument(
        "--delay",
        type=float,
        default=1.0,
        help="Jeda antar panggilan AI dalam detik (default: 1).",
    )
    return parser


def main() -> int:
    args = _build_parser().parse_args()
    if args.start and args.end and args.start > args.end:
        print("ERROR: --start tidak boleh setelah --end.", file=sys.stderr)
        return 2
    if args.delay < 0:
        print("ERROR: --delay tidak boleh negatif.", file=sys.stderr)
        return 2

    settings = get_settings()
    client = create_client(settings.supabase_url, settings.supabase_secret_key)
    table = client.schema("gerdhero").table("daily_logs")

    query = table.select("*").eq("user_id", args.user_id).order("log_date")
    if args.start:
        query = query.gte("log_date", args.start)
    if args.end:
        query = query.lte("log_date", args.end)
    rows = query.execute().data or []
    rows = [row for row in rows if isinstance(row, dict)]

    pending = [
        row for row in rows
        if args.force or not _has_analysis(row.get("ai_analysis"))
    ]
    print(f"User: {args.user_id}")
    print(f"Total log ditemukan: {len(rows)}")
    print(f"Akan diproses: {len(pending)}")

    if args.dry_run or not pending:
        if not pending:
            print("Tidak ada ai_analysis kosong yang perlu diproses.")
        return 0

    profile_context = _load_profile_context(client, args.user_id)
    success = 0
    failed = 0

    for index, row in enumerate(pending, start=1):
        log_date = row.get("log_date")
        try:
            analysis = generate_daily_analysis(row, profile_context)
            table.update({"ai_analysis": analysis}).eq(
                "user_id", args.user_id
            ).eq("log_date", log_date).execute()
            success += 1
            print(
                f"[{index}/{len(pending)}] {log_date}: tersimpan "
                f"({analysis.get('analysis_source', 'unknown')})"
            )
        except Exception as error:
            failed += 1
            print(f"[{index}/{len(pending)}] {log_date}: GAGAL - {error}")
        if index < len(pending) and args.delay:
            time.sleep(args.delay)

    print(f"Selesai: {success} berhasil, {failed} gagal.")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
