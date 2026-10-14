import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HistoryIndexGauge extends StatelessWidget {
  const HistoryIndexGauge({required this.value, super.key});

  final int value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 72,
    height: 72,
    child: Stack(
      alignment: Alignment.center,
      children: [
        const SizedBox.expand(
          child: CircularProgressIndicator(
            value: 1,
            strokeWidth: 7,
            color: AppColors.surfaceContainerHigh,
          ),
        ),
        SizedBox.expand(
          child: CircularProgressIndicator(
            value: value / 100,
            strokeWidth: 7,
            color: AppColors.primary,
          ),
        ),
        Text(
          '$value%',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}
