# GERDHero

GERDHero adalah aplikasi pendamping untuk memantau gejala **GERD (Gastroesophageal Reflux Disease)**. Pengguna mencatat log harian, mengisi kuesioner **GERD-Q**, melihat analitik pola gejala, dan menghasilkan **laporan klinis PDF** untuk konsultasi dokter. Aplikasi mobile dibangun dengan **Flutter**, backend dengan **Flask**, data dan autentikasi memakai **Supabase**, serta analisis harian memakai **LiteLLM** (Gemini/Groq).

---

## Unduh Aplikasi (APK)

APK rilis tersedia di halaman **GitHub Releases**:

- **Rilis terbaru:** https://github.com/helgaprayoga/gerd-hero/releases/latest
- **Semua rilis:** https://github.com/helgaprayoga/gerd-hero/releases
- **Unduh langsung (v1.0.0):** https://github.com/helgaprayoga/gerd-hero/releases/download/v1.0.0/app-release.apk

### Cara memasang di Android

1. Buka salah satu tautan di atas dari browser HP.
2. Unduh berkas `app-release.apk`.
3. Buka berkas APK tersebut, lalu izinkan **"Install unknown apps"** bila diminta.
4. Selesaikan instalasi dan buka **GERDHero**.

> APK ini sudah ditandatangani (release signing). Untuk update di kemudian hari, gunakan APK dengan tanda tangan yang sama agar dapat menimpa instalasi sebelumnya.

---

## Fitur Utama

| Area | Fitur |
|---|---|
| Autentikasi | Login/registrasi email & kata sandi, Google OAuth, lupa kata sandi (deep link) |
| Onboarding | Medical disclaimer, data profil (dasar, kebiasaan, riwayat kesehatan, obat rutin), kuesioner GERD-Q |
| Beranda | Sapaan & streak, hero state, ringkasan GERD level 7 hari, kartu log hari ini |
| Log harian | 3 langkah: gejala → pemicu & kebiasaan → ringkasan |
| Riwayat | Riwayat lengkap per minggu, isi susulan untuk hari yang terlewat, ringkasan per tanggal |
| Analitik | Tren indeks gejala, faktor dominan, dinamika skor, rekomendasi |
| Laporan | Pratinjau laporan klinis 2 halaman, ekspor PDF |
| Backend | Skoring GERD & GERD-Q (D1–D7, E1–E5), analisis AI harian dengan fallback, generator PDF, Storage Supabase |

---

## Arsitektur

```
┌────────────────────┐        HTTPS/JSON         ┌─────────────────────┐
│  Flutter (mobile)  │  ───────────────────────▶ │   Flask Backend     │
│  Supabase Auth     │   Authorization: Bearer   │   (Railway / lokal) │
└─────────┬──────────┘                           └──────────┬──────────┘
          │                                                 │
          │ Supabase SDK                                    │ LiteLLM
          ▼                                                 ▼
   ┌──────────────┐                                   ┌────────────────┐
   │  Supabase    │◀──────────────────────────────────│ Gemini / Groq  │
   │ (Auth + DB)  │        server-side secret key     └────────────────┘
   └──────────────┘
```

- **Mobile** membaca `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, dan `API_BASE_URL` dari `.env`.
- **Backend** memakai `SUPABASE_SECRET_KEY` (server-side) dan meneruskan JWT pengguna agar RLS `auth.uid()` benar.

---

## Struktur Direktori

```
GERDHero/
├─ backend/                     # API Flask
│  ├─ app.py                    # Entry point & registrasi blueprint
│  ├─ config.py                 # Validasi environment
│  ├─ connection/               # Supabase & LiteLLM gateway
│  ├─ middleware/               # require_auth (Bearer token)
│  ├─ migrations/               # Skema SQL Supabase (001, 002)
│  ├─ routes/                   # auth, profile, gerdq, logs, analytics, report, onboarding
│  ├─ services/                 # Skoring, analitik, AI, PDF
│  └─ requirements.txt
├─ mobile_frontend/             # Aplikasi Flutter
│  ├─ lib/features/             # auth, onboarding, landing, home
│  ├─ assets/icon/              # Ikon aplikasi
│  └─ pubspec.yaml
├─ PRD GERDHero.md
├─ CHECKLIST_PROGRESS_PENGEMBANGAN.md
└─ README.md
```

---

## Alur Aplikasi

1. **Landing** → pengguna menekan "Mulai".
2. **Disclaimer** → menyetujui pernyataan medis.
3. **Login/Registrasi** → Supabase Auth (email/Google).
4. **Onboarding profil** → data dasar, kebiasaan, riwayat, obat rutin.
5. **GERD-Q** → 6 pertanyaan, skor dihitung dan disimpan.
6. **Beranda** → pengguna mengisi **log harian** (gejala → kebiasaan → ringkasan).
7. **Riwayat** → melihat/menambah catatan harian yang terlewat (isi susulan).
8. **Analitik** → pola gejala & rekomendasi.
9. **Laporan** → pratinjau dan ekspor PDF untuk dibawa ke dokter.

---

## Prasyarat

- **Flutter** 3.44+ & **Dart** 3.12+ (untuk mobile)
- **Python** 3.11+ (untuk backend)
- **Android SDK** + JDK 17 (untuk build Android)
- Proyek **Supabase** (Auth + Database + Storage)
- **API key Gemini** (wajib) dan Groq (opsional)

---

## Menjalankan Backend

1. Masuk ke folder backend dan buat virtual environment:

   ```powershell
   cd backend
   python -m venv .venv
   .\.venv\Scripts\Activate.ps1
   pip install -r requirements.txt
   ```

2. Buat file `backend/.env`:

   ```env
   FLASK_SECRET_KEY=ubah-dengan-secret-key
   FLASK_DEBUG=True

   SUPABASE_URL=https://<project>.supabase.co
   SUPABASE_PUBLISHABLE_KEY=<publishable-key>
   SUPABASE_SECRET_KEY=<secret-key-server>

   GEMINI_API_KEY=<gemini-key>
   # Opsional:
   GROQ_API_KEY=<groq-key>
   CORS_ORIGINS=*
   APP_TIMEZONE=Asia/Jakarta
   ```

   Variabel wajib: `FLASK_SECRET_KEY`, `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `SUPABASE_SECRET_KEY`, dan minimal satu `GEMINI_API_KEY`.

