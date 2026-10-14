import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'history_detail_card_shell.dart';

class AnalyticsScoreDynamics extends StatelessWidget {
  const AnalyticsScoreDynamics({super.key});

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
      const _DynamicsCard(
        title: 'Faktor Peningkat Refluks',
        badge: 'Pemicu',
        icon: Icons.arrow_upward,
        iconColor: AppColors.error,
        iconBackground: Color(0xFFFFDAD6),
        factors: [
          ('Jeda makan-ke-tidur < 2 jam', '+18% pengaruh', 0.88),
          ('Beban stres kerja kantor tinggi', '+14% pengaruh', 0.68),
          ('Porsi makan berlebih sekali duduk', '+10% pengaruh', 0.48),
        ],
      ),
      const SizedBox(height: 16),
      const _DynamicsCard(
        title: 'Faktor Pereda Refluks',
        badge: 'Protektif',
        icon: Icons.arrow_downward,
        iconColor: AppColors.primary,
        iconBackground: AppColors.surfaceContainerLow,
        factors: [
          ('Minum air hangat & porsi terbagi', '-16% pengaruh', 0.78),
          ('Jalan santai 10 menit pasca-makan', '-12% pengaruh', 0.58),
          ('Kepatuhan antasida/PPI tepat waktu', '-10% pengaruh', 0.48),
        ],
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
  final List<(String, String, double)> factors;

  @override
  Widget build(BuildContext context) => HistoryDetailCardShell(
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
        for (final factor in factors)
          _FactorRow(
            label: factor.$1,
            value: factor.$2,
            progress: factor.$3,
            color: iconColor,
          ),
      ],
    ),
  );
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
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    ),
  );
}
