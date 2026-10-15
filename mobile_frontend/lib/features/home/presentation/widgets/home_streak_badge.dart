import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HomeStreakBadge extends StatelessWidget {
  const HomeStreakBadge({required this.streakDays, super.key});

  final int streakDays;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: AppColors.primaryFixed.withValues(alpha: 0.7)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.local_fire_department, color: AppColors.tertiary, size: 16),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            streakDays == 0
                ? 'Mulai streak hari ini'
                : '$streakDays hari berturut-turut',
            softWrap: true,
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}
