import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/analytics_models.dart';
import 'history_detail_card_shell.dart';

class AnalyticsScoreDynamics extends StatelessWidget {
  const AnalyticsScoreDynamics({required this.data, super.key});

  final AnalyticsData data;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dinamika Skor Gejala',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 2),
            Text(
              'Korelasi perilaku terhadap fluktuasi kenyamanan lambung',
              style: TextStyle(color: AppColors.secondary, fontSize: 12),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _DynamicsCard(
        title: 'Faktor Peningkat Refluks',
        badge: 'Pemicu',
        icon: Icons.arrow_upward,
        iconColor: AppColors.error,
        iconBackground: const Color(0xFFFFDAD6),
        factors: data.influencingFactors.increasing,
      ),
      const SizedBox(height: 16),
      _DynamicsCard(
        title: 'Faktor Pereda Refluks',
        badge: 'Protektif',
        icon: Icons.arrow_downward,
        iconColor: AppColors.primary,
        iconBackground: AppColors.surfaceContainerLow,
        factors: data.influencingFactors.protective,
      ),
    ],
  );
}

class _DynamicsCard extends StatelessWidget {
  const _DynamicsCard({
    required this.title,
    required this.badge,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.factors,
  });

  final String title;
  final String badge;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final List<AnalyticsFactor> factors;

  @override
  Widget build(BuildContext context) {
    final maxMagnitude = factors.fold<double>(
      0,
      (maximum, factor) =>
          factor.magnitude > maximum ? factor.magnitude : maximum,
    );
    return HistoryDetailCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (factors.isEmpty)
            const Text(
              'Belum ada perbandingan yang cukup pada periode ini.',
              style: TextStyle(color: AppColors.secondary, fontSize: 13),
            )
          else
            for (final factor in factors.take(5))
              _FactorRow(
                label: factor.name,
                value:
                    '${factor.differencePercentagePoints >= 0 ? '+' : ''}${factor.differencePercentagePoints.toStringAsFixed(0)}% pengaruh',
                progress: maxMagnitude == 0
                    ? 0
                    : factor.magnitude / maxMagnitude,
                color: iconColor,
              ),
        ],
      ),
    );
  }
}

class _FactorRow extends StatelessWidget {
  const _FactorRow({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  final String label;
  final String value;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 12,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: AppColors.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    ),
  );
}
