import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/analytics_models.dart';
import 'history_detail_card_shell.dart';

class AnalyticsRankedFactorsCard extends StatelessWidget {
  const AnalyticsRankedFactorsCard({required this.data, super.key});

  final AnalyticsData data;

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
          'Faktor yang kemungkinan memicu gejala pada hari bergejala',
          style: TextStyle(color: AppColors.secondary, fontSize: 12),
        ),
        const SizedBox(height: 16),
        if (data.topTriggers.isEmpty)
          const Text(
            'Belum ada pemicu yang cukup untuk dirangkum pada periode ini.',
            style: TextStyle(color: AppColors.secondary, fontSize: 13),
          )
        else
          for (final item in data.topTriggers.take(5))
            _Factor(
              name: item.name,
              count: '${item.frequency} dari ${item.symptomaticDays} hari',
              progress: (item.percentOfSymptomaticDays / 100).clamp(0.0, 1.0),
              color: item.percentOfSymptomaticDays >= 66
                  ? AppColors.error
                  : item.percentOfSymptomaticDays >= 33
                  ? AppColors.tertiary
                  : AppColors.primaryContainer,
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
