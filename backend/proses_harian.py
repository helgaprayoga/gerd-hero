import requests

def summary(inputmakan, inputpola, inputkondisi, inputobat, gejalas):
    pedas, lemak, asam, kafein, soda = inputmakan
    frekuensi_makan, jam_makan = inputpola
    tingkat_stres, jam_tidur, jam_bangun = inputkondisi
    obat, waktu_konsumsi_obat = inputobat

    # Format data list menjadi string secara otomatis di dalam fungsi
    jam_makan_str = ", ".join(jam_makan) if isinstance(jam_makan, list) else jam_makan
    
    if isinstance(gejalas, list):
        gejala_str = "\n".join([f'    "{g}"' for g in gejalas])
    else:
        gejala_str = gejalas

    prompt = f"""Menganalisis data harian pemicu kesehatan (makanan, minuman, pola makan, tingkat stres, tidur, obat) dan korelasi hubungannya terhadap gejala yang dirasakan, lalu memberikan luaran (output) berformat JSON terstruktur.

    Instructions
    Analisis Pemicu Gejala Harian
    Skill ini digunakan untuk menganalisis data pencatatan harian pemicu kesehatan dan mengorelasikannya dengan gejala yang dialami pengguna. Luaran yang dihasilkan selalu berupa format JSON terstruktur tanpa kode pembungkus berlebih.

    Format Data Masukan (Input)
    Input terdiri dari dua bagian utama:

    PEMICU:

    --- MAKANAN & MINUMAN ---
    - Makanan Pedas (0/1)        : {pedas}
    - Makanan Berlemak/Gorengan (0/1): {lemak}
    - Makanan Asam (0/1)         : {asam}
    - Minuman Berkafein (0/1)    : {kafein}
    - Minuman Bersoda (0/1)     : {soda}

    --- POLA MAKAN ---
    - Frekuensi Makan (kali)    : {frekuensi_makan}
    - Jam Makan                 : {jam_makan_str}

    --- KONDISI & TIDUR ---
    - Tingkat Stres (1-5)       : {tingkat_stres}
    - Jam Tidur Semalam         : {jam_tidur}
    - Jam Bangun                : {jam_bangun}

    --- OBAT ---
    - Konsumsi Obat (0/1)       : {obat}
    - Waktu Konsumsi            : {waktu_konsumsi_obat}

    GEJALA:

    {gejala_str}

    Panduan Analisis Korelasi
    Evaluasi setiap faktor pemicu yang bernilai 1 atau indikator tinggi (seperti Stres >= 3, kurang tidur, dll.).
    Hubungkan pemicu aktif tersebut secara medis/fisiologis dengan gejala yang dirasakan.
    Jika ada pemicu bernilai 1 yang tidak berkorelasi langsung dengan gejala saat ini, tidak perlu dimasukkan ke dalam daftar array pemicu, atau jelaskan dalam ringkasan.
    Jika tidak ada pemicu yang bernilai 1 yang menjelaskan gejala, berikan penjelasan pada ringkasan_analisis bahwa gejala mungkin berasal dari pemicu lain (misal: infeksi, kondisi medis khusus, faktor lingkungan).

    Format Luaran (Output JSON)
    {{
    "analisis_pemicu_gejala": [
        {{
        "pemicu": "[Nama Pemicu]",
        "penjelasan_korelasi": "[Penjelasan singkat korelasi pemicu terhadap gejala yang dialami]"
        }}
    ],
    "ringkasan_analisis": "[Ringkasan umum mengenai korelasi pemicu dan gejala secara keseluruhan]"
    }}
    """

    result = requests.post(
        "http://127.0.0.1:5000/generate",
        json={"prompt": prompt},
    )

    return result.json().get("response")


# --- Contoh Pemanggilan Fungsi ---
if __name__ == "__main__":
    input_makan = [1, 1, 0, 1, 0]
    input_pola = [3, ["07:15", "12:30", "19:00"]]
    input_kondisi = [3, "23:30", "06:00"]
    input_obat = [1, "Sesudah makan"]
    gejala = ["Nyeri dada", "Sulit menelan", "Kembung dan gas"]

    output = summary(input_makan, input_pola, input_kondisi, input_obat, gejala)
    print(output)