import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HomeStreakBadge extends StatelessWidget {
  const HomeStreakBadge({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: AppColors.primaryFixed.withValues(alpha: 0.7)),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.local_fire_department, color: AppColors.tertiary, size: 16),
        SizedBox(width: 6),
        Text(
          '7 hari berturut-turut',
          style: TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
