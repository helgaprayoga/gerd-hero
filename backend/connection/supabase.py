from supabase import create_client, Client

from config import get_settings

settings = get_settings()
supabase: Client = create_client(
    settings.supabase_url,
    settings.supabase_publishable_key,
)


def get_authenticated_client(access_token: str) -> Client:
    """Create a custom-schema client carrying the user's Supabase JWT."""
    if not access_token or not isinstance(access_token, str):
        raise ValueError("access_token wajib diisi")

    client = create_client(
        settings.supabase_url,
        settings.supabase_publishable_key,
    )
    client.postgrest.auth(access_token)
    return client


def get_table(client: Client, table_name: str):
    """Return a table query targeting the PRD's custom schema."""
    return client.schema("gerdhero").table(table_name)

