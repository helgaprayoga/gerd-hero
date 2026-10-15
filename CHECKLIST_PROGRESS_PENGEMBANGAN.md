# Checklist Progress Pengembangan GERDHero

> Dokumen ini menjadi sumber keputusan tim untuk menentukan apakah fitur MVP
> sudah cukup untuk demo dan kapan pengembangan harus dihentikan.

**Basis:** `backend/PRD GERDHero.md` v1.0 (MVP Hackathon 4 Hari)  
**Tanggal evaluasi:** 15 Oktober 2026  
**Aturan selesai:** fitur dinyatakan selesai apabila alur dasar pengguna dapat
berjalan dari UI sampai penyimpanan/pengambilan data tanpa bug yang memblokir.
Polish, optimasi, dan fitur lanjutan tidak menahan status selesai MVP.

## 1. Definisi status dan level penerapan

### Status

| Status | Arti |
|---|---|
| `[x] Selesai` | Fungsi dasar sudah tersedia dan dapat digunakan untuk alur MVP. |
| `[~] Sebagian` | Sebagian alur tersedia, tetapi masih ada batasan, kontrak yang belum konsisten, atau perlu verifikasi integrasi. |
| `[ ] Belum` | Belum tersedia atau belum memenuhi fungsi dasar PRD. |
| `N/A` | Sengaja tidak dikerjakan karena termasuk Could Have/Won't Have. |

### Level penerapan

Level menunjukkan peluang peningkatan, bukan syarat tambahan agar MVP dianggap
selesai.

| Level | Makna | Keputusan |
|---|---|---|
| **L1 — Fondasi** | UI/prototipe atau alur sebagian sudah ada. | Belum cukup untuk menyatakan fitur selesai. |
| **L2 — MVP fungsional** | Alur utama berjalan, data tersimpan/terambil, dan fallback dasar tersedia. | Target berhenti untuk fitur Must. |
| **L3 — Stabil/polished** | Error state, loading state, validasi, dan UX utama sudah dirapikan. | Dikerjakan jika tidak mengganggu code freeze. |
| **L4 — Lanjutan** | Otomasi, notifikasi, personalisasi, analitik lanjutan, atau integrasi tambahan. | Backlog pasca-MVP. |

## 2. Ringkasan keputusan berhenti

- [ ] Seluruh fitur **Must** berstatus `Selesai` dan minimal **L2**.
- [ ] Alur demo utama berjalan: **Onboarding → GERD-Q → Home → Log Harian → Analitik → Report/PDF**.
- [ ] Tidak ada bug blocker/crash pada alur demo.
- [ ] Loading, empty state, error state, dan fallback AI tersedia pada fitur utama.
- [ ] Fitur **Should** tidak boleh menunda code freeze setelah seluruh Must selesai.
- [ ] Fitur **Could Have** dan **Won't Have** tidak dikerjakan untuk MVP.
- [ ] Setelah checklist di atas terpenuhi, tim masuk **code freeze** dan hanya menerima bug fix kritis.

## 3. Checklist fitur PRD

### A. Akun dan Onboarding

| Selesai | ID | Fitur | Prioritas | Level | Bukti/komponen | Peningkatan yang tidak menahan MVP |
|---|---|---|---|---|---|---|
| [x] | A1 | Splash dan sambutan dengan maskot Gerdie | Must | L2 | `landing_page.dart` | Animasi dan copywriting tambahan. |
| [x] | A2 | Disclaimer wajib dicentang | Must | L2 | `disclaimer_page.dart` | Audit aksesibilitas dan penyempurnaan copy. |
| [x] | A3 | Masuk/daftar email dan kata sandi | Must | L2 | `auth_service.dart`, `login_page.dart`, `register_page.dart` | Verifikasi email dan telemetry auth. |
| [x] | A4 | OAuth Google | Must | L2 | `auth_service.dart`, konfigurasi Supabase Auth | Penanganan provider error yang lebih detail. |
| [~] | A5 | Lupa kata sandi tiga tahap | Should | L2 | `forgot_password_page.dart`, `check_email_page.dart`, `new_password_page.dart` | Verifikasi end-to-end pada environment Supabase production; test reset masih perlu dibereskan. |
| [x] | A6 | Profil dasar: nama, tanggal lahir, gender, tinggi/berat, BMI | Must | L3 | `profile_page.dart`, `/api/profile` | Validasi rentang klinis dan foto profil. |
| [x] | A7 | GERD-Q awal dan halaman hasil | Must | L2 | `gerdq_question_page.dart`, `gerdq_result_page.dart`, `/api/gerdq` | Edukasi lebih lengkap dan histori hasil. |
| [~] | A8 | GERD-Q berkala setiap 7 hari dengan pengingat | Should | L2 | Reminder/evaluasi ulang tersedia di Home; push notification belum ada | Notifikasi lokal/push dan scheduler berkala. |

