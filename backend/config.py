from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path
from os import getenv
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

from dotenv import load_dotenv


class ConfigurationError(RuntimeError):
    """Raised when the backend environment is incomplete or invalid."""


@dataclass(frozen=True)
class Settings:
    flask_secret_key: str
    flask_debug: bool
    gemini_api_keys: tuple[str, ...]
    groq_api_keys: tuple[str, ...]
    primary_ai_model: str               # Default: gemini/gemini-2.5-flash-lite
    groq_model: str                     # Default: groq/llama-3.1-8b-instant
    groq_fallback_model: str            # Safety fallback for Groq access issues
    supabase_url: str
    supabase_publishable_key: str
    supabase_secret_key: str
    cors_origins: tuple[str, ...]
    app_timezone: str


def _parse_bool(value: str | None, default: bool = False) -> bool:
    if value is None:
        return default

    normalized = value.strip().lower()
    if normalized in {"1", "true", "yes", "on"}:
        return True
    if normalized in {"0", "false", "no", "off"}:
        return False
    raise ConfigurationError("FLASK_DEBUG harus bernilai true/false")


def _load_api_keys(prefix: str, max_keys: int) -> tuple[str, ...]:
    """Load, trim, and de-duplicate numbered provider keys from the environment."""
    names = [prefix, *(f"{prefix}_{index}" for index in range(2, max_keys + 1))]
    values: list[str] = []
    for name in names:
        value = (getenv(name) or "").strip()
        if value and value not in values:
            values.append(value)
    return tuple(values)


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    """Load and validate backend configuration once at startup."""
    load_dotenv(Path(__file__).with_name(".env"))

    required = (
        "FLASK_SECRET_KEY",
        "SUPABASE_URL",
        "SUPABASE_PUBLISHABLE_KEY",
        "SUPABASE_SECRET_KEY",
    )
    missing = [name for name in required if not getenv(name)]
    if missing:
        raise ConfigurationError(
            "Environment variable wajib belum diatur: " + ", ".join(missing)
        )

    gemini_api_keys = _load_api_keys("GEMINI_API_KEY", 5)
    if not gemini_api_keys:
        raise ConfigurationError(
            "Minimal satu environment variable GEMINI_API_KEY harus diisi."
        )
    groq_api_keys = _load_api_keys("GROQ_API_KEY", 4)

    supabase_url = getenv("SUPABASE_URL", "")
    if not supabase_url.startswith(("http://", "https://")):
        raise ConfigurationError("SUPABASE_URL harus berupa URL HTTP/HTTPS")

    cors_value = getenv("CORS_ORIGINS", "*")
    cors_origins = tuple(
        origin.strip() for origin in cors_value.split(",") if origin.strip()
    )
    if not cors_origins:
        raise ConfigurationError("CORS_ORIGINS tidak boleh kosong")

    app_timezone = (getenv("APP_TIMEZONE") or "Asia/Jakarta").strip()
    try:
        ZoneInfo(app_timezone)
    except ZoneInfoNotFoundError as error:
        raise ConfigurationError(f"APP_TIMEZONE tidak valid: {app_timezone}") from error

    return Settings(
        flask_secret_key=getenv("FLASK_SECRET_KEY", ""),
        flask_debug=_parse_bool(getenv("FLASK_DEBUG")),
        gemini_api_keys=gemini_api_keys,
        groq_api_keys=groq_api_keys,
        primary_ai_model=getenv(
            "PRIMARY_AI_MODEL", "gemini/gemini-2.5-flash-lite"
        ),
        groq_model=getenv("GROQ_MODEL", "groq/llama-3.1-8b-instant"),
        groq_fallback_model=getenv(
            "GROQ_FALLBACK_MODEL", "groq/openai/gpt-oss-20b"
        ),
        supabase_url=supabase_url,
        supabase_publishable_key=getenv("SUPABASE_PUBLISHABLE_KEY", ""),
        supabase_secret_key=getenv("SUPABASE_SECRET_KEY", ""),
        cors_origins=cors_origins,
        app_timezone=app_timezone,
    )
