import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ReportPreviewDocument extends StatelessWidget {
  const ReportPreviewDocument({required this.data, super.key});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final period = _map(data['period']);
    final profile = _map(data['profile']);
    final summary = _map(data['summary']);
    final gerdq = _map(data['gerdq']);
    final logs = _maps(data['daily_history']);
    return Column(
      children: [
        _ReportCard(
          title: 'A. Identitas Pengguna',
          child: _KeyValueList([
            ('Nama', _value(profile['name'] ?? profile['nickname'])),
            ('Email', _value(profile['email'])),
            ('Tanggal lahir', _value(profile['birth_date'])),
            ('Jenis kelamin', _value(profile['gender'])),
            (
              'Tinggi / berat',
              '${_value(profile['height'])} / ${_value(profile['weight'])}',
            ),
            ('BMI', _value(profile['bmi'])),
          ]),
        ),
        _ReportCard(
          title: 'B. Ringkasan Pemantauan',
          child: _KeyValueList([
            (
              'Periode',
              '${_value(period['start'])} s/d ${_value(period['end'])}',
            ),
            (
              'Hari tercatat',
              '${_value(summary['logged_days'])} / ${_value(period['days'])}',
            ),
            ('Hari bergejala', _value(summary['symptomatic_days'])),
            ('Rata-rata level GERD', _percent(summary['average_gerd_level'])),
            ('Level tertinggi', _percent(summary['maximum_gerd_level'])),
          ]),
        ),
        _ReportCard(
          title: 'C. Riwayat Gejala',
          child: _LogTable(
            logs: logs,
            columns: const ['Tanggal', 'Gejala', 'Level'],
          ),
        ),
        _ReportCard(
          title: 'D. Skor GERD-Q',
          child: _KeyValueList([
            ('Skor', _value(gerdq['score'])),
            ('Hasil', _gerdqResult(gerdq['result'])),
            ('Tanggal', _value(gerdq['created_at'])),
          ]),
        ),
        _ReportCard(
          title: 'E. Pemicu yang Dilaporkan',
          child: _LogTable(
            logs: logs,
            columns: const ['Tanggal', 'Pemicu', 'Gejala'],
          ),
        ),
        _ReportCard(
          title: 'F. Pola Hidup',
          child: _LogTable(
            logs: logs,
            columns: const ['Tanggal', 'Makan', 'Tidur', 'Stres'],
          ),
        ),
        _ReportCard(
          title: 'G. Riwayat & Kebiasaan Harian',
          child: _LogTable(
            logs: logs,
            columns: const ['Tanggal', 'Level', 'Obat'],
          ),
        ),
        _ReportCard(
          title: 'H. Obat & Suplemen',
          child: _LogTable(
            logs: logs,
            columns: const ['Tanggal', 'Obat', 'Digunakan'],
          ),
        ),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 3)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class _KeyValueList extends StatelessWidget {
  const _KeyValueList(this.items);
  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final item in items)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.$1,
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.$2,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

class _LogTable extends StatelessWidget {
  const _LogTable({required this.logs, required this.columns});
  final List<Map<String, dynamic>> logs;
  final List<String> columns;

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const Text(
        'Belum ada data pada periode ini.',
        style: TextStyle(color: AppColors.secondary, fontSize: 12),
      );
    }
    return Column(
      children: logs.map((log) {
        final symptoms = _list(log['symptoms']).join(', ');
        final triggers = _map(
          log['triggers'],
        ).entries.where((e) => e.value == true).map((e) => e.key).join(', ');
        final medications = _list(log['medications']).join(', ');
        final values = [
          _value(log['log_date']),
          columns.contains('Gejala')
              ? _value(symptoms)
              : columns.contains('Pemicu')
              ? _value(triggers)
              : columns.contains('Makan')
              ? _value(log['meal_frequency'])
              : _percent(log['gerd_level']),
          columns.contains('Level')
              ? _percent(log['gerd_level'])
              : columns.contains('Tidur')
              ? _value(log['sleep_duration_minutes'])
              : columns.contains('Stres')
              ? _value(log['stress_level'])
              : _value(medications),
          if (columns.length > 3) _value(log['stress_level']),
        ];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            values.take(columns.length).join('  •  '),
            style: const TextStyle(fontSize: 11),
          ),
        );
      }).toList(),
    );
  }
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
List<dynamic> _list(dynamic value) => value is List ? value : const <dynamic>[];
List<Map<String, dynamic>> _maps(dynamic value) => value is List
    ? value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
    : const <Map<String, dynamic>>[];
String _value(dynamic value) =>
    value == null || value.toString().isEmpty ? '-' : value.toString();
String _percent(dynamic value) =>
    value is num ? '${(value * 100).toStringAsFixed(1)}%' : '-';
String _gerdqResult(dynamic value) => value == 'likely_gerd'
    ? 'Kemungkinan GERD'
    : value == 'no_gerd'
    ? 'Kemungkinan tidak GERD'
    : '-';