### B. Home/Beranda

| Selesai | ID | Fitur | Prioritas | Level | Bukti/komponen | Peningkatan yang tidak menahan MVP |
|---|---|---|---|---|---|---|
| [x] | B1 | Tombol Isi Log Harian | Must | L3 | `home_page.dart`, `daily_log_step_one_page.dart` | Deep link dan shortcut tambahan. |
| [x] | B2 | Kartu skor GERD-Q terakhir | Must | L3 | `home_daily_chart.dart`, `/api/gerdq/latest` | Grafik histori skor dan animasi progres. |
| [x] | B3 | Level GERD 7 hari dan riwayat lengkap | Must | L3 | `home_daily_chart.dart`, `daily_history_page.dart` | Filter dan visualisasi yang lebih kaya. |
| [x] | B4 | Kartu harian per minggu dan detail harian | Must | L3 | `daily_history_page.dart`, `daily_history_detail_page.dart` | Pagination/cache histori. |
| [x] | B5 | Hero maskot, state kondisi, dan streak | Should | L3 | `home_hero_card.dart`, `home_streak_badge.dart` | Animasi maskot dan aturan state yang lebih kaya. |
| [x] | B6 | Profil lengkap, kebiasaan, riwayat, obat, ubah tinggi/berat | Should | L3 | `profile_settings_page.dart`, `/api/profile` | Foto profil, audit perubahan, dan field tambahan. |
| [x] | B7 | Sapaan nama di Home | Should | L3 | `home_header.dart` | Fallback nama yang lebih personal. |

### C. Log Harian

| Selesai | ID | Fitur | Prioritas | Level | Bukti/komponen | Peningkatan yang tidak menahan MVP |
|---|---|---|---|---|---|---|
| [~] | C1 | Gejala, opsi tidak ada gejala, deskripsi opsional | Must | L2 | `daily_log_step_one_view.dart`, `proses_gejala.py` | PRD utama menyebut 9 gejala, dokumen pemetaan lama menyebut 10; daftar final perlu disepakati tim. |
| [x] | C2 | Lima pertanyaan pemicu makanan/minuman | Must | L2 | `daily_log_step_two_food_card.dart` | Preset pemicu yang dapat dikonfigurasi. |
| [x] | C3 | Frekuensi makan, jam makan, konfirmasi dibanding kemarin | Must | L2 | `daily_log_step_two_frequency_card.dart`, `daily_log_step_two_meal_time_card.dart` | Shortcut input dan auto-fill lebih pintar. |
| [x] | C4 | Stres, tidur/bangun, konsumsi obat | Must | L2 | `daily_log_step_two_stress_card.dart`, `daily_log_step_two_sleep_card.dart`, medicine widgets | Pengingat obat dan integrasi wearable. |
| [x] | C5 | Ringkasan level GERD, pemicu, kebiasaan, data diri | Must | L3 | `daily_log_summary_page.dart`, `daily_summary_*` | Visualisasi komparasi dan insight lebih detail. |
| [~] | C6 | Draf tersimpan lokal ketika keluar di tengah jalan | Should | L1 | `DailyLogDraft` berjalan antar halaman; persistence lokal belum tersedia | Shared preferences/SQLite dan pemulihan draf setelah restart. |
| [x] | C7 | Kalimat keselamatan tetap | Must | `daily_summary_attention_callout.dart` | L2 | Review medis/copy oleh pakar. |

### D. Logika dan AI

