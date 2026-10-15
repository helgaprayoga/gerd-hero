import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/analytics_models.dart';
import 'history_detail_card_shell.dart';

class AnalyticsSummaryCard extends StatelessWidget {
  const AnalyticsSummaryCard({required this.data, super.key});

  final AnalyticsData data;

  @override
  Widget build(BuildContext context) => HistoryDetailCardShell(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Ringkasan Periode',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            Chip(
              label: Text(
                data.aiAnalysis.source == 'fallback'
                    ? 'Ringkasan'
                    : 'Dianalisis AI',
                style: const TextStyle(color: AppColors.primary, fontSize: 11),
              ),
              backgroundColor: AppColors.surfaceContainerLow,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (data.aiAnalysis.summaryPoints.isEmpty)
          const _Insight(text: 'Belum ada ringkasan untuk periode ini.')
        else
          for (final point in data.aiAnalysis.summaryPoints)
            _Insight(text: point),
      ],
    ),
  );
}

class _Insight extends StatelessWidget {
  const _Insight({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
              height: 1.63,
            ),
          ),
        ),
      ],
    ),
  );
}
