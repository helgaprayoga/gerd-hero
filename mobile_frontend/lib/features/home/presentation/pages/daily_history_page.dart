import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/navigation/slide_page_route.dart';
import '../../data/models/daily_log_models.dart';
import '../../data/repositories/daily_log_repository.dart';
import '../models/daily_history_entry.dart';
import '../widgets/history_day_card.dart';
import '../widgets/history_empty_card.dart';
import '../widgets/history_week_selector.dart';
import '../widgets/history_loading_skeleton.dart';
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
  List<DailyHistoryLog> _logs = const [];

  @override
  void initState() {
    super.initState();
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
    if (!_hasSession && widget.repository == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final logs = await (widget.repository ?? DailyLogRepository()).fetchWeek(
        _isoWeek(_weekStart),
      );
      debugPrint('Riwayat: ${logs.length} log diterima dari API.');
      if (mounted) {
        setState(() {
          _logs = logs;
          _errorMessage = null;
        });
      }
    } catch (error, stackTrace) {
      debugPrint('Riwayat: gagal mengambil data: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          _logs = const [];
          _errorMessage = error.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  String _isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  DailyHistoryLog? _logByDate(String iso) {
    for (final log in _logs) {
      if (log.date == iso) return log;
    }
    return null;
  }

  List<DailyHistoryEntry> _buildDayEntries() {
    final today = _dateOnly(DateTime.now());
    final entries = <DailyHistoryEntry>[];
    for (var i = 6; i >= 0; i--) {
      final date = _weekStart.add(Duration(days: i));
      if (date.isAfter(today)) continue;
      final iso = _isoDate(date);
      final log = _logByDate(iso);
      if (log != null) {
        try {
          entries.add(_toEntry(log));
        } catch (error, stackTrace) {
          debugPrint('Riwayat: item log tidak valid: $error');
          debugPrintStack(stackTrace: stackTrace);
        }
      } else {
        entries.add(
          DailyHistoryEntry(
            day: _dayName(date.weekday),
            date: '${date.day} ${_monthName(date.month)}',
            dateIso: iso,
            isEmpty: true,
          ),
        );
      }
    }
    return entries;
  }

  Future<void> _openBackfill(DailyHistoryEntry entry) async {
    final navigator = Navigator.of(context);
    final date = DateTime.tryParse(entry.dateIso ?? '');
    await navigator.push(
      SlidePageRoute<void>(
        builder: (_) => DailyLogStepOnePage(
          dateLabel: '${entry.day}, ${entry.date}',
          logDate: date,
          finishLabel: 'Kembali ke Riwayat',
          onFinish: () =>
              navigator.popUntil((route) => route.settings.name == '/riwayat'),
        ),
        begin: const Offset(1, 0),
      ),
    );
    if (mounted) _loadEntries();
  }

  DailyHistoryEntry _toEntry(DailyHistoryLog log) {
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
        .where((entry) => _isActiveTrigger(entry.value))
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

  bool _isActiveTrigger(dynamic value) =>
      value == true ||
      value == 1 ||
      value.toString().toLowerCase() == 'true' ||
      value.toString() == '1';

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
              ? const HistoryLoadingSkeleton()
              : _errorMessage != null
              ? _HistoryErrorState(
                  message: _errorMessage!,
                  onRetry: _loadEntries,
                )
              : _DayList(
                  entries: _buildDayEntries(),
                  repository: widget.repository,
                  onBackfill: _openBackfill,
                ),
        ),
      ],
    ),
  );
}

class _DayList extends StatelessWidget {
  const _DayList({
    required this.entries,
    required this.repository,
    required this.onBackfill,
  });

  final List<DailyHistoryEntry> entries;
  final DailyLogRepository? repository;
  final ValueChanged<DailyHistoryEntry> onBackfill;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
    itemCount: entries.length,
    separatorBuilder: (_, index) => const SizedBox(height: 12),
    itemBuilder: (_, index) {
      final entry = entries[index];
      return entry.isEmpty
          ? HistoryEmptyCard(
              day: entry.day,
              date: entry.date,
              onFill: () => onBackfill(entry),
            )
          : HistoryDayCard(entry: entry, repository: repository);
    },
  );
}

class _HistoryErrorState extends StatelessWidget {
  const _HistoryErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            color: AppColors.secondary,
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Coba Lagi'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              shape: const StadiumBorder(),
            ),
          ),
        ],
      ),
    ),
  );
}
