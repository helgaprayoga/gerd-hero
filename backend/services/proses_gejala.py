from enums import Gejala


gejala_dict = {
    Gejala.HEARTBURN.value: 0.6,
    Gejala.REGURGITASI.value: 0.7,
    Gejala.NYERI_DADA.value: 0.8,
    Gejala.KESULITAN_MENELAN.value: 0.6,
    Gejala.KEMBUNG_GAS.value: 0.4,
    Gejala.SUARA_SERAK.value: 0.2,
    Gejala.KERINGAT_DINGIN.value: 0.4,
    Gejala.KRAM_PERUT.value: 0.3,
    Gejala.KETIDAKNYAMANAN_TENGGOROKAN.value: 0.4,
}

def hitung_skor_gerd(inputs, weights):
    cf_total = 0.0
    for gejala, selected in inputs.items():
        if selected == 1 and gejala in weights:
            cf_gejala = weights[gejala]
            # Combined CF Formula: CF_combined = CF1 + CF2 * (1 - CF1)
            cf_total = cf_total + cf_gejala * (1 - cf_total)
    return cf_total