| Selesai | ID | Fitur | Prioritas | Level | Bukti/komponen | Peningkatan yang tidak menahan MVP |
|---|---|---|---|---|---|---|
| [x] | D1 | Level GERD harian dengan bobot Certainty Factor | Must | L2 | `proses_gejala.py`, `hitung_skor_gerd` | Kalibrasi bobot bersama pakar. |
| [x] | D2 | Konsistensi frekuensi makan | Must | L2 | `proses_harian.py` | Dataset pembanding lebih besar. |
| [x] | D3 | Konsistensi jam makan ±60 menit | Must | L2 | `proses_harian.py` | Penanganan zona waktu dan pola shift lebih detail. |
| [x] | D4 | Jeda makan-tidur 2–3 jam | Must | L2 | `proses_harian.py` | Aturan personalisasi berdasarkan jadwal pengguna. |
| [x] | D5 | Flag iritan makanan | Must | L2 | `proses_gejala.py`, `proses_harian.py` | Bobot/pemetaan pemicu yang dapat dikonfigurasi. |
| [x] | D6 | Penalaran AI: pemicu, ringkasan, rekomendasi | Should | L2 | `ai_service.py`, Gemini integration | Cache, observability, dan evaluasi kualitas output. |
| [x] | D7 | Fallback template dan loading state | Must | L3 | `templates/ai_fallback.json`, `ai_service.py` | Retry terkontrol dan indikator status AI. |

### E. Analitik

| Selesai | ID | Fitur | Prioritas | Level | Bukti/komponen | Peningkatan yang tidak menahan MVP |
|---|---|---|---|---|---|---|
| [x] | E1 | Filter mingguan/bulanan dan grafik tren | Must | L2 | `analytics_page.dart`, `/api/analytics` | Zoom, custom range, dan export grafik. |
| [x] | E2 | Pemicu teratas | Must | `analytics_ranked_factors_card.dart`, `analytics_service.py` | Segmentasi berdasarkan waktu/makanan. |
| [x] | E3 | Ringkasan periode oleh AI | Must | `analytics_summary_card.dart`, `generate_analytics_summary` | Perbandingan antarperiode dan feedback kualitas. |
| [x] | E4 | Faktor yang menaikkan/menurunkan level | Must | `analytics_score_dynamics.dart`, `get_influencing_factors` | Penjelasan confidence dan drill-down. |
| [x] | E5 | Rekomendasi kebiasaan | Must | `analytics_recommendations.dart`, `generate_habit_recommendations` | Personalisasi berbasis target pengguna. |
| [ ] | E6 | Tingkat perhatian komplikasi | Should | Belum terlihat sebagai modul terpisah yang tervalidasi | Definisi aturan pakar, level rendah/sedang/tinggi, dan faktor penyumbang. |
| [ ] | E7 | Peringatan tren gejala naik berturut-turut | Should | Belum ada aturan/peringatan eksplisit | Definisi threshold pakar dan notifikasi. |

### F. Report/Laporan Klinis

| Selesai | ID | Fitur | Prioritas | Level | Bukti/komponen | Peningkatan yang tidak menahan MVP |
|---|---|---|---|---|---|---|
| [x] | F1 | Pilih periode, info laporan, pratinjau medical report | Must | L2 | `reports_page.dart`, `report_preview_page.dart`, `report_service.py` | Validasi template oleh tenaga medis dan halaman lampiran. |
| [x] | F2 | Generate dan download PDF | Must | L2 | `/api/generate`, `/api/report/<id>/download`, `report_preview_export_bar.dart` | Queue generation, signed URL, dan layout PDF lebih kaya. |

## 4. Fitur di luar MVP

| Fitur | Status keputusan | Catatan |
|---|---|---|
| Push notification log harian | Backlog | PRD: Could Have. |
| Integrasi wearable | Backlog | PRD: Could Have. |
| Bahasa Inggris | Backlog | PRD: Could Have. |
| Dark mode | Backlog | PRD: Could Have. |
| Konsultasi langsung dokter | Tidak dikerjakan | PRD: Won't Have. |
| Marketplace obat/suplemen | Tidak dikerjakan | PRD: Won't Have. |
| Komunitas/forum | Tidak dikerjakan | PRD: Won't Have. |
| Gamifikasi reward | Tidak dikerjakan | PRD: Won't Have untuk versi ini. |

