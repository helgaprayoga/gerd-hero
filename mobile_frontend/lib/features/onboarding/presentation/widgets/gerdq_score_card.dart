import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'gerdq_result_mascot.dart';

class GerdQScoreCard extends StatelessWidget {
  const GerdQScoreCard({required this.score, super.key});

  final int score;

  bool get isLikelyGerd => score >= 8;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0C000000),
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: Column(
      children: [
        SizedBox(
          width: 144,
          height: 144,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 144,
                height: 144,
                child: CircularProgressIndicator(
                  value: (score / 18).clamp(0.0, 1.0),
                  strokeWidth: 8,
                  backgroundColor: AppColors.secondaryContainer,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isLikelyGerd ? AppColors.tertiary : AppColors.primary,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'SKOR ANDA',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$score',
                          style: TextStyle(
                            color: isLikelyGerd
                                ? const Color(0xFF835400)
                                : AppColors.primary,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const TextSpan(
                          text: ' / 18',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: isLikelyGerd
                ? AppColors.tertiaryFixed.withValues(alpha: 0.35)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLikelyGerd ? Icons.warning_amber_rounded : Icons.check_circle,
                color: isLikelyGerd ? AppColors.error : AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                isLikelyGerd
                    ? 'Kemungkinan menderita GERD'
                    : 'Kemungkinan tidak menderita GERD',
                style: TextStyle(
                  color: isLikelyGerd ? AppColors.error : AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GerdQResultMascot(isLikelyGerd: isLikelyGerd),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isLikelyGerd
                      ? 'Jangan khawatir, Gerdie siap membantumu memantau pemicu makanan dan gaya hidup sehat mulai hari ini.'
                      : 'Kondisi asam lambungmu cenderung stabil! Tetap jaga jam makan teratur dan pola hidup sehat.',
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
