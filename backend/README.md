# GERDHero Backend

Backend API menggunakan Python Flask.

## Menjalankan secara lokal

1. Buat dan aktifkan virtual environment:

   ```bash
   python -m venv .venv
   .venv\Scripts\activate
   ```

2. Install dependensi:

   ```bash
   pip install -r requirements.txt
   ```

3. Jalankan server:

   ```bash
   flask --app app run --debug
   ```

API tersedia di `http://127.0.0.1:5000`.

- `GET /` - Memastikan backend aktif
- `GET /health` - Health check