## 5. Pekerjaan wajib sebelum code freeze

Prioritas berikut adalah pekerjaan verifikasi/stabilisasi, bukan penambahan
fitur baru:

- [ ] Jalankan alur demo end-to-end menggunakan akun dan Supabase environment yang sebenarnya.
- [ ] Pastikan bucket Storage `reports` tersedia dan PDF dapat diunduh.
- [ ] Verifikasi OAuth Google dan reset password pada environment target.
- [ ] Putuskan daftar final jumlah gejala C1 (9 atau 10) dan selaraskan PRD, backend, frontend, serta test.
- [ ] Pastikan fallback AI tampil ketika Gemini gagal/rate limit.
- [ ] Uji akun tanpa GERD-Q, tanpa log, dan tanpa profil lengkap.
- [ ] Uji streak setelah log pertama, log berurutan, tanggal yang terlewat, dan onboarding GERD-Q tanpa Daily Log.
- [ ] Catat dan prioritaskan test yang masih gagal; hanya bug yang memblokir alur demo wajib diperbaiki sebelum freeze.

## 6. Keputusan akhir tim

### MVP cukup untuk berhenti apabila

1. Semua ID **Must** di bagian A–F berstatus `[x]` dan minimal level **L2**.
2. Tidak ada blocker pada alur demo utama.
3. Kekurangan level L3/L4 hanya berupa polish, optimasi, atau peningkatan kualitas.
4. Semua item Should yang belum selesai sudah dicatat sebagai backlog, bukan dikerjakan tanpa batas.

### Jangan menambah fitur baru apabila

- Fitur tersebut tidak diperlukan untuk alur demo utama.
- Fitur tersebut hanya mempercantik UI tanpa memperbaiki bug atau usability dasar.
- Fitur tersebut membutuhkan aturan medis baru yang belum disahkan.
- Fitur tersebut berpotensi merusak fitur Must yang sudah stabil.

**Status rekomendasi saat dokumen ini dibuat:** fitur Must inti sudah berada pada
level fungsional, tetapi code freeze sebaiknya dilakukan setelah checklist
verifikasi pada bagian 5, frontend, integrasi, dan smoke test selesai.

## 7. Checklist pengembangan Frontend

Checklist ini dipakai untuk memastikan setiap fitur terlihat dan dapat
digunakan dari aplikasi Flutter, bukan hanya tersedia di backend.

