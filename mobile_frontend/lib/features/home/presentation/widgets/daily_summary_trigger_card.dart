import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/daily_log_models.dart';
import 'daily_summary_card_shell.dart';
import 'daily_summary_trigger_entry.dart';

class DailySummaryTriggerCard extends StatelessWidget {
  const DailySummaryTriggerCard({this.response, super.key});

  final DailyLogResponse? response;

  @override
  Widget build(BuildContext context) {
    final result = response ?? DailyLogResponse.demo();
    final entries = _displayEntries(result.aiTriggerAnalysis);
    return DailySummaryCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pemicu Berkaitan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  result.analysisSource == 'fallback'
                      ? 'Analisis fallback'
                      : 'Dianalisis AI',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Korelasi sensoris & catatan\nmakanan'),
          const SizedBox(height: 14),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text('Belum ada pemicu yang dapat dianalisis.'),
            )
          else
            for (final entry in entries)
              DailySummaryTriggerEntry(
                emoji: _emojiFor(entry['pemicu']?.toString()),
                title: entry['pemicu']?.toString() ?? 'Pemicu',
                description:
                    entry['penjelasan_korelasi']?.toString() ??
                    'Data tersimpan dan menunggu analisis lanjutan.',
              ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _displayEntries(
    List<Map<String, dynamic>> source,
  ) {
    final entries = <Map<String, dynamic>>[];
    for (final entry in source) {
      final title = entry['pemicu']?.toString() ?? 'Pemicu';
      final names = title
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty);
      for (final name in names) {
        entries.add({...entry, 'pemicu': name});
      }
    }
    return entries;
  }

  String _emojiFor(String? trigger) {
    final value = trigger?.toLowerCase() ?? '';
    if (value.contains('pedas')) return '🌶️';
    if (value.contains('kafein')) return '☕';
    if (value.contains('asam')) return '🍋';
    if (value.contains('soda')) return '🥤';
    if (value.contains('lemak') || value.contains('goreng')) return '🍟';
    return 'ℹ️';
  }
}
