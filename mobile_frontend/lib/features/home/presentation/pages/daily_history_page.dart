import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/navigation/slide_page_route.dart';
import '../../data/repositories/daily_log_repository.dart';
import '../models/daily_history_entry.dart';
import '../widgets/history_day_card.dart';
import '../widgets/history_empty_card.dart';
import '../widgets/history_week_selector.dart';
import 'daily_log_step_one_page.dart';

class RiwayatLengkapPage extends StatefulWidget {
  const RiwayatLengkapPage({this.repository, super.key});

  final DailyLogRepository? repository;

  @override
  State<RiwayatLengkapPage> createState() => _RiwayatLengkapPageState();
}

class _RiwayatLengkapPageState extends State<RiwayatLengkapPage> {
  int _weekOffset = 0;
  bool _loading = false;
  String? _errorMessage;
  late List<DailyHistoryEntry> _visibleEntries;

  static const _demoEntries = [
    DailyHistoryEntry(
      day: 'Minggu',
      date: '12 Okt',
      badge: 'HARI INI',
      index: 39,
      symptoms: ['Heartburn', 'Regurgitasi'],
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
      symptoms: ['Kembung & gas', 'Ketidaknyamanan tenggorokan'],
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

  @override
  void initState() {
    super.initState();
    _visibleEntries = _demoEntries;
    _loadEntries();
  }

  bool get _hasSession {
    try {
      return Supabase.instance.client.auth.currentSession != null;
    } on AssertionError {
      return false;
    }
  }

  DateTime get _weekStart {
    final today = DateTime.now();
    final monday = today.subtract(Duration(days: today.weekday - 1));
    return DateTime(
      monday.year,
      monday.month,
      monday.day,
    ).add(Duration(days: _weekOffset * 7));
  }

  String get _weekLabel {
    if (!_hasSession && widget.repository == null) {
      return switch (_weekOffset) {
        0 => '6 – 12 Okt 2026',
        -1 => '29 Sep – 5 Okt 2026',
        _ => '13 – 19 Okt 2026',
      };
    }
    final start = _weekStart;
    final end = start.add(const Duration(days: 6));
    return '${_shortDate(start)} – ${_shortDate(end)}';
  }

  String _shortDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _isoWeek(DateTime date) {
    final thursday = date.add(Duration(days: 4 - date.weekday));
    final firstThursday = DateTime(thursday.year, 1, 4);
    final week =
        1 +
        (thursday
                .difference(
                  firstThursday.subtract(
                    Duration(days: firstThursday.weekday - 1),
                  ),
                )
                .inDays ~/
            7);
    return '${thursday.year}-W${week.toString().padLeft(2, '0')}';
  }

  Future<void> _loadEntries() async {
    if (!_hasSession && widget.repository == null) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final logs = await (widget.repository ?? DailyLogRepository()).fetchWeek(
        _isoWeek(_weekStart),
      );
      final entries = logs.map(_toEntry).toList();
      if (mounted) setState(() => _visibleEntries = entries);
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'Riwayat belum dapat dimuat.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  DailyHistoryEntry _toEntry(dynamic log) {
    final parsed = DateTime.tryParse(log.date) ?? DateTime.now();
    final today = DateTime.now();
    final dateOnly = DateTime(parsed.year, parsed.month, parsed.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    final badge = dateOnly == todayOnly
        ? 'HARI INI'
        : dateOnly == todayOnly.subtract(const Duration(days: 1))
        ? 'Kemarin'
        : null;
    final triggers = log.triggers.entries
        .where((entry) => entry.value == 1 || entry.value == true)
        .map((entry) => '${_triggerEmoji(entry.key)} ${entry.key}')
        .toList();
    return DailyHistoryEntry(
      day: _dayName(parsed.weekday),
      date: '${parsed.day} ${_monthName(parsed.month)}',
      dateIso: log.date,
      badge: badge,
      index: log.index,
      symptoms: log.symptoms.isEmpty ? const ['Tanpa Gejala'] : log.symptoms,
      triggers: triggers,
    );
  }

  String _dayName(int weekday) => const [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ][weekday - 1];

  String _monthName(int month) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ][month - 1];

  String _triggerEmoji(String value) => switch (value) {
    'Pedas' => '🌶️',
    'Berkafein' => '☕',
    'Asam' => '🍋',
    'Bersoda' => '🥤',
    'Berlemak/gorengan' => '🍟',
    _ => '•',
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
          onPrevious: () {
            setState(() => _weekOffset--);
            _loadEntries();
          },
          onNext: () {
            setState(() => _weekOffset++);
            _loadEntries();
          },
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  itemCount: _visibleEntries.isEmpty
                      ? 1
                      : _visibleEntries.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    if (_visibleEntries.isEmpty) {
                      return HistoryEmptyCard(
                        day: 'Belum ada data',
                        date: _weekLabel,
                        onFill: () => Navigator.of(context).push(
                          SlidePageRoute<void>(
                            builder: (_) => const DailyLogStepOnePage(
                              dateLabel: 'tanggal ini',
                            ),
                            begin: const Offset(1, 0),
                          ),
                        ),
                      );
                    }
                    final entry = _visibleEntries[index];
                    return entry.isEmpty
                        ? HistoryEmptyCard(
                            day: entry.day,
                            date: entry.date,
                            onFill: () => Navigator.of(context).push(
                              SlidePageRoute<void>(
                                builder: (_) =>
                                    DailyLogStepOnePage(dateLabel: entry.date),
                                begin: const Offset(1, 0),
                              ),
                            ),
                          )
                        : HistoryDayCard(
                            entry: entry,
                            repository: widget.repository,
                          );
                  },
                ),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
      ],
    ),
  );
}
