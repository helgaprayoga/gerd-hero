import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/pill_badge.dart';

class LandingTopBar extends StatelessWidget {
  const LandingTopBar({super.key});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const PillBadge(
        label: 'Panduan Lambung Terpercaya',
        icon: Icons.health_and_safety,
        backgroundColor: AppColors.surfaceContainer,
      ),
      Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Versi 2.4',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.secondary),
          ),
        ],
      ),
    ],
  );
}
