import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'home_day_bar.dart';

class HomeGerdSummary extends StatelessWidget {
  const HomeGerdSummary({
    required this.isSymptomatic,
    this.onHistoryTap,
    super.key,
  });

  final bool isSymptomatic;
  final VoidCallback? onHistoryTap;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A1F2D2B),
          blurRadius: 20,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GERD Level 7 Hari',
          style: TextStyle(
            color: AppColors.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          '18 Mei – 24 Mei',
          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final entry in [
              ('Sen', '18', false),
              ('Sel', '19', false),
              ('Rab', '20', false),
              ('Kam', '21', isSymptomatic),
              ('Jum', '22', false),
              ('Sab', '23', false),
              ('Min', '24', false),
            ])
              HomeDayBar(day: entry.$1, date: entry.$2, active: entry.$3),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton.icon(
            onPressed: onHistoryTap,
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('Lihat riwayat lengkap'),
          ),
        ),
      ],
    ),
  );
}
