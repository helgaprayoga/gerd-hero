import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'gerdq_info_line.dart';

class GerdQInfoCard extends StatelessWidget {
  const GerdQInfoCard({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow.withValues(alpha: 0.80),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yang perlu kamu tahu',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8),
        GerdQInfoLine(
          icon: Icons.timer_outlined,
          text: 'Ada 6 pertanyaan, sekitar 1 menit.',
        ),
        GerdQInfoLine(
          icon: Icons.history,
          text: 'Jawab berdasarkan 7 hari terakhir.',
        ),
        GerdQInfoLine(
          icon: Icons.check_circle_outline,
          text: 'Tidak ada jawaban benar atau salah.',
        ),
      ],
    ),
  );
}
