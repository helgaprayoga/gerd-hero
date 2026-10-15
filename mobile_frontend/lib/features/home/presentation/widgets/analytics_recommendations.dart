import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/analytics_models.dart';
import 'history_detail_card_shell.dart';

class AnalyticsRecommendations extends StatelessWidget {
  const AnalyticsRecommendations({required this.data, super.key});

  final AnalyticsData data;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Rekomendasi Kebiasaan untukmu',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 2),
      const Text(
        'Langkah praktis berdasarkan pola periode ini',
        style: TextStyle(color: AppColors.secondary, fontSize: 12),
      ),
      const SizedBox(height: 16),
      if (data.aiAnalysis.recommendations.isEmpty)
        const Text('Belum ada rekomendasi untuk periode ini.')
      else
        for (final item in data.aiAnalysis.recommendations)
          HistoryDetailCardShell(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                          height: 1.63,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    ],
  );
}
