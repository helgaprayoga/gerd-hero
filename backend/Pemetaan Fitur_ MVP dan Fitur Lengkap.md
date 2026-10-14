**Pemetaan Fitur: MVP dan Fitur Lengkap**

1. **Struktur Aplikasi**  
   

| Area | Isi |
| :---- | :---- |
| Bottom nav | Home, Analytik, Report |
| Di luar tab | Layar onboarding, Profile (dari ikon di Home), Riwayat Lengkap dan Detail Harian (dari Home), Log Harian (sesi 3 slide)  |

   

2. **Katalog Fitur Lengkap dan Status**  
   Keterangan status: Must (wajib di MVP), Should (dikerjakan bila Must aman)   
     
1. **Akun dan Onboarding**  
   

| ID | Fitur | Status | Catatan |
| :---- | :---- | :---- | :---- |
| A1  | Splash dan sambutan  | Must  |  |
| A2 | Disclaimer, wajib dicentang  | Must  |  |
| A3 | Autentikasi manual (Masuk, Daftar: email, kata sandi, konfirmasi)  | Must  |  |
| A4 | OAuth Google  | Must  |  |
| A5  | Lupa kata sandi (3C, 3D)  | Should  | Layar atur ulang bisa memakai halaman bawaan penyedia auth  |
| A6  | Profil dasar: tanggal lahir (usia), jenis kelamin, tinggi dan berat (BMI)  | Must  |  |
| A7 | GERD-Q awal dan halaman hasil (0-7 kemungkinan tidak GERD, 8-18 kemungkinan GERD)  | Must  | Pertanyaan harus sesuai versi baku kalbemed  |
| A8  | GERD-Q berkala dengan pengingat | Should  |  |

   

2. **Home**  
   

| ID | Fitur | Status | Catatan |
| :---- | :---- | :---- | :---- |
| B1  | Tombol Log Harian  | Must  |  |
| B2 | Kartu Skor GERD-Q terakhir  | Must  |  |
| B3 | riwayat level GERD 7 hari dan tombol "Lihat riwayat lengkap"  | Must  |  |
| B4  | Riwayat Lengkap (kartu harian per minggu) dan Detail Harian  | Must  |  |
| B5  | Maskot 4 keadaan (default, tenang, bergejala, tidak aktif) dan chip streak  | Should  | Tidak aktif: belum ada log atau lebih dari 3 hari tanpa log, teks dibedakan  |
| B6  | Profile lengkap: kebiasaan (merokok, alkohol, pola kerja, kopi), riwayat penyakit, obat rutin, ubah TB/BB  | Should  | BMI dihitung ulang otomatis. Kartu "Lengkapi profil" di Home  |
| B7  | Sapaan nama di Home  | Should  | Sumber nama: akun Google, atau bagian depan email  |

   

3. **Log Harian (satu sesi, 3 slide, harus selesai semua)**   
   

| ID | Fitur | Status | Catatan |
| :---- | :---- | :---- | :---- |
| C1  | Slide 1: 10 gejala dicentang, opsi "Tidak ada gejala", deskripsi opsional  | Must  |  |
| C2 | Slide 2: 5 pertanyaan ya/tidak (pedas, berlemak, asam, berkafein, bersoda)   | Must  |  |
| C3  | Slide 2: frekuensi makan, jam makan, konfirmasi sekali ketuk "masih di rentang kemarin (±1 jam)" bila frekuensi sama  | Must  |  |
| C4  | Slide 2: stres 1-5, jam tidur dan bangun, konsumsi obat (ya/tidak, jenis)  | Must  |  |
| C5  | Slide 3: Level GERD, pemicu berpotensi terkait (AI), kebiasaan pendukung gejala, data diri pendukung (usia, BMI)  | Must |  |
| C6  | Draf tersimpan lokal bila keluar di tengah jalan, masuk database saat Simpan  | Should  |  |
| C7  | Kalimat tetap keselamatan di slide 3 ("Gejala seperti nyeri dada atau sesak napas dapat berkaitan dengan kondisi lain...")  | Must |  |

   

4. **Logika dan AI (inti Implementasi Teknis)**  
   

| ID | Fitur | Status | Catatan |
| :---- | :---- | :---- | :---- |
| D1  | Level GERD harian  | Must  | Σ bobot dicentang menggunakan metode certentyfactor |
| D2 | Konsistensi frekuensi makan (0/1)  | Must  | Hari ini vs kemarin. Hari pertama "belum tersedia", bukan 0  |
| D3  | Konsistensi jam makan  | Must  | Makan ke-k vs makan ke-k kemarin, toleransi ±60 menit  |
| D4  | Jeda makan-tidur  | Must  | Makan terakhir kemarin ke jam tidur semalam, patokan 2-3 Indikator pemantauan berbasis faktor persisten (bukan dari satu hari log), tampil di Analytik dan Report dengan level Rendah / Sedang / Tinggi. Faktor yang dinilai: gejala menetap (heartburn ≥2 hari/minggu, kesulitan menelan yang berulang), penggunaan obat lama atau obat berisiko, tren berat badan turun, serta faktor risiko usia, BMI, merokok, dan alkohol. Setiap level disertai daftar faktor penyumbangnya. Aturan dan ambang final harus disahkan pakar. Bukan diagnosis. jam  |
| D5  | Flag iritan setiap makanan (1/0)  | Must | Jawaban "ya" \= iritan  |
| D6  | Penalaran AI (pemicu, ringkasan, rekomendasi habit)  | Should  | Input data terstruktur, output JSON, statistik dihitung di kode. Bahasa "berpotensi berkaitan", tanpa diagnosis, tanpa jaminan aman, nyeri dada tidak pernah disimpulkan "pasti GERD"  |
| D7  | Fallback templat dan loading state bila AI gagal  | Must | Wajib untuk demo  |

   Bobot gejala: Heartburn 0,6; Regurgitasi 0,7; Nyeri dada 0,8; Sulit menelan 0,6; Kembung dan gas 0,4; Suara serak 0,2; Keringat dingin 0,4; Kram perut 0,3; Tak nyaman di tenggorokan 0,4; Gejala sementara (gejala akan menghilang dalam beberapa jam atau setelah penggunaan antasida) 0,7. 

   

5. **Analytik**  
   

| ID | Fitur | Status | Catatan |
| :---- | :---- | :---- | :---- |
| E1  | Filter mingguan/bulanan dan grafik tren level GERD | Must  |  |
| E2 | Pemicu teratas  | Must  | Frekuensi pemicu pada hari bergejala, dihitung di kode  |
| E3  | Ringkasan periode (AI)  | Must  |  |
| E4  | Faktor yang menaikkan dan menurunkan level GERD | Must  |  |
| E5  | Rekomendasi habit  | Must |  |
| E6  | Tingkat Perhatian Komplikasi (lama gejala menetap, obat lama, usia, BMI, merokok, alkohol)  | Should  |  |
| E7  | Peringatan tren bila gejala naik berturut-turut  | Should  | Butuh aturan pakar (berapa hari)  |

   

6. **Report**  
   

| ID | Fitur | Status | Catatan |
| :---- | :---- | :---- | :---- |
| F1  | Input periode laporan, info laporan, dan tombol lihat pratinjau laporan | Must  | Format medical report untuk ekspor PDF: A4, 2 halaman inti, lampiran log di halaman 3 (opsional), 11 bagian (A sampai K), footer di tiap halaman  |
| F2 | Ekspor PDF  | Must  |  |

   

