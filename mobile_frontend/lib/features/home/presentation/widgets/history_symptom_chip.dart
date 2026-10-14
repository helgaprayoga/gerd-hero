import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HistorySymptomChip extends StatelessWidget {
  const HistorySymptomChip({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: AppColors.onSurfaceVariant,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
