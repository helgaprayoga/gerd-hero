import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HistoryStatusBadge extends StatelessWidget {
  const HistoryStatusBadge({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
