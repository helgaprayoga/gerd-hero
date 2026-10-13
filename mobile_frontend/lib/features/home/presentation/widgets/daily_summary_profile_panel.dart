import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class DailySummaryProfilePanel extends StatelessWidget {
  const DailySummaryProfilePanel({
    required this.label,
    required this.value,
    required this.unit,
    required this.description,
    this.badge = false,
    super.key,
  });

  final String label;
  final String value;
  final String unit;
  final String description;
  final bool badge;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (badge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(unit),
          )
        else
          Text(unit),
        const SizedBox(height: 12),
        Text(description),
      ],
    ),
  );
}
