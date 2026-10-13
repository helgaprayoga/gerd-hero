import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/mascot.dart';
import 'disclaimer_card_text.dart';
import 'disclaimer_surface_card.dart';

class DisclaimerIntroCard extends StatelessWidget {
  const DisclaimerIntroCard({super.key});

  @override
  Widget build(BuildContext context) => DisclaimerSurfaceCard(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: DisclaimerCardText(
            title: 'Sebelum Mulai',
            body:
                'Harap baca dan pahami batasan penggunaan aplikasi ini demi kenyamanan dan keselamatan pemantauan kesehatan lambungmu.',
          ),
        ),
        const SizedBox(width: 16),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: const Mascot(animation: AlwaysStoppedAnimation(0)),
            ),
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 16,
                height: 16,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primaryFixed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  size: 10,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
