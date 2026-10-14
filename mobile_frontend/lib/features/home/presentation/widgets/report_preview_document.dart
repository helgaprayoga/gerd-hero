import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ReportPreviewDocument extends StatelessWidget {
  const ReportPreviewDocument({required this.periodDays, super.key});
  final int periodDays;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _DocumentPage(
        children: [
          _DocumentMeta(periodDays: periodDays),
          const _DocumentTitle(text: 'LAPORAN PEMANTAUAN GEJALA GERD'),
          const _SectionTitle(title: 'A. IDENTITAS PENGGUNA'),
          const _InfoGrid(
            items: [
              ('Nama Lengkap', 'Budi Pratama'),
              ('Tanggal Lahir / Usia', '14 Mei 1994 (32 tahun)'),
              ('Jenis Kelamin', 'Laki-laki'),
              ('Tinggi / Berat Badan', '172 cm / 68 kg'),
              ('Indeks Massa Tubuh (BMI)', '23.0 kg/m² (Kategori Normal)'),
            ],
          ),
          const _SectionTitle(title: 'B. RINGKASAN PEMANTAUAN'),
          const Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'Hari tercatat',
                  value: '6 / 7',
                  note: '86%',
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: _Metric(
                  label: 'Hari bergejala',
                  value: '4',
                  note: 'hari',
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: _Metric(
                  label: 'Rata-rata intensitas',
                  value: '34%',
                  note: 'intensitas',
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: _Metric(
                  label: 'Arah tren',
                  value: 'Naik',
                  note: 'vs mgg lalu',
                ),
              ),
            ],
          ),
          const _SectionTitle(title: 'C. RIWAYAT GEJALA'),
          const _ReportTable(
            headers: ['Gejala', 'Jumlah Hari', 'Terakhir'],
            rows: [
              ['Heartburn', '4 dari 6 hari', '12 Okt 2026'],
              ['Regurgitasi', '2 dari 6 hari', '11 Okt 2026'],
              ['Kembung dan gas', '3 dari 6 hari', '12 Okt 2026'],
              ['Nyeri dada', '1 dari 6 hari', '10 Okt 2026'],
            ],
          ),
          const _SectionTitle(title: 'D. SKOR GERD-Q'),
          const _ReportTable(
            headers: [
              'Tanggal',
              'Skor Total',
              'Kesan Pemantauan',
              'Perbandingan',
            ],
            rows: [
              [
                '12 Okt 2026',
                '9 / 18',
                'Kecenderungan refluks aktif',
                '7 -> 9 (+2 poin)',
              ],
            ],
          ),
        ],
      ),
      const SizedBox(height: 20),
      _DocumentPage(
        children: [
          const _DocumentTitle(
            text: 'LAPORAN PEMANTAUAN GEJALA GERD\n(LANJUTAN)',
          ),
          const _SectionTitle(title: 'E. PEMICU YANG DILAPORKAN'),
          const _ReportTable(
            headers: ['Faktor Pemicu Makanan/Minuman', 'Frekuensi Terpapar'],
            rows: [
              ['Berkafein', '3 hari dari 7 hari'],
              ['Pedas', '3 hari dari 7 hari'],
              ['Berlemak / Gorengan', '4 hari dari 7 hari'],
              ['Asam (Jeruk, cuka, tomat)', '2 hari dari 7 hari'],
              ['Bersoda / Minuman berkarbonasi', '1 hari dari 7 hari'],
            ],
          ),
          const _SectionTitle(title: 'F. POLA HIDUP'),
          const _InfoGrid(
            items: [
              ('Konsistensi Frekuensi Makan', '3x sehari (Teratur)'),
              ('Konsistensi Jam Makan', 'Bervariasi (selisih >1 jam)'),
              ('Jeda Makan-Tidur Malam', '2 jam 15 menit (Target >3 jam)'),
              ('Rata-rata Durasi Tidur', '6 jam 45 menit / malam'),
              ('Rata-rata Tingkat Stres', 'Sedang (3 / 5)'),
            ],
          ),
          const _SectionTitle(title: 'G. RIWAYAT & KEBIASAAN HARIAN'),
          const _InfoGrid(
            items: [
              ('Merokok', 'Tidak'),
              ('Konsumsi Alkohol', 'Tidak'),
              ('Kopi per Hari', '1-2 cangkir'),
              ('Pola Aktivitas', 'Reguler (09.00 - 17.00)'),
              (
                'Riwayat Penyakit Terkait',
                'Gastritis episodik (2024), dispepsia fungsional',
              ),
            ],
          ),
          const _SectionTitle(title: 'H. OBAT & SUPLEMEN YANG DIKONSUMSI'),
          const _ReportTable(
            headers: ['Jenis Obat', 'Jadwal Minum', 'Frekuensi Minum'],
            rows: [
              ['Omeprazole 20mg', '1x pagi (ac)', '6 dari 7 hari'],
              ['Antasida Suspensi', 'Bila perlu (PRN)', '2 hari diminum'],
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'SALINAN PASIEN',
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

class _DocumentPage extends StatelessWidget {
  const _DocumentPage({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1E101E1C),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

class _DocumentMeta extends StatelessWidget {
  const _DocumentMeta({required this.periodDays});
  final int periodDays;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(
          Icons.health_and_safety_outlined,
          color: AppColors.primary,
          size: 18,
        ),
      ),
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'No. Laporan: LK-2026-1013-001\nTanggal cetak: 13 Okt 2026\nPeriode: 6–12 Okt 2026 ($periodDays hari)',
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontFamily: 'monospace',
            color: AppColors.onSurfaceVariant,
            fontSize: 9,
            height: 1.6,
          ),
        ),
      ),
    ],
  );
}

class _DocumentTitle extends StatelessWidget {
  const _DocumentTitle({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.onSurface,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.6,
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.26,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          height: 2,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    ),
  );
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.items});
  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFFF9FAFB),
      border: Border.all(color: const Color(0xFFE5E7EB)),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.$1,
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 9,
                  ),
                ),
                Text(
                  item.$2,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.note});
  final String label;
  final String value;
  final String note;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE5E7EB)),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.secondary, fontSize: 8),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          note,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.secondary, fontSize: 8),
        ),
      ],
    ),
  );
}

class _ReportTable extends StatelessWidget {
  const _ReportTable({required this.headers, required this.rows});
  final List<String> headers;
  final List<List<String>> rows;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFE5E7EB)),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Column(
      children: [
        Container(
          color: const Color(0xFFF3F4F6),
          child: Row(
            children: [
              for (final header in headers)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      header,
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        for (final row in rows)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final cell in row)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      cell,
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 9,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    ),
  );
}