| Selesai | Area frontend | Level | Bukti/komponen | Pekerjaan lanjutan |
|---|---|---|---|---|
| [x] | Struktur navigasi: Landing, Auth, Onboarding, Home, Analitik, Report | L3 | `lib/features/*/presentation/pages`, bottom navigation | Uji deep link dan back navigation pada semua alur. |
| [x] | Landing dan disclaimer dengan validasi persetujuan | L3 | `landing_page.dart`, `disclaimer_page.dart` | Audit semantic label dan aksesibilitas. |
| [x] | Login, register, Google OAuth, forgot password | L2 | `features/auth/presentation/pages` | Verifikasi callback/provider di device nyata. |
| [x] | Profil onboarding dan kalkulasi BMI | L3 | `profile_page.dart`, `bmi_card.dart` | Tambahkan validasi rentang dan keyboard UX. |
| [x] | GERD-Q intro, enam pertanyaan, progres, hasil | L3 | `gerdq_*_page.dart`, `gerdq_*_widget.dart` | Tambahkan histori hasil dan retry submit yang lebih jelas. |
| [x] | Home loading, empty, error, dan data state | L3 | `home_page.dart`, `home_loading_skeleton.dart` | Tambahkan retry per sumber data bila diperlukan. |
| [x] | Home hero card dan seluruh state status | L3 | `home_hero_card.dart`, `home_dashboard_data.dart` | Uji kombinasi symptomatic/evaluation due secara eksplisit. |
| [x] | Kartu profil, progress, streak, GERD-Q terakhir | L3 | `home_profile_card.dart`, `home_streak_badge.dart`, `home_daily_chart.dart` | Tambahkan animasi ringan tanpa mengganggu performa. |
| [x] | Daily Log slide 1: gejala dan deskripsi | L2 | `daily_log_step_one_page.dart`, `daily_log_step_one_view.dart` | Selaraskan jumlah gejala final dengan PRD. |
| [x] | Daily Log slide 2: pemicu, makan, tidur, stres, obat | L2 | `daily_log_step_two_page.dart`, `daily_log_step_two_*` | Sediakan pemulihan draf setelah aplikasi ditutup. |
| [x] | Daily Log slide 3: ringkasan, skor, AI, safety copy | L3 | `daily_log_summary_page.dart`, `daily_summary_*` | Tambahkan state retry AI dan aksesibilitas chart. |
| [x] | History mingguan dan detail harian | L3 | `daily_history_page.dart`, `daily_history_detail_page.dart` | Pagination/cache data histori. |
| [x] | Analitik filter, grafik, faktor, rekomendasi | L2 | `analytics_page.dart`, `analytics_*` | Empty state untuk periode tanpa log dan export insight. |
| [x] | Report periode, preview, dan aksi export | L2 | `reports_page.dart`, `report_preview_page.dart` | Tampilkan progress generate dan retry download. |
| [x] | Profile & Settings lengkap dan logout | L3 | `profile_settings_page.dart` | Foto profil dan konfirmasi logout bila dibutuhkan. |
| [~] | Test widget dan alur utama | L2 | `mobile_frontend/test` | Dua test lama masih gagal: skip profile dan reset password; putuskan apakah blocker. |
| [ ] | Uji manual device target Android/iOS | L1 | Belum menjadi hasil verifikasi terdokumentasi | Jalankan smoke test dengan akun demo dan checklist bagian 9. |

### Kriteria frontend dianggap selesai

- [ ] Setiap layar Must memiliki loading, empty, error, dan success state yang
  dapat dipahami pengguna.
- [ ] Tombol utama tidak dapat ditekan dua kali ketika request sedang berjalan.
- [ ] Semua form memiliki validasi dasar dan pesan error dalam Bahasa Indonesia.
- [ ] Tidak ada overflow layout pada ukuran layar target utama.
- [ ] Navigasi utama dapat diselesaikan tanpa dead-end atau halaman kosong.
- [ ] Alur onboarding → Home → Daily Log dapat diselesaikan oleh pengguna baru.

## 8. Checklist integrasi Frontend–Backend

| Selesai | Integrasi | Endpoint/kontrak | Level | Verifikasi dan catatan |
|---|---|---|---|---|
| [x] | Auth session dan token Supabase | Supabase Auth + `ApiService` | L2 | Request terautentikasi menggunakan session aktif. |
| [x] | Profil onboarding dan profil settings | `GET/PUT /api/profile` | L3 | Profile dasar dan extended profile tersimpan; progress Home disamakan. |
| [x] | Status onboarding | `GET /api/onboarding/status`, `PUT /api/onboarding/profile`, `PUT /api/onboarding/gerdq` | L2 | Gate menentukan langkah berikutnya. |
| [x] | Submit GERD-Q dan ambil hasil terakhir | `POST /api/gerdq`, `GET /api/gerdq/latest` | L3 | Hasil tersimpan dan evaluation dikembalikan konsisten. |
| [x] | Load dashboard Home | `GET /api/profile`, `GET /api/gerdq/latest`, `GET /api/logs?week=` | L3 | Kegagalan log/GERD-Q tidak lagi menggagalkan seluruh dashboard. |
| [x] | Streak harian | `POST /api/logs` dan field profile `streak_days` | L3 | Hanya Daily Log yang mengubah streak; streak lama dinormalisasi menjadi 0. |
| [x] | Submit Daily Log | `POST /api/logs` | L2 | Payload tiga slide tersimpan dan response membawa hasil streak/level. |
| [x] | Riwayat log mingguan | `GET /api/logs?week=YYYY-Www` | L2 | Data Home dan halaman history menggunakan periode ISO week. |
| [x] | Detail log harian | `GET /api/logs/<date>` | L2 | Detail symptoms, triggers, habits, dan analysis tersedia. |
| [x] | Analitik periode | `GET /api/analytics?period=weekly\|monthly\|custom` | L2 | Trend, trigger, influencing factors, summary, dan recommendations diterima frontend. |
| [x] | AI daily analysis | Backend AI service + fallback template | L3 | Fallback tetap menghasilkan ringkasan ketika Gemini gagal. |
| [x] | Generate report | `POST /api/generate` | L2 | Periode dan data pengguna/log dipakai untuk PDF. |
| [x] | Download report | `GET /api/report/<id>/download` | L2 | Bergantung pada bucket Supabase Storage `reports`. |
| [~] | Error mapping dan retry | `ApiException` + error state setiap halaman | L2 | Sebagian sudah ada; retry per endpoint dan logging client masih dapat ditingkatkan. |
| [~] | Kontrak response terotomasi | API contract/tests | L1 | Belum ada test contract menyeluruh antara Flutter dan Flask. |
| [ ] | Environment production/staging | `.env`, API URL, Supabase, Gemini, Storage | L1 | Verifikasi konfigurasi device demo dan secret management. |

