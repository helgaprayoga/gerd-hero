import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class GerdQHeartburnInfoCard extends StatelessWidget {
  const GerdQHeartburnInfoCard({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.tertiaryFixed.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.25)),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lightbulb_outline, color: AppColors.tertiary, size: 20),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Heartburn adalah sensasi terbakar di dada yang bisa terasa naik hingga ke tenggorokan.',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}
