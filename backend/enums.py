from enum import Enum


class Gejala(str, Enum):
    HEARTBURN = "Heartburn"
    REGURGITASI = "Regurgitasi"
    NYERI_DADA = "Nyeri dada"
    KESULITAN_MENELAN = "Kesulitan menelan"
    KEMBUNG_GAS = "Kembung & gas"
    SUARA_SERAK = "Suara serak"
    KERINGAT_DINGIN = "Keringat dingin"
    KRAM_PERUT = "Kram perut"
    KETIDAKNYAMANAN_TENGGOROKAN = "Ketidaknyamanan tenggorokan"


class Pemicu(str, Enum):
    PEDAS = "Pedas"
    BERLEMAK_GORENGAN = "Berlemak/gorengan"
    ASAM = "Asam"
    BERKAFEIN = "Berkafein"
    BERSODA = "Bersoda"


class StatusObat(str, Enum):
    YA = "ya"
    TIDAK = "tidak"


class HasilEvaluasiGERDQ(str, Enum):
    TIDAK_MUNGKIN_GERD = "Kemungkinan tidak menderita GERD"
    MUNGKIN_GERD = "Kemungkinan menderita GERD"


class StatusKonsistensi(str, Enum):
    BELUM_TERSEDIA = "belum tersedia"
    KONSISTEN = "konsisten"
    TIDAK_KONSISTEN = "tidak konsisten"