### Kriteria integrasi Frontend–Backend dianggap selesai

- [ ] Semua endpoint Must memiliki request/response contract yang terdokumentasi.
- [ ] Setiap response backend yang dipakai frontend memiliki success, empty, dan
  error behavior yang jelas.
- [ ] Token/session expired menghasilkan alur logout atau re-authentication yang
  aman, bukan layar kosong.
- [ ] Request idempotent atau terlindungi dari submit ganda untuk Daily Log,
  GERD-Q, profile, dan report.
- [ ] Data yang dibuat di satu layar langsung dapat dibaca kembali di layar lain
  setelah reload aplikasi.
- [ ] Alur integrasi utama berhasil pada environment target:
  **register/login → onboarding → GERD-Q → Home → Daily Log → Analitik → PDF**.
- [ ] Tidak ada endpoint penting yang hanya bekerja dengan mock/fallback demo.

## 9. Smoke test rilis/demo

Gunakan satu akun demo baru dan centang setiap item setelah benar-benar diuji
melalui aplikasi, bukan hanya melalui unit test.

- [ ] Daftar akun baru dan masuk kembali.
- [ ] Persetujuan disclaimer wajib bekerja.
- [ ] Profil dasar tersimpan dan BMI berubah setelah tinggi/berat diubah.
- [ ] GERD-Q onboarding tersimpan dan skor tampil di Home setelah reload.
- [ ] GERD-Q tidak mengubah streak sebelum Daily Log dibuat.
- [ ] Daily Log tanpa gejala dapat disimpan.
- [ ] Daily Log dengan gejala dan pemicu dapat disimpan.
- [ ] Daily Log kedua pada hari berikutnya menaikkan streak secara benar.
- [ ] Jeda log memutus streak secara benar.
- [ ] Home tetap usable ketika request analitik/log/GERD-Q mengalami error.
- [ ] History menampilkan data yang baru saja dibuat.
- [ ] Analitik weekly, monthly, dan custom menampilkan data yang sesuai periode.
- [ ] AI fallback tampil saat Gemini tidak tersedia.
- [ ] Report preview sesuai periode yang dipilih.
- [ ] PDF berhasil dibuat, disimpan, dan diunduh.
- [ ] Logout menghapus session dan mengembalikan pengguna ke auth.

## 10. Aturan penghentian pengembangan FE dan integrasi

Tim boleh berhenti mengembangkan fitur baru ketika seluruh item berikut sudah
terpenuhi:

1. Checklist Frontend untuk seluruh fitur **Must** selesai minimal level **L2**.
2. Checklist integrasi untuk seluruh endpoint **Must** selesai minimal level
   **L2**.
3. Smoke test bagian 9 lulus untuk alur utama.
4. Item `[~]` atau `[ ]` yang tersisa tidak memblokir demo dan sudah memiliki
   issue/backlog yang jelas.
5. Setelah itu status proyek diubah menjadi **Code Freeze — Bug Fix Only**.

Setelah code freeze, peningkatan level L3/L4 hanya dikerjakan jika tidak
menambah risiko pada alur Must atau jika ditemukan bug blocker.
