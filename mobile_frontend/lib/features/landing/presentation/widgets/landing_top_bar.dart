import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/pill_badge.dart';

class LandingTopBar extends StatelessWidget {
  const LandingTopBar({super.key});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: const PillBadge(
              label: 'Panduan Lambung Terpercaya',
              icon: Icons.health_and_safety,
              backgroundColor: AppColors.surfaceContainer,
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                'Versi 1.0.0',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.secondary),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
