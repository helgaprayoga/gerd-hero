import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class GerdQProgressCard extends StatelessWidget {
  const GerdQProgressCard({
    required this.currentQuestion,
    required this.totalQuestions,
    super.key,
  });

  final int currentQuestion;
  final int totalQuestions;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'PROGRES KUESIONER',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Soal $currentQuestion dari $totalQuestions',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: currentQuestion / totalQuestions,
            minHeight: 8,
            backgroundColor: AppColors.secondaryContainer,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primaryContainer,
            ),
          ),
        ),
      ],
    ),
  );
}
