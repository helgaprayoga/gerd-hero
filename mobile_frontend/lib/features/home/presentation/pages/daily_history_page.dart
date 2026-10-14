import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/navigation/slide_page_route.dart';
import '../models/daily_history_entry.dart';
import '../widgets/history_day_card.dart';
import '../widgets/history_empty_card.dart';
import '../widgets/history_week_selector.dart';
import 'daily_log_step_one_page.dart';

class RiwayatLengkapPage extends StatefulWidget {
  const RiwayatLengkapPage({super.key});

  @override
  State<RiwayatLengkapPage> createState() => _RiwayatLengkapPageState();
}

class _RiwayatLengkapPageState extends State<RiwayatLengkapPage> {
  int _weekOffset = 0;

  static const _entries = [
    DailyHistoryEntry(
      day: 'Minggu',
      date: '12 Okt',
      badge: 'HARI INI',
      index: 39,
      symptoms: ['Heartburn', 'Gejala Sementara'],
      triggers: ['🌶️ Pedas', '☕ Kafein'],
    ),
    DailyHistoryEntry(
      day: 'Sabtu',
      date: '11 Okt',
      badge: 'Kemarin',
      index: 0,
      symptoms: ['Tanpa Gejala'],
    ),
    DailyHistoryEntry(
      day: 'Jumat',
      date: '10 Okt',
      index: 52,
      symptoms: ['Heartburn', 'Nyeri dada', 'Suara serak', '+1'],
      triggers: ['🌶️ Pedas', '☕ Kafein'],
    ),
    DailyHistoryEntry(day: 'Kamis', date: '9 Okt', isEmpty: true),
    DailyHistoryEntry(
      day: 'Rabu',
      date: '8 Okt',
      index: 18,
      symptoms: ['Gejala Ringan', 'Kembung & Gas', 'Gejala Sementara'],
      triggers: ['🌶️ Pedas', '☕ Kafein'],
    ),
    DailyHistoryEntry(
      day: 'Senin',
      date: '6 Okt',
      index: 25,
      symptoms: ['Gejala Ringan', 'Ketidaknyamanan tenggorokan'],
      triggers: ['🌶️ Pedas', '☕ Kafein'],
    ),
  ];

  String get _weekLabel => switch (_weekOffset) {
    0 => '6 – 12 Okt 2026',
    -1 => '29 Sep – 5 Okt 2026',
    _ => '13 – 19 Okt 2026',
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surface,
    appBar: AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back),
      ),
      title: const Text(
        'Riwayat Lengkap',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
    ),
    body: Column(
      children: [
        HistoryWeekSelector(
          label: _weekLabel,
          canGoNext: _weekOffset < 0,
          onPrevious: () => setState(() => _weekOffset--),
          onNext: () => setState(() => _weekOffset++),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            itemCount: _weekOffset == 0 ? _entries.length : 1,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (_, index) => _weekOffset == 0
                ? (_entries[index].isEmpty
                      ? HistoryEmptyCard(
                          day: _entries[index].day,
                          date: _entries[index].date,
                          onFill: () => Navigator.of(context).push(
                            SlidePageRoute<void>(
                              builder: (_) => DailyLogStepOnePage(
                                dateLabel: _entries[index].date,
                              ),
                              begin: const Offset(1, 0),
                            ),
                          ),
                        )
                      : HistoryDayCard(entry: _entries[index]))
                : HistoryEmptyCard(
                    day: 'Belum ada data',
                    date: 'minggu ini',
                    onFill: () => Navigator.of(context).push(
                      SlidePageRoute<void>(
                        builder: (_) =>
                            const DailyLogStepOnePage(dateLabel: 'tanggal ini'),
                        begin: const Offset(1, 0),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    ),
  );
}
