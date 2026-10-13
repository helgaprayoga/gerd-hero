import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/mascot.dart';
import '../../../../core/widgets/pill_badge.dart';

class ProfileIntroCard extends StatelessWidget {
  const ProfileIntroCard({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0C000000),
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PillBadge(
                label: 'Langkah Awal',
                backgroundColor: AppColors.surfaceContainerLow,
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                shadow: false,
              ),
              SizedBox(height: 6),
              Text(
                'Data Dasar',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Bantu Gery mengenal profil fisikmu untuk rekomendasi dan perhitungan risiko yang akurat.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primaryFixed.withValues(alpha: 0.40),
            shape: BoxShape.circle,
          ),
          child: const Mascot(animation: AlwaysStoppedAnimation(0)),
        ),
      ],
    ),
  );
}
