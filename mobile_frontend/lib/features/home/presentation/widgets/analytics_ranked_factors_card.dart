import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'history_detail_card_shell.dart';

class AnalyticsRankedFactorsCard extends StatelessWidget {
  const AnalyticsRankedFactorsCard({super.key});
  @override
  Widget build(BuildContext context) => HistoryDetailCardShell(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pemicu Teratas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        const Text(
          'Faktor yang kemungkinan memicu gejala',
          style: TextStyle(color: AppColors.secondary, fontSize: 12),
        ),
        const SizedBox(height: 16),
        for (final item in const [
          (
            'Kafein (Kopi & Teh Pekat)',
            '4 dari 7 hari',
            0.57,
            Color(0xFFBA1A1A),
          ),
          (
            'Kurang tidur / Stres padat',
            '3 dari 7 hari',
            0.43,
            Color(0xFFD08800),
          ),
          (
            'Makanan pedas (Cabai & Sambal)',
            '2 dari 7 hari',
            0.29,
            AppColors.primaryContainer,
          ),
        ])
          _Factor(
            name: item.$1,
            count: item.$2,
            progress: item.$3,
            color: item.$4,
          ),
      ],
    ),
  );
}

class _Factor extends StatelessWidget {
  const _Factor({
    required this.name,
    required this.count,
    required this.progress,
    required this.color,
  });
  final String name;
  final String count;
  final double progress;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              count,
              style: const TextStyle(color: AppColors.secondary, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: AppColors.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    ),
  );
}
