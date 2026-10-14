from google import genai

from config import get_settings


def _get_client():
    return genai.Client(api_key=get_settings().gemini_api_key)

def generate_text(prompt: str) -> str:
    response = _get_client().models.generate_content(
        model="gemini-3.1-flash-lite",
        contents=prompt,
    )
    return response.text
