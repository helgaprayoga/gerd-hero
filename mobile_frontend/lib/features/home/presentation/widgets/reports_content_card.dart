import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'history_detail_card_shell.dart';

class ReportsContentCard extends StatelessWidget {
  const ReportsContentCard({super.key});
  static const _items = [
    ('Identitas', Icons.person_outline),
    ('Ringkasan harian', Icons.today_outlined),
    ('Riwayat gejala', Icons.favorite_border),
    ('Skor GERD-Q', Icons.assessment_outlined),
    ('Grafik tren', Icons.show_chart),
    ('Daftar pemicu', Icons.warning_amber_outlined),
    ('Pola makan & tidur', Icons.restaurant_outlined),
    ('Kepatuhan obat', Icons.medication_outlined),
    (
      'Tingkat Perhatian Komplikasi (Clinical Flag)',
      Icons.health_and_safety_outlined,
    ),
  ];
  @override
  Widget build(BuildContext context) => HistoryDetailCardShell(
    child: Column(
      children: [
        for (final item in _items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0C000000),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(item.$2, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.$1,
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
