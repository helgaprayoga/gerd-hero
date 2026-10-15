# PRD Frontend Mobile GERDHero

## 1. Ringkasan

GERDHero adalah aplikasi mobile pendamping kesehatan lambung. Fase pertama frontend menerjemahkan landing page existing ke Flutter dengan pengalaman mobile-first yang hangat, ringan, dan terpercaya.

## 2. Tujuan Fase 1

- Menampilkan identitas GERDHero sebelum pengguna masuk ke produk.
- Menjelaskan manfaat utama secara singkat: memantau gejala, mengenali pemicu, dan menjaga lambung lebih awal.
- Menyediakan dua jalur aksi: mulai menggunakan aplikasi dan masuk ke akun yang sudah ada.
- Menyiapkan fondasi kode yang mudah dikembangkan tanpa berubah menjadi monolith yang sulit dirawat.

## 3. Ruang Lingkup

### In scope

- Landing page responsive untuk ponsel portrait dan ukuran layar yang lebih besar.
- Brand badge, status versi, mascot GERDHero, trust badges, CTA `Mulai`, dan link `Masuk`.
- Animasi mascot saat disentuh dan feedback visual pada CTA.
- Safe area, scrolling, semantic labels, serta tema warna dari desain HTML.
- Routing awal untuk landing page; flow onboarding dan autentikasi disiapkan sebagai extension point.

### Out of scope

- Login, registrasi, onboarding, dashboard, dan API integration.
- Penyimpanan lokal, analytics, push notification, dan remote configuration.
- Klaim diagnosis atau rekomendasi medis personal.

## 4. Arsitektur Modular Monolith

Kode tetap berada dalam satu aplikasi Flutter dan satu deployment unit, tetapi batas modul ditentukan berdasarkan domain:

```text
lib/
├── app/                         # Bootstrap aplikasi dan routing global
├── core/                        # Fondasi lintas fitur, tanpa aturan domain
│   ├── theme/                   # Warna, tipografi, ThemeData
│   └── widgets/                 # Komponen UI generik
└── features/
    └── landing/                # Modul landing page yang mandiri
        └── presentation/
            ├── pages/
            └── widgets/
```

Aturan dependency:

- `app` boleh memakai `core` dan entry point feature.
- `features` boleh memakai `core`, tetapi tidak boleh mengimpor feature lain secara langsung.
- `core` tidak boleh mengimpor `features`.
- State dan interaksi yang hanya dimiliki landing page tinggal di modul `landing`.
- Saat domain membesar, setiap feature dapat ditambah `data`, `domain`, dan `application` tanpa memindahkan tanggung jawab feature lain.

## 5. Persyaratan Fungsional

- Sistem menampilkan greeting `Hai, aku Gery!` dan identitas `GERDHero`.
- Sistem menampilkan CTA `Mulai` yang siap dihubungkan ke onboarding.
- Sistem menampilkan link `Sudah punya akun? Masuk` yang siap dihubungkan ke autentikasi.
- Tap pada mascot memainkan animasi wiggle.
- Tap CTA memberi feedback visual dan menampilkan placeholder action sampai modul onboarding tersedia.
- Konten dapat discroll pada layar pendek dan tidak tertutup system inset.

## 6. Persyaratan Non-Fungsional

- Flutter stable dan null safety.
- Tidak menambah package eksternal pada fase landing page.
- UI harus dapat dipreview melalui widget test tanpa network.
- Kontras, ukuran tap target, dan label semantic mengikuti praktik aksesibilitas Flutter.
- Warna dan spacing tersentralisasi di `core/theme`.

## 7. Kriteria Penerimaan

- `flutter analyze` tidak menghasilkan error.
- `flutter test` dapat dijalankan.
- Landing page menampilkan seluruh elemen utama dari desain HTML.
- Layout tetap terbaca pada lebar ponsel kecil dan besar.
- Interaksi mascot dan CTA berfungsi tanpa crash.

## 8. Rencana Evolusi

1. Tambahkan modul `onboarding` dan `auth` sebagai feature terpisah.
2. Tambahkan router terpusat ketika flow mulai bertambah.
3. Tambahkan repository dan data source per feature saat API backend siap.
4. Tambahkan design tokens dan golden test ketika visual mulai stabil.
