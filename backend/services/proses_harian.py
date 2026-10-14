from datetime import datetime

from enums import Pemicu, StatusKonsistensi


PEMICU_IRITAN = (
    Pemicu.PEDAS.value,
    Pemicu.BERLEMAK_GORENGAN.value,
    Pemicu.ASAM.value,
    Pemicu.BERKAFEIN.value,
    Pemicu.BERSODA.value,
)


def _waktu_ke_menit(waktu):
    """Convert an HH:MM value to minutes after midnight."""
    if not isinstance(waktu, str):
        raise ValueError("waktu harus berupa string dengan format HH:MM")

    try:
        parsed = datetime.strptime(waktu, "%H:%M")
    except ValueError as error:
        raise ValueError("waktu harus menggunakan format HH:MM") from error

    return parsed.hour * 60 + parsed.minute


def hitung_konsistensi_frekuensi(frekuensi_hari_ini, frekuensi_hari_kemarin):
    """Return 1/0, or None when there is no previous-day comparison."""
    if frekuensi_hari_kemarin is None:
        return None
    return int(frekuensi_hari_ini == frekuensi_hari_kemarin)


def hitung_konsistensi_jam_makan(
    jam_makan_hari_ini,
    jam_makan_hari_kemarin,
    toleransi_menit=60,
):
    """Compare each meal at the same index with a +/- 60 minute tolerance."""
    if jam_makan_hari_kemarin is None:
        return {
            "nilai": None,
            "makan_dibandingkan": 0,
            "makan_konsisten": 0,
        }

    if len(jam_makan_hari_ini) != len(jam_makan_hari_kemarin):
        return {
            "nilai": 0,
            "makan_dibandingkan": min(
                len(jam_makan_hari_ini), len(jam_makan_hari_kemarin)
            ),
            "makan_konsisten": 0,
        }

    selisih = [
        abs(_waktu_ke_menit(hari_ini) - _waktu_ke_menit(hari_kemarin))
        for hari_ini, hari_kemarin in zip(
            jam_makan_hari_ini, jam_makan_hari_kemarin
        )
    ]
    konsisten = all(nilai <= toleransi_menit for nilai in selisih)

    return {
        "nilai": int(konsisten),
        "makan_dibandingkan": len(jam_makan_hari_ini),
        "makan_konsisten": sum(nilai <= toleransi_menit for nilai in selisih),
    }


def hitung_jeda_makan_tidur(jam_makan, jam_tidur):
    """Calculate the gap between the last meal and sleep time."""
    if not jam_makan:
        raise ValueError("jam_makan tidak boleh kosong")

    makan_terakhir = _waktu_ke_menit(jam_makan[-1])
    waktu_tidur = _waktu_ke_menit(jam_tidur)
    jeda_menit = waktu_tidur - makan_terakhir

    # Sleep after midnight belongs to the following day.
    if jeda_menit <= 0:
        jeda_menit += 24 * 60

    return {
        "menit": jeda_menit,
        "jam": round(jeda_menit / 60, 2),
        "memenuhi_patokan": jeda_menit >= 120,
        "patokan_minimum_jam": 2,
    }


def hitung_flag_iritan(pemicu):
    """Convert the five yes/no food answers into 1/0 irritant flags."""
    if not isinstance(pemicu, dict):
        raise ValueError("pemicu harus berupa object")

    unknown = [nama for nama in pemicu if nama not in PEMICU_IRITAN]
    missing = [nama for nama in PEMICU_IRITAN if nama not in pemicu]
    if unknown or missing:
        raise ValueError(
            "pemicu harus berisi tepat lima field: "
            + ", ".join(PEMICU_IRITAN)
        )

    invalid = [
        nama
        for nama in PEMICU_IRITAN
        if type(pemicu[nama]) is not int or pemicu[nama] not in (0, 1)
    ]
    if invalid:
        raise ValueError("nilai pemicu harus berupa 0 atau 1")

    return {nama: pemicu[nama] for nama in PEMICU_IRITAN}


def proses_indikator_harian(hari_ini, hari_kemarin=None):
    """Calculate deterministic indicators D2-D5 for a daily log."""
    frekuensi_hari_ini = hari_ini["frekuensi_makan"]
    jam_makan_hari_ini = hari_ini["jam_makan"]
    frekuensi_hari_kemarin = (
        hari_kemarin.get("frekuensi_makan")
        if hari_kemarin is not None
        else None
    )
    jam_makan_hari_kemarin = (
        hari_kemarin.get("jam_makan")
        if hari_kemarin is not None
        else None
    )

    konsistensi_frekuensi = hitung_konsistensi_frekuensi(
        frekuensi_hari_ini,
        frekuensi_hari_kemarin,
    )
    konsistensi_jam = hitung_konsistensi_jam_makan(
        jam_makan_hari_ini,
        jam_makan_hari_kemarin,
    )
    if konsistensi_frekuensi is None:
        frekuensi_status = StatusKonsistensi.BELUM_TERSEDIA.value
    else:
        frekuensi_status = (
            StatusKonsistensi.KONSISTEN.value
            if konsistensi_frekuensi
            else StatusKonsistensi.TIDAK_KONSISTEN.value
        )
    if konsistensi_jam["nilai"] is None:
        jam_status = StatusKonsistensi.BELUM_TERSEDIA.value
    else:
        jam_status = (
            StatusKonsistensi.KONSISTEN.value
            if konsistensi_jam["nilai"]
            else StatusKonsistensi.TIDAK_KONSISTEN.value
        )

    return {
        "konsistensi_frekuensi_makan": {
            "nilai": konsistensi_frekuensi,
            "status": frekuensi_status,
        },
        "konsistensi_jam_makan": {
            **konsistensi_jam,
            "status": jam_status,
            "toleransi_menit": 60,
        },
        "jeda_makan_tidur": hitung_jeda_makan_tidur(
            jam_makan_hari_ini,
            hari_ini["jam_tidur"],
        ),
        "flag_iritan": hitung_flag_iritan(hari_ini["pemicu"]),
    }
