import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/mascot.dart';

class GerdQHero extends StatelessWidget {
  const GerdQHero({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 80,
        height: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primaryFixed.withValues(alpha: 0.45),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryFixed),
        ),
        child: const Mascot(animation: AlwaysStoppedAnimation(0)),
      ),
      const SizedBox(height: 12),
      const Text(
        'Kenali kondisi awalmu',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.onSurface,
        ),
      ),
      const SizedBox(height: 4),
      const Text(
        'Sebelum mulai, jawab beberapa pertanyaan singkat tentang keluhan lambungmu. Jawabanmu jadi titik awal pemantauan.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          height: 1.63,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    ],
  );
}
