# GERDHero Backend

Backend API menggunakan Python Flask.

## Konfigurasi environment

Buat file `.env` di folder `backend` dengan variabel berikut:

```env
FLASK_SECRET_KEY=ubah-dengan-secret-key
FLASK_DEBUG=True
GEMINI_API_KEY=isi-api-key-gemini
SUPABASE_URL=https://project.supabase.co
SUPABASE_PUBLISHABLE_KEY=isi-publishable-key
SUPABASE_SECRET_KEY=isi-secret-key-server
CORS_ORIGINS=*
```

Backend akan gagal dijalankan jika variabel wajib tidak tersedia atau `SUPABASE_URL` bukan URL HTTP/HTTPS.

## Database migration

Migration Supabase tersedia di:

```text
migrations/001_gerdhero_schema.sql
migrations/002_gerdhero_additions.sql
migrations/003_onboarding_status.sql
migrations/004_remove_other_gender.sql
```

Jalankan file tersebut secara berurutan melalui Supabase SQL Editor. Migration
membuat schema `gerdhero` bila belum ada. Setelah itu, tambahkan `gerdhero` ke
**Exposed schemas** pada Supabase Dashboard agar dapat diakses melalui PostgREST.

Query untuk data pengguna harus dibuat dengan `get_authenticated_client(access_token)` dan `get_table(client, table_name)` dari `connection/supabase.py`. Cara ini meneruskan JWT pengguna dan memastikan policy RLS menggunakan `auth.uid()` yang benar.

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

## Endpoint

- `GET /health` - Memeriksa status backend.
- `POST /api/auth/register` - Registrasi email dan kata sandi.
- `POST /api/auth/login` - Login pengguna.
- `GET|PUT /api/profile` - Profil pengguna dan kalkulasi BMI.
- `POST /api/gerdq` dan `GET /api/gerdq/latest` - GERD-Q.
- `POST /api/logs`, `GET /api/logs`, `GET /api/logs/<date>` - Log harian.
- `GET /api/analytics` - Tren, pemicu, faktor, dan rekomendasi.
- `POST /api/report/generate` dan `GET /api/report/<id>/download` - Laporan PDF.

Selain `/health`, endpoint privat menggunakan:

```http
Authorization: Bearer <supabase_access_token>
```

Sebelum menggunakan fitur laporan, buat bucket Storage Supabase bernama
`reports`. File disimpan di path `<user_id>/<report_number>.pdf` menggunakan
secret key server-side; secret key tidak boleh dikirim ke frontend.

## Kontrak API MVP berdasarkan PRD

Endpoint berikut adalah kontrak target untuk modul MVP. Endpoint yang belum memiliki status **Aktif** akan diimplementasikan pada fase berikutnya.

| Method | Endpoint | Status | Keterangan |
|---|---|---|---|
| POST | `/api/auth/register` | Direncanakan | Registrasi email dan kata sandi |
| POST | `/api/auth/login` | Direncanakan | Login pengguna |
| GET | `/api/profile` | Direncanakan | Mengambil profil pengguna |
| PUT | `/api/profile` | Direncanakan | Memperbarui profil pengguna |
| POST | `/api/gerdq` | Direncanakan | Menyimpan hasil GERD-Q |
| GET | `/api/gerdq/latest` | Direncanakan | Mengambil skor GERD-Q terakhir |
| POST | `/api/logs` | Direncanakan | Menyimpan log harian |
| GET | `/api/logs?week=YYYY-Www` | Direncanakan | Mengambil log mingguan |
| GET | `/api/logs/<date>` | Direncanakan | Mengambil detail log berdasarkan tanggal |
| GET | `/api/analytics?period=weekly&date=YYYY-MM-DD` | Direncanakan | Mengambil analitik periode |
| POST | `/api/report/generate` | Direncanakan | Membuat laporan PDF |
| GET | `/api/report/<id>/download` | Direncanakan | Mengunduh laporan PDF |

Handler endpoint sudah terhubung ke Supabase, service kalkulasi D1–D7 dan
E1–E5, serta generator PDF. Pastikan migration sudah dijalankan dan schema
`gerdhero` sudah ditambahkan ke **Exposed schemas**.

Respons sukses `/proses-gerdq`:

```json
{
  "success": true,
  "data": {
    "score": 11,
    "result": "Kemungkinan menderita GERD"
  }
}
```

### Contoh `POST /proses-harian`

```json
{
  "hari_ini": {
    "frekuensi_makan": 3,
    "jam_makan": ["07:15", "12:30", "19:00"],
    "jam_tidur": "23:30",
    "pemicu": {
      "Pedas": 1,
      "Berlemak/gorengan": 0,
      "Asam": 0,
      "Berkafein": 1,
      "Bersoda": 0
    }
  },
  "hari_kemarin": {
    "frekuensi_makan": 3,
    "jam_makan": ["07:00", "13:00", "19:30"]
  }
}
```

Jika `hari_kemarin` tidak dikirim, indikator konsistensi frekuensi dan jam makan bernilai `null` dengan status `belum tersedia`.
