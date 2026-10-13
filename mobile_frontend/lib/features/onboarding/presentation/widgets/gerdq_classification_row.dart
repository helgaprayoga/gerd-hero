import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class GerdQClassificationRow extends StatelessWidget {
  const GerdQClassificationRow({
    required this.score,
    required this.label,
    required this.active,
    super.key,
  });

  final String score;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: active
          ? AppColors.surfaceContainerLow
          : AppColors.surfaceContainerHigh.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(8),
      border: active
          ? const Border(left: BorderSide(color: AppColors.primary, width: 4))
          : null,
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            score,
            style: TextStyle(
              color: active ? AppColors.primary : AppColors.secondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 14,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        if (active)
          const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
      ],
    ),
  );
}
