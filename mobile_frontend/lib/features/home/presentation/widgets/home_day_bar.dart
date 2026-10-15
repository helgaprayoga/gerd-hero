import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HomeDayBar extends StatelessWidget {
  const HomeDayBar({
    required this.day,
    required this.date,
    required this.gerdLevel,
    required this.hasLog,
    required this.symptomatic,
    super.key,
  });

  final String day;
  final String date;
  final double? gerdLevel;
  final bool hasLog;
  final bool symptomatic;

  @override
  Widget build(BuildContext context) => Container(
    width: 38,
    height: 150,
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: symptomatic ? AppColors.surfaceContainerLow : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: symptomatic ? AppColors.primary : AppColors.secondaryContainer,
        width: symptomatic ? 1.5 : 1,
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          day,
          style: const TextStyle(fontSize: 10, color: AppColors.secondary),
        ),
        Text(
          date,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        Container(
          width: 20,
          height: hasLog ? 20 + ((gerdLevel ?? 0).clamp(0.0, 1.0) * 58) : 20,
          decoration: BoxDecoration(
            color: symptomatic
                ? AppColors.tertiary
                : AppColors.secondaryContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: hasLog
              ? const Icon(Icons.priority_high, color: Colors.white, size: 14)
              : const Center(
                  child: Text(
                    '-',
                    style: TextStyle(color: AppColors.secondary),
                  ),
                ),
        ),
      ],
    ),
  );
}
