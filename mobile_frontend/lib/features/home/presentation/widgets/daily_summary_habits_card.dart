import 'package:flutter/material.dart';

import 'daily_summary_card_shell.dart';
import 'daily_summary_habit_chip.dart';

class DailySummaryHabitsCard extends StatelessWidget {
  const DailySummaryHabitsCard({super.key});

  @override
  Widget build(BuildContext context) => DailySummaryCardShell(
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
          children: const [
            DailySummaryHabitChip(
              emoji: '⏰',
              label: 'Jam makan tidak konsisten',
            ),
            DailySummaryHabitChip(
              emoji: '🌙',
              label: 'Jeda makan-tidur pendek',
            ),
            DailySummaryHabitChip(emoji: '⚡', label: 'Stres tinggi'),
            DailySummaryHabitChip(
              emoji: '🏃‍♂️',
              label: 'Kurang jeda gerak pasca-makan',
            ),
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
