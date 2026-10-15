import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/analytics_models.dart';
import 'history_detail_card_shell.dart';

class AnalyticsAttentionCard extends StatelessWidget {
  const AnalyticsAttentionCard({required this.data, super.key});

  final AnalyticsData data;

  @override
  Widget build(BuildContext context) {
    final attention = data.attention;
    final color = attention.needsAttention
        ? AppColors.error
        : AppColors.primary;
    return HistoryDetailCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.health_and_safety_outlined, color: color, size: 21),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Tingkat Perhatian Komplikasi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  attention.needsAttention
                      ? 'Perlu dipantau'
                      : 'Tidak terdeteksi',
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            data.aiAnalysis.attentionExplanation.isNotEmpty
                ? data.aiAnalysis.attentionExplanation
                : attention.message,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          if (attention.flags.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final flag in attention.flags)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• ${flag.label}: tercatat ${flag.days} hari',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
          ],
          const SizedBox(height: 8),
          const Text(
            'Informasi ini bukan diagnosis. Jika mengalami nyeri dada berat, sesak napas, atau gejala mengkhawatirkan, segera cari bantuan medis.',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 11,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
