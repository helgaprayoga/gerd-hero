from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path
from os import getenv

from dotenv import load_dotenv


class ConfigurationError(RuntimeError):
    """Raised when the backend environment is incomplete or invalid."""


@dataclass(frozen=True)
class Settings:
    flask_secret_key: str
    flask_debug: bool
    gemini_api_key: str
    supabase_url: str
    supabase_publishable_key: str
    cors_origins: tuple[str, ...]


def _parse_bool(value: str | None, default: bool = False) -> bool:
    if value is None:
        return default

    normalized = value.strip().lower()
    if normalized in {"1", "true", "yes", "on"}:
        return True
    if normalized in {"0", "false", "no", "off"}:
        return False
    raise ConfigurationError("FLASK_DEBUG harus bernilai true/false")


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    """Load and validate backend configuration once at startup."""
    load_dotenv(Path(__file__).with_name(".env"))

    required = (
        "FLASK_SECRET_KEY",
        "GEMINI_API_KEY",
        "SUPABASE_URL",
        "SUPABASE_PUBLISHABLE_KEY",
    )
    missing = [name for name in required if not getenv(name)]
    if missing:
        raise ConfigurationError(
            "Environment variable wajib belum diatur: " + ", ".join(missing)
        )

    supabase_url = getenv("SUPABASE_URL", "")
    if not supabase_url.startswith(("http://", "https://")):
        raise ConfigurationError("SUPABASE_URL harus berupa URL HTTP/HTTPS")

    cors_value = getenv("CORS_ORIGINS", "*")
    cors_origins = tuple(
        origin.strip() for origin in cors_value.split(",") if origin.strip()
    )
    if not cors_origins:
        raise ConfigurationError("CORS_ORIGINS tidak boleh kosong")

    return Settings(
        flask_secret_key=getenv("FLASK_SECRET_KEY", ""),
        flask_debug=_parse_bool(getenv("FLASK_DEBUG")),
        gemini_api_key=getenv("GEMINI_API_KEY", ""),
        supabase_url=supabase_url,
        supabase_publishable_key=getenv("SUPABASE_PUBLISHABLE_KEY", ""),
        cors_origins=cors_origins,
    )
