import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HomeDayBar extends StatelessWidget {
  const HomeDayBar({
    required this.day,
    required this.date,
    required this.active,
    super.key,
  });

  final String day;
  final String date;
  final bool active;

  @override
  Widget build(BuildContext context) => Container(
    width: 38,
    height: 150,
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: active ? AppColors.surfaceContainerLow : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: active ? AppColors.primary : AppColors.secondaryContainer,
        width: active ? 1.5 : 1,
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          day,
          style: const TextStyle(fontSize: 10, color: AppColors.secondary),
        ),
        Text(
          date,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        Container(
          width: 20,
          height: active ? 58 : 20,
          decoration: BoxDecoration(
            color: active ? AppColors.tertiary : AppColors.secondaryContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: active
              ? const Icon(Icons.priority_high, color: Colors.white, size: 14)
              : const Center(
                  child: Text(
                    '-',
                    style: TextStyle(color: AppColors.secondary),
                  ),
                ),
        ),
      ],
    ),
  );
}
