from flask import Blueprint

auth_bp = Blueprint("auth", __name__)

@auth_bp.post("/register")
def register():
    pass  # TODO: validasi input, panggil Supabase auth.sign_up()

@auth_bp.post("/login")
def login():
    pass  # TODO: panggil Supabase auth.sign_in_with_password()
