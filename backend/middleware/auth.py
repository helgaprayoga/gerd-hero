"""Authentication middleware for Supabase access tokens."""

from functools import wraps

from flask import g, jsonify, request

from connection.supabase import get_authenticated_client


def _unauthorized(message: str):
    return jsonify({
        "success": False,
        "error": "Unauthorized",
        "message": message,
    }), 401


def require_auth(view):
    """Validate a Supabase bearer token and expose request context.

    Supabase Auth validates the token through ``auth.get_user``. The client
    stored in ``g.supabase`` still carries the user's JWT so PostgREST RLS
    evaluates queries against the authenticated user.
    """

    @wraps(view)
    def wrapped(*args, **kwargs):
        authorization = request.headers.get("Authorization", "")
        scheme, _, token = authorization.partition(" ")
        if scheme.lower() != "bearer" or not token.strip():
            return _unauthorized("Header Authorization Bearer wajib diisi.")

        token = token.strip()
        try:
            client = get_authenticated_client(token)
            response = client.auth.get_user(token)
            user = getattr(response, "user", None)
            user_id = getattr(user, "id", None)
        except Exception:
            return _unauthorized("Token tidak valid atau sudah kedaluwarsa.")

        if not user_id:
            return _unauthorized("Token tidak memiliki identitas pengguna.")

        g.user_id = user_id
        g.supabase = client
        g.access_token = token
        return view(*args, **kwargs)

    return wrapped
