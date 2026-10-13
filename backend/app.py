from flask import Flask, jsonify, request
from connection.api import generate_text
from proses_gejala import gejala_dict, hitung_skor_gerd
from proses_gerdq import hitung_skor_gerdq

def create_app():
    app = Flask(__name__)

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

        score = hitung_skor_gerdq(jawaban)
        return jsonify({
            "success": True,
            "data": { 
                "Skor": score,
            },
        })

    return app

app = create_app()
