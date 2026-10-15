import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/daily_log_models.dart';
import '../../data/repositories/daily_log_repository.dart';
import '../models/daily_history_entry.dart';
import 'daily_log_summary_page.dart';

class DailyHistorySummaryPage extends StatefulWidget {
  const DailyHistorySummaryPage({
    required this.entry,
    this.repository,
    super.key,
  });

  final DailyHistoryEntry entry;
  final DailyLogRepository? repository;

  @override
  State<DailyHistorySummaryPage> createState() =>
      _DailyHistorySummaryPageState();
}

class _DailyHistorySummaryPageState extends State<DailyHistorySummaryPage> {
  DailyLogResponse? _response;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final date = widget.entry.dateIso;
    if (date != null && date.isNotEmpty) {
      try {
        final log = await (widget.repository ?? DailyLogRepository()).fetchDate(
          date,
        );
        var data = Map<String, dynamic>.from(log.data);
        final existingAnalysis = data['ai_analysis'];
        if (existingAnalysis is! Map || existingAnalysis.isEmpty) {
          final generated = await (widget.repository ?? DailyLogRepository())
              .generateDailySummary(date);
          data = {...data, ...generated.data};
        }
        if (mounted) setState(() => _response = DailyLogResponse(data: data));
        return;
      } catch (_) {
        // Keep the selected date and card data visible when the detail request fails.
      }
    }
    if (mounted) setState(() => _response = _fallbackResponse());
  }

  DailyLogResponse _fallbackResponse() {
    final triggers = <String, dynamic>{};
    for (final trigger in widget.entry.triggers) {
      final label = trigger.replaceFirst(RegExp(r'^[^\u0000-\u007F]+\s*'), '');
      triggers[label] = 1;
    }
    final date = widget.entry.dateIso ?? _fallbackDate();
    return DailyLogResponse(
      data: {
        'log_date': date,
        'gerd_level': (widget.entry.index ?? 0) / 100,
        'symptoms': widget.entry.symptoms
            .where((item) => item != 'Tanpa Gejala')
            .toList(),
        'triggers': triggers,
        'meal_frequency': 0,
        'meal_times': <String>[],
        'stress_level': 0,
        'sleep_time': '--:--',
        'wake_time': '--:--',
        'took_medication': false,
        'medications': <dynamic>[],
      },
    );
  }

  String _fallbackDate() {
    final match = RegExp(
      r'(\d{1,2})\s+([A-Za-z]+)',
    ).firstMatch(widget.entry.date);
    if (match == null) return DateTime.now().toIso8601String().substring(0, 10);
    const months = <String, int>{
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'Mei': 5,
      'Jun': 6,
      'Jul': 7,
      'Agu': 8,
      'Sep': 9,
      'Okt': 10,
      'Nov': 11,
      'Des': 12,
    };
    final month = months[match.group(2)] ?? DateTime.now().month;
    final date = DateTime(2026, month, int.parse(match.group(1)!));
    return date.toIso8601String().substring(0, 10);
  }

  @override
  Widget build(BuildContext context) {
    final response = _response;
    if (response != null) {
      return DailyLogSummaryPage(
        response: response,
        finishLabel: 'Kembali ke Riwayat',
        onFinish: () => Navigator.of(context).pop(),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          'Ringkasan Harian',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
