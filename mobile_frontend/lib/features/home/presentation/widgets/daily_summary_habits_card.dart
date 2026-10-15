import 'package:flutter/material.dart';

import '../../data/models/daily_log_models.dart';
import 'daily_summary_card_shell.dart';
import 'daily_summary_habit_entry.dart';

class DailySummaryHabitsCard extends StatelessWidget {
  const DailySummaryHabitsCard({this.response, super.key});

  final DailyLogResponse? response;

  @override
  Widget build(BuildContext context) {
    final result = response ?? DailyLogResponse.demo();
    final indicators = result.indicators;
    final aiHabits = result.aiHabitAnalysis;
    final habits = <String>[];
    final frequency = indicators['konsistensi_frekuensi_makan'];
    final mealTime = indicators['konsistensi_jam_makan'];
    final gap = indicators['jeda_makan_tidur'];
    if (frequency is Map && frequency['nilai'] == 0) {
      habits.add('Jam makan tidak konsisten');
    }
    if (mealTime is Map && mealTime['nilai'] == 0) {
      habits.add('Waktu makan berubah');
    }
    if (gap is Map && (gap['jam'] is num) && (gap['jam'] as num) < 2) {
      habits.add('Jeda makan-tidur pendek');
    }
    final stress = result.data['stress_level'];
    if (stress is num && stress >= 3) {
      habits.add('Stres sedang/tinggi');
    }
    final entries = aiHabits.isNotEmpty
        ? aiHabits
        : [
            for (final habit in habits)
              {
                'kebiasaan': habit,
                'penjelasan':
                    '$habit tercatat pada log hari ini dan berpotensi '
                    'berkaitan dengan keluhan yang muncul.',
              },
          ];
    return DailySummaryCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kebiasaan yang Mendukung Gejala',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text('Belum ada kebiasaan yang dapat dianalisis.'),
            )
          else
            for (final entry in entries)
              DailySummaryHabitEntry(
                emoji: _emojiFor(entry['kebiasaan']?.toString() ?? ''),
                title: entry['kebiasaan']?.toString() ?? 'Kebiasaan',
                subtitle: _supportingText(entry),
                description: _description(entry),
              ),
        ],
      ),
    );
  }

  String _emojiFor(String habit) {
    final value = habit.toLowerCase();
    if (value.contains('tidur')) return '🌙';
    if (value.contains('stres')) return '⚡';
    if (value.contains('makan')) return '⏰';
    return '✓';
  }

  String? _supportingText(Map<String, dynamic> entry) {
    final value = entry['nilai']?.toString();
    return value == null || value.isEmpty ? null : value;
  }

  String _description(Map<String, dynamic> entry) {
    final explanation = entry['penjelasan']?.toString();
    final evidence = entry['bukti']?.toString();
    if (explanation != null && explanation.isNotEmpty) {
      if (evidence == null || evidence.isEmpty) return explanation;
      return '$evidence\n$explanation';
    }
    if (evidence != null && evidence.isNotEmpty) return evidence;
    return 'Data kebiasaan tercatat pada log hari ini.';
  }
}
