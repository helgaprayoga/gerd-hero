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
CORS_ORIGINS=*
```

Backend akan gagal dijalankan jika variabel wajib tidak tersedia atau `SUPABASE_URL` bukan URL HTTP/HTTPS.

## Database migration

Migration Supabase tersedia di:

```text
migrations/001_gerdhero_schema.sql
```

Jalankan file tersebut melalui Supabase SQL Editor. Migration mengasumsikan schema `gerdhero` sudah tersedia. Setelah itu, tambahkan `gerdhero` ke **Exposed schemas** pada Supabase Dashboard agar dapat diakses melalui PostgREST.

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

- `POST /generate` - Mengirim prompt ke Gemini dan mengembalikan respons teks.
- `GET /health` - Memeriksa status backend.
- `POST /proses-gejala` - Menghitung skor Certainty Factor dari gejala yang dipilih.
- `POST /proses-gerdq` - Menghitung skor dan hasil GERD-Q dari 6 jawaban bernilai 0-3.
- `POST /proses-harian` - Menghitung indikator D2-D5 dari data log harian.

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

Endpoint foundation yang sudah aktif (`/health`, `/generate`, `/proses-gejala`, `/proses-gerdq`, dan `/proses-harian`) akan dipertahankan sebagai service logika dan health check selama endpoint MVP di atas dikembangkan.

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
