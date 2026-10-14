import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/pill_badge.dart';

class DisclaimerFlowIndicator extends StatelessWidget {
  const DisclaimerFlowIndicator({super.key});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const PillBadge(
        label: 'Langkah Awal',
        backgroundColor: AppColors.surfaceContainer,
        foregroundColor: AppColors.primary,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shadow: false,
      ),
      Text(
        'Pemberitahuan Medis',
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: AppColors.secondary),
      ),
    ],
  );
}
