import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'daily_summary_card_shell.dart';
import 'daily_summary_trigger_entry.dart';

class DailySummaryTriggerCard extends StatelessWidget {
  const DailySummaryTriggerCard({super.key});

  @override
  Widget build(BuildContext context) => DailySummaryCardShell(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Pemicu Berkaitan',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Dianalisis AI'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Korelasi sensoris & catatan\nmakanan'),
        const SizedBox(height: 14),
        const DailySummaryTriggerEntry(
          emoji: '🌶️',
          title: 'Konsumsi Makanan Pedas',
          description:
              'Berpotensi berkaitan dengan sensasi heartburn\nkarena capsaicin merangsang reseptor mukosa\nlambung dan memperlambat pengosongan\nlambung.',
        ),
        const DailySummaryTriggerEntry(
          emoji: '☕',
          title: 'Minuman Berkafein',
          description:
              'Berpotensi berkaitan dengan regurgitasi asam\nakibat relaksasi sementara sfingter esofagus\nbawah (LES).',
        ),
        const DailySummaryTriggerEntry(
          emoji: '🛌',
          title: 'Waktu Makan Malam & Tidur Dekat',
          subtitle: 'Estimasi selisih waktu: < 2 jam',
          description:
              'Berpotensi berkaitan dengan refluks nokturnal\nkarena posisi berbaring kurang dari 3 jam setelah\nasupan berat.',
        ),
      ],
    ),
  );
}
