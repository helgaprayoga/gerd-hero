gejala_dict = {
    "Heartburn": 0.6,
    "Regurgitasi": 0.7,
    "Nyeri dada": 0.8,
    "Sulit menelan": 0.6,
    "Kembung dan gas": 0.4,
    "Suara serak": 0.2,
    "Keringat dingin": 0.4,
    "Kram perut": 0.3,
    "Tak nyaman di tenggorokan": 0.4,
}   

def hitung_skor_gerd(inputs, weights):
    cf_total = 0.0
    for gejala, selected in inputs.items():
        if selected == 1 and gejala in weights:
            cf_gejala = weights[gejala]
            # Combined CF Formula: CF_combined = CF1 + CF2 * (1 - CF1)
            cf_total = cf_total + cf_gejala * (1 - cf_total)
    return cf_total

# result = requests.post(
#     "http://127.0.0.1:5000/generate",
#     json={"prompt": "Explain GERD simply"},
# )

# print(result.json()["response"])
