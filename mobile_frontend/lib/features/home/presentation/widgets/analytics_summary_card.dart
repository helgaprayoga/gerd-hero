import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'history_detail_card_shell.dart';

class AnalyticsSummaryCard extends StatelessWidget {
  const AnalyticsSummaryCard({super.key});
  @override
  Widget build(BuildContext context) => HistoryDetailCardShell(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ringkasan Periode',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            Chip(
              label: Text(
                'Dianalisis AI',
                style: TextStyle(color: AppColors.primary, fontSize: 11),
              ),
              backgroundColor: AppColors.surfaceContainerLow,
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _Insight(
          text:
              'Pola kambuh mingguan paling tinggi terdeteksi di hari Jumat setelah asupan kafein ganda dan jam lembur kerja.',
        ),
        const _Insight(
          text:
              'Hari Sabtu mencatatkan bebas gejala total sejalan dengan jam makan siang teratur dan hidrasi cukup.',
        ),
        const _Insight(
          text:
              'Kepatuhan jeda tidur lebih dari 3 jam berhasil menekan keluhan refluks nokturnal hingga 35%.',
        ),
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