3. Jalankan migrasi di **Supabase SQL Editor** secara berurutan:

   ```text
   backend/migrations/001_gerdhero_schema.sql
   backend/migrations/002_gerdhero_additions.sql
   ```

   Tambahkan schema `gerdhero` ke **Exposed schemas** pada Supabase Dashboard.

4. Jalankan server:

   ```powershell
   flask --app app run --debug --host 0.0.0.0 --port 5000
   ```

   Cek: `http://127.0.0.1:5000/health` → `{"status":"ok",...}`.

   > Endpoint privat memerlukan header `Authorization: Bearer <supabase_access_token>`.

---

## Menjalankan Frontend (Mobile)

1. Install dependency:

   ```powershell
   cd mobile_frontend
   flutter pub get
   ```

2. Buat file `mobile_frontend/.env`:

   ```env
   SUPABASE_URL=https://<project>.supabase.co
   SUPABASE_PUBLISHABLE_KEY=<publishable-key>

   # Ganti sesuai lingkungan:
   API_BASE_URL=http://10.0.2.2:5000
   ```

3. Konfigurasi deep link di **Supabase → Authentication → URL Configuration → Redirect URLs**:

   ```text
   io.supabase.gerdhero://login-callback
   io.supabase.gerdhero://password-reset
   ```

4. Jalankan aplikasi:

   ```powershell
   flutter run
   ```

### `API_BASE_URL` sesuai perangkat

| Target | Nilai |
|---|---|
| Android Emulator | `http://10.0.2.2:5000` |
| Perangkat fisik (Wi-Fi sama) | `http://<IP-LAN-laptop>:5000` |
| Perangkat fisik via USB | `http://127.0.0.1:5000` + `adb reverse tcp:5000 tcp:5000` |
| Produksi | URL backend ter-deploy, mis. `https://gerd-hero-production.up.railway.app` |

Jika memakai IP LAN, jalankan backend dengan `--host 0.0.0.0` dan izinkan port `5000` di firewall.

---

## Endpoint API

| Method | Endpoint | Keterangan |
|---|---|---|
| GET | `/health` | Status backend |
| POST | `/api/auth/register` | Registrasi |
| POST | `/api/auth/login` | Login |
| GET / PUT | `/api/profile` | Profil pengguna & BMI |
| POST | `/api/gerdq` | Simpan hasil GERD-Q |
| GET | `/api/gerdq/latest` | GERD-Q terakhir |
| POST | `/api/logs` | Simpan log harian |
| GET | `/api/logs?week=YYYY-Www` | Log mingguan |
| GET | `/api/logs/<date>` | Detail log per tanggal |
| POST | `/api/ai/daily-summary` | Ringkasan AI harian |
| GET | `/api/analytics` | Tren, pemicu, faktor, rekomendasi |
| GET | `/api/onboarding/status` | Status onboarding |
| PUT | `/api/onboarding/profile` | Update status onboarding profil |
| PUT | `/api/onboarding/gerdq` | Update status onboarding GERD-Q |
| POST | `/api/report/preview` | Data pratinjau laporan |
| POST | `/api/report/preview-pdf` | Pratinjau PDF |
| POST | `/api/report/generate` | Buat laporan PDF |
| GET | `/api/report/<report_id>/download` | Unduh laporan PDF |

---

## Testing

```powershell
# Mobile
cd mobile_frontend
flutter analyze
flutter test --no-pub

# Backend
cd backend
pytest
```

---

## Troubleshooting

| Gejala | Penyebab & solusi |
|---|---|
| `ModuleNotFoundError: litellm` | Belum `pip install -r requirements.txt` di venv backend |
| Backend 500 di semua endpoint | Variabel `.env` wajib belum lengkap / schema belum di-expose |
| `Riwayat belum dapat dimuat` | `API_BASE_URL` salah (emulator vs perangkat) atau sesi login habis |
| `Keystore file ... not found` | `key.properties` ada tetapi file `.jks` belum dibuat |
| Gradle mencari Flutter SDK salah | Perbaiki `flutter.sdk` di `android/local.properties` |
