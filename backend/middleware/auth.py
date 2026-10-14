# Decorator @require_auth yang:
# 1. Ambil Authorization: Bearer <token> dari header
# 2. Panggil connection/supabase.py get_authenticated_client(token)
# 3. Inject `g.supabase` dan `g.user_id` ke Flask context
pass