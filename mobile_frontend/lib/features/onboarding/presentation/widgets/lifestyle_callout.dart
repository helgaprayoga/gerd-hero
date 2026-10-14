import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class LifestyleCallout extends StatelessWidget {
  const LifestyleCallout({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLow,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.spa, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            'GERDHero mendampingi pola makan, jadwal tidur, dan pencatatan pemicu harian agar lambung tetap nyaman beraktivitas.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
      ],
    ),
  );
}
