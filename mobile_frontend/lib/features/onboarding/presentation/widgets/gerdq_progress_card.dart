import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class GerdQProgressCard extends StatelessWidget {
  const GerdQProgressCard({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PROGRES KUESIONER',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'Soal 1 dari 6',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: const LinearProgressIndicator(
            value: 1 / 6,
            minHeight: 8,
            backgroundColor: AppColors.secondaryContainer,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primaryContainer,
            ),
          ),
        ),
      ],
    ),
  );
}
