import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class DailySummaryAttentionCallout extends StatelessWidget {
  const DailySummaryAttentionCallout({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.info_outline, color: AppColors.primary),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Perhatian Klinis',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6),
              Text(
                'Gejala seperti nyeri dada atau sesak napas dapat\nberkaitan dengan kondisi lain. Bila memburuk,\nsegera cari bantuan medis.',
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
