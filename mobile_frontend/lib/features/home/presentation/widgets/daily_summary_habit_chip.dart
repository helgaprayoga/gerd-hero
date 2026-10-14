import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class DailySummaryHabitChip extends StatelessWidget {
  const DailySummaryHabitChip({
    required this.emoji,
    required this.label,
    super.key,
  });

  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) => Chip(
    avatar: Text(emoji, style: const TextStyle(fontSize: 17)),
    label: Text(label),
    padding: const EdgeInsets.symmetric(horizontal: 4),
    backgroundColor: AppColors.surfaceContainerLow,
    side: BorderSide.none,
  );
}
