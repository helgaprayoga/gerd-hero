from flask import Flask, jsonify
from flask_cors import CORS
from werkzeug.exceptions import HTTPException

from config import get_settings
from routes.auth import auth_bp
from routes.profile import profile_bp
from routes.gerdq import gerdq_bp
from routes.logs import logs_bp
from routes.analytics import analytics_bp
from routes.report import report_bp


def create_app():
    settings = get_settings()
    app = Flask(__name__)
    app.config.update(
        SECRET_KEY=settings.flask_secret_key,
        DEBUG=settings.flask_debug,
    )
    CORS(app, origins=settings.cors_origins)

    # Blueprint per domain.
    app.register_blueprint(auth_bp,      url_prefix="/api/auth")
    app.register_blueprint(profile_bp,   url_prefix="/api")
    app.register_blueprint(gerdq_bp,     url_prefix="/api")
    app.register_blueprint(logs_bp,      url_prefix="/api")
    app.register_blueprint(analytics_bp, url_prefix="/api")
    app.register_blueprint(report_bp,    url_prefix="/api/report")

    @app.get("/health")
    def health():
        return jsonify({"status": "ok", "service": "gerdhero-backend"})

    @app.errorhandler(HTTPException)
    def handle_http_error(error):
        return jsonify({
            "success": False,
            "error": error.name,
            "message": error.description,
        }), error.code

    @app.errorhandler(Exception)
    def handle_unexpected_error(error):
        app.logger.exception("Unhandled backend error: %s", error)
        return jsonify({
            "success": False,
            "error": "Internal Server Error",
            "message": "Terjadi kesalahan pada server.",
        }), 500

    return app


app = create_app()
