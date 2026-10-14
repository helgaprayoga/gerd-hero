from flask import Blueprint

profile_bp = Blueprint("profile", __name__)

@profile_bp.get("/profile")
def get_profile():
    pass  # TODO: ambil dari gerdhero.users + user_profiles_extended

@profile_bp.put("/profile")
def update_profile():
    pass  # TODO: update gerdhero.users, hitung ulang BMI