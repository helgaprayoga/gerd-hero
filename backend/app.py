from flask import Flask, jsonify, request
from flask_cors import CORS
from werkzeug.exceptions import HTTPException

from config import get_settings
from connection.api import generate_text
from proses_gejala import gejala_dict, hitung_skor_gerd
from proses_gerdq import hitung_skor_gerdq
from proses_harian import proses_indikator_harian


def create_app():
    settings = get_settings()
    app = Flask(__name__)
    app.config.update(
        SECRET_KEY=settings.flask_secret_key,
        DEBUG=settings.flask_debug,
    )
    CORS(app, origins=settings.cors_origins)

    @app.get("/health")
    def health():
        return jsonify({
            "status": "ok",
            "service": "gerdhero-backend",
        })

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

    @app.post("/generate")
    def generate():
        data = request.get_json(silent=True) or {}
        prompt = data.get("prompt")

        if not prompt:
            return jsonify({"error": "prompt is required"}), 400

        return jsonify({"response": generate_text(prompt)})

    @app.post("/proses-gejala")
    def proses_gejala():
        """Calculate the GERD certainty factor from the selected symptoms."""
        data = request.get_json(silent=True)

        if not isinstance(data, dict):
            return jsonify({
                "success": False,
                "error": "request body must be a JSON object",
            }), 400

        inputs = data.get("inputs")
        if not isinstance(inputs, dict):
            return jsonify({
                "success": False,
                "error": "inputs must be an object",
            }), 400

        unknown_symptoms = [gejala for gejala in inputs if gejala not in gejala_dict]
        if unknown_symptoms:
            return jsonify({
                "success": False,
                "error": "unknown symptom",
                "unknown_symptoms": unknown_symptoms,
            }), 400

        invalid_values = [
            gejala
            for gejala, selected in inputs.items()
            if type(selected) is not int or selected not in (0, 1)
        ]
        if invalid_values:
            return jsonify({
                "success": False,
                "error": "symptom values must be 0 or 1",
                "invalid_symptoms": invalid_values,
            }), 400

        score = hitung_skor_gerd(inputs, gejala_dict)
        selected_symptoms = [
            gejala for gejala, selected in inputs.items() if selected == 1
        ]

        return jsonify({
            "success": True,
            "data": {
                "score": round(score, 4),
                "percentage": round(score * 100, 2),
                "selected_symptoms": selected_symptoms,
            },
        })

    @app.post("/proses-gerdq")
    def proses_gerdq():
        """Calculate the GerdQ score from six answers scored 0 to 3."""
        data = request.get_json(silent=True)

        if not isinstance(data, dict):
            return jsonify({
                "success": False,
                "error": "request body must be a JSON object",
            }), 400

        jawaban = data.get("jawaban")
        if not isinstance(jawaban, list):
            return jsonify({
                "success": False,
                "error": "jawaban must be an array",
            }), 400

        if len(jawaban) != 6:
            return jsonify({
                "success": False,
                "error": "jawaban must contain exactly 6 answers",
            }), 400

        if any(type(nilai) is not int or nilai not in range(4) for nilai in jawaban):
            return jsonify({
                "success": False,
                "error": "each answer must be an integer from 0 to 3",
            }), 400

        score, evaluation = hitung_skor_gerdq(jawaban)
        return jsonify({
            "success": True,
            "data": {
                "score": score,
                "result": evaluation,
            },
        })

    @app.post("/proses-harian")
    def proses_harian():
        """Calculate daily indicators D2-D5."""
        data = request.get_json(silent=True)
        if not isinstance(data, dict):
            return jsonify({
                "success": False,
                "error": "request body must be a JSON object",
            }), 400

        hari_ini = data.get("hari_ini")
        hari_kemarin = data.get("hari_kemarin")
        if not isinstance(hari_ini, dict):
            return jsonify({
                "success": False,
                "error": "hari_ini must be an object",
            }), 400
        if hari_kemarin is not None and not isinstance(hari_kemarin, dict):
            return jsonify({
                "success": False,
                "error": "hari_kemarin must be an object",
            }), 400

        required_fields = ("frekuensi_makan", "jam_makan", "jam_tidur", "pemicu")
        missing_fields = [field for field in required_fields if field not in hari_ini]
        if missing_fields:
            return jsonify({
                "success": False,
                "error": "missing daily log fields",
                "missing_fields": missing_fields,
            }), 400

        if (
            type(hari_ini["frekuensi_makan"]) is not int
            or hari_ini["frekuensi_makan"] < 1
        ):
            return jsonify({
                "success": False,
                "error": "frekuensi_makan must be a positive integer",
            }), 400
        if not isinstance(hari_ini["jam_makan"], list) or not hari_ini["jam_makan"]:
            return jsonify({
                "success": False,
                "error": "jam_makan must be a non-empty array",
            }), 400
        if len(hari_ini["jam_makan"]) != hari_ini["frekuensi_makan"]:
            return jsonify({
                "success": False,
                "error": "jam_makan count must match frekuensi_makan",
            }), 400

        if hari_kemarin is not None:
            previous_required = ("frekuensi_makan", "jam_makan")
            missing_previous = [
                field for field in previous_required if field not in hari_kemarin
            ]
            if missing_previous:
                return jsonify({
                    "success": False,
                    "error": "missing previous-day fields",
                    "missing_fields": missing_previous,
                }), 400

            if (
                type(hari_kemarin["frekuensi_makan"]) is not int
                or hari_kemarin["frekuensi_makan"] < 1
            ):
                return jsonify({
                    "success": False,
                    "error": "previous frekuensi_makan must be a positive integer",
                }), 400
            if (
                not isinstance(hari_kemarin["jam_makan"], list)
                or not hari_kemarin["jam_makan"]
            ):
                return jsonify({
                    "success": False,
                    "error": "previous jam_makan must be a non-empty array",
                }), 400
            if len(hari_kemarin["jam_makan"]) != hari_kemarin["frekuensi_makan"]:
                return jsonify({
                    "success": False,
                    "error": "previous jam_makan count must match frekuensi_makan",
                }), 400

        try:
            indicators = proses_indikator_harian(hari_ini, hari_kemarin)
        except (KeyError, TypeError, ValueError) as error:
            return jsonify({
                "success": False,
                "error": str(error),
            }), 400

        return jsonify({
            "success": True,
            "data": indicators,
        })

    return app

app = create_app()
