import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class GerdQQuestionInfoCard extends StatelessWidget {
  const GerdQQuestionInfoCard({required this.info, super.key});

  final String info;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.tertiaryFixed.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.25)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.lightbulb_outline,
          color: AppColors.tertiary,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            info,
            style: const TextStyle(
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
