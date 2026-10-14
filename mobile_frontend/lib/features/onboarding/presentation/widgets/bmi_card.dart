import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class BmiCard extends StatelessWidget {
  const BmiCard({required this.height, required this.weight, super.key});

  final double? height;
  final double? weight;

  @override
  Widget build(BuildContext context) {
    final bmi = height == null || weight == null || height == 0
        ? null
        : weight! / ((height! / 100) * (height! / 100));
    final value = bmi == null
        ? '--'
        : bmi.toStringAsFixed(1).replaceAll('.', ',');
    final status = bmi == null
        ? 'Lengkapi data'
        : bmi < 18.5
        ? 'Berat kurang'
        : bmi < 25
        ? 'Normal'
        : bmi < 30
        ? 'Berat berlebih'
        : 'Obesitas';

    final marker = bmi == null ? 0.5 : ((bmi - 10) / 30).clamp(0.0, 1.0);
    final accent = bmi != null && bmi >= 18.5 && bmi < 25
        ? AppColors.primary
        : AppColors.tertiary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.monitor_weight_outlined,
                  color: AppColors.primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Indeks Massa Tubuh',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.secondary,
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'BMI Kamu: ',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          TextSpan(
                            text: value,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: bmi == null ? AppColors.secondary : accent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) => SizedBox(
              height: 52,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 5,
                    left: 0,
                    right: 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: SizedBox(
                        height: 10,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                color: AppColors.secondaryContainer,
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                color: AppColors.primaryContainer,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                color: AppColors.tertiaryFixedDim,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(color: const Color(0xFFFFDAD6)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: (constraints.maxWidth - 12) * marker,
                    top: 4,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 0,
                    right: 0,
                    top: 26,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '< 18.5',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.secondary,
                          ),
                        ),
                        Text(
                          '18.5 – 24.9 (Ideal)',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '> 25.0',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
