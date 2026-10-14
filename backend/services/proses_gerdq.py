from enums import HasilEvaluasiGERDQ


def hitung_skor_gerdq(jawaban):
    # Skor pertanyaan positif: Q1, Q2, Q5, Q6 (0->0, 1->1, 2->2, 3->3)
    skor_positif = [0, 1, 2, 3]
    # Skor pertanyaan negatif: Q3, Q4 (0->3, 1->2, 2->1, 3->0)
    skor_negatif = [3, 2, 1, 0]

    total_skor = 0
    for idx, nilai in enumerate(jawaban):
        # Membatasi nilai input agar tetap berada pada rentang opsi 0 sampai 3
        pilihan = min(max(nilai, 0), 3)
        
        if idx in (2, 3):  # Pertanyaan 3 & 4 (nyeri ulu hati dan mual)
            total_skor += skor_negatif[pilihan]
        else:              # Pertanyaan 1, 2, 5, & 6
            total_skor += skor_positif[pilihan]

    if total_skor <= 7:
        evaluasi = HasilEvaluasiGERDQ.TIDAK_MUNGKIN_GERD.value
    else:
        evaluasi = HasilEvaluasiGERDQ.MUNGKIN_GERD.value

    return total_skor, evaluasi
