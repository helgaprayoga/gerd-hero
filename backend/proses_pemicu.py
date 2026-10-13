import requests

prompt = input("Masukkan prompt: ")

result = requests.post(
    "http://127.0.0.1:5000/generate",
    json={"prompt": prompt},
)

print(result.json()["response"])