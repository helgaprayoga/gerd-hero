"""LiteLLM-backed resilient AI Gateway with multi-provider fallback.

Public interface:
    generate_text(prompt, json_mode=False) -> str

Internal:
    - Builds a LiteLLM Router with all configured providers at startup.
    - Fallback chain: Gemini 2.5 Flash-Lite → Gemini 3.1 Flash-Lite →
      Gemini 3.5 Flash-Lite → legacy Groq model → safe Groq fallback.
    - Router is a module-level singleton to avoid re-initialization overhead.
"""

from __future__ import annotations

import logging
from typing import Any

import litellm
from litellm import Router

from config import get_settings

logger = logging.getLogger(__name__)

# Suppress LiteLLM's verbose telemetry and cost logs
litellm.telemetry = False
litellm.suppress_debug_info = True


def _add_deployments(
    deployments: list[dict[str, Any]],
    *,
    model_name: str,
    model: str,
    api_keys: tuple[str, ...],
    timeout: int,
) -> None:
    """Add one load-balanced deployment per configured provider key."""
    for api_key in api_keys:
        deployments.append({
            "model_name": model_name,
            "litellm_params": {
                "model": model,
                "api_key": api_key,
                "timeout": timeout,
            },
        })


def _build_model_list() -> list[dict[str, Any]]:
    """Construct the LiteLLM deployment list from current settings.

    Only deployments whose API key is available are added, so the router
    gracefully degrades when optional keys are absent.
    """
    settings = get_settings()
    deployments: list[dict[str, Any]] = []

    # --- Primary tier: Gemini 2.5 Flash-Lite, all configured keys ---
    _add_deployments(
        deployments,
        model_name="gerdhero-primary",
        model=settings.primary_ai_model,
        api_keys=settings.gemini_api_keys,
        timeout=8,
    )

    # --- Fallback Tier 1: Gemini 3.1 Flash-Lite ---
    _add_deployments(
        deployments,
        model_name="gerdhero-gemini-31-lite",
        model="gemini/gemini-3.1-flash-lite",
        api_keys=settings.gemini_api_keys,
        timeout=6,
    )

    # --- Fallback Tier 2: Gemini 3.5 Flash-Lite ---
    _add_deployments(
        deployments,
        model_name="gerdhero-gemini-35-lite",
        model="gemini/gemini-3.5-flash-lite",
        api_keys=settings.gemini_api_keys,
        timeout=6,
    )

    # --- Fallback Tier 3: legacy Groq model (optional) ---
    _add_deployments(
        deployments,
        model_name="gerdhero-groq",
        model=settings.groq_model,
        api_keys=settings.groq_api_keys,
        timeout=5,
    )
    if settings.groq_fallback_model != settings.groq_model:
        _add_deployments(
            deployments,
            model_name="gerdhero-groq-safe",
            model=settings.groq_fallback_model,
            api_keys=settings.groq_api_keys,
            timeout=5,
        )

    return deployments


def _build_fallback_list(deployments: list[dict[str, Any]]) -> list[dict]:
    """Construct fallback chain from available deployment names."""
    available = {d["model_name"] for d in deployments}
    candidates = [
        "gerdhero-gemini-31-lite",
        "gerdhero-gemini-35-lite",
        "gerdhero-groq",
        "gerdhero-groq-safe",
    ]
    targets = [name for name in candidates if name in available]
    if not targets:
        return []
    fallback_list = [{"gerdhero-primary": targets}]
    if "gerdhero-groq" in available and "gerdhero-groq-safe" in available:
        fallback_list.append({"gerdhero-groq": ["gerdhero-groq-safe"]})
    return fallback_list


_router: Router | None = None


def get_router() -> Router:
    """Return the module-level LiteLLM Router singleton."""
    global _router
    if _router is None:
        deployments = _build_model_list()
        if not deployments:
            raise RuntimeError(
                "Tidak ada AI provider yang dikonfigurasi. "
                "Pastikan GEMINI_API_KEY sudah diisi di .env."
            )
        fallbacks = _build_fallback_list(deployments)
        _router = Router(
            model_list=deployments,
            fallbacks=fallbacks,
            num_retries=2,
            allowed_fails=1,
            cooldown_time=60,
        )
        logger.info(
            "LiteLLM Router initialized — %d deployment(s), Gemini keys: %d, "
            "Groq keys: %d, fallback chain: %s",
            len(deployments),
            len(get_settings().gemini_api_keys),
            len(get_settings().groq_api_keys),
            [list(f.values())[0] for f in fallbacks] if fallbacks else "none",
        )
    return _router


def generate_text(prompt: str, json_mode: bool = False) -> str:
    """Generate a completion using the LiteLLM Router with transparent failover.

    Args:
        prompt:    The user prompt string.
        json_mode: If True, request JSON output format from the model.
                   Reduces markdown fences and malformed JSON risk.

    Returns:
        The model's text response as a string.

    Raises:
        Any exception from LiteLLM if all providers are exhausted.
        The caller (ai_service.py) is responsible for catching and loading
        the local ai_fallback.json as the last line of defense.
    """
    router = get_router()
    messages = [{"role": "user", "content": prompt}]
    kwargs: dict[str, Any] = {
        "model": "gerdhero-primary",
        "messages": messages,
        "temperature": 0.2,
    }
    if json_mode:
        kwargs["response_format"] = {"type": "json_object"}

    response = router.completion(**kwargs)
    return response.choices[0].message.content or ""
