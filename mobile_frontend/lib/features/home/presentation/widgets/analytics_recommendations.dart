import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'history_detail_card_shell.dart';

class AnalyticsRecommendations extends StatelessWidget {
  const AnalyticsRecommendations({super.key});
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
        'Langkah terbukti klinis berdasarkan pola mingguanmu',
        style: TextStyle(color: AppColors.secondary, fontSize: 12),
      ),
      const SizedBox(height: 16),
      for (final item in const [
        (
          'Beri jeda 3 jam sebelum tidur',
          'Hindari rebahan segera setelah makan malam untuk mencegah refluks asam nokturnal.',
          Icons.bedtime_outlined,
        ),
        (
          'Batasi kafein setelah pukul 14:00',
          'Ganti kopi sore dengan air jahe hangat atau teh kamomil bebas kafein.',
          Icons.coffee_outlined,
        ),
        (
          'Pertahankan jadwal makan teratur',
          'Bagi konsumsi harian menjadi porsi kecil namun sering.',
          Icons.restaurant_outlined,
        ),
      ])
        HistoryDetailCardShell(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.$3, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.$1,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.$2,
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
