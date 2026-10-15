import 'package:flutter/material.dart';

import '../../data/models/daily_log_models.dart';
import 'daily_summary_card_shell.dart';
import 'daily_summary_habit_chip.dart';

class DailySummaryHabitsCard extends StatelessWidget {
  const DailySummaryHabitsCard({this.response, super.key});

  final DailyLogResponse? response;

  @override
  Widget build(BuildContext context) {
    final result = response ?? DailyLogResponse.demo();
    final indicators = result.indicators;
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
    final visibleHabits = habits.isEmpty ? ['Pola harian tersimpan'] : habits;
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final habit in visibleHabits)
                DailySummaryHabitChip(emoji: _emojiFor(habit), label: habit),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Pola kebiasaan ini tercatat bersamaan dengan\ntimbulnya rasa tidak nyaman pada catatan harianmu.',
          ),
        ],
      ),
    );
  }

  String _emojiFor(String habit) {
    if (habit.contains('tidur')) return '🌙';
    if (habit.contains('Stres')) return '⚡';
    if (habit.contains('makan')) return '⏰';
    return '✓';
  }
}
