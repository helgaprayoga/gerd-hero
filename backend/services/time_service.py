"""Application-local date helpers for date-only business rules."""

from datetime import date, datetime
from zoneinfo import ZoneInfo

from config import get_settings


def application_timezone() -> ZoneInfo:
    return ZoneInfo(get_settings().app_timezone)


def application_today() -> date:
    return datetime.now(application_timezone()).date()
