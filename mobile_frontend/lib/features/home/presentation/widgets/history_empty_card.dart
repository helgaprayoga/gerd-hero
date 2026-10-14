import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'history_status_badge.dart';

class HistoryEmptyCard extends StatelessWidget {
  const HistoryEmptyCard({required this.day, required this.date, super.key});

  final String day;
  final String date;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A1F2D2B),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$day, $date', style: _dateStyle),
            const HistoryStatusBadge(label: 'Kosong'),
          ],
        ),
        const SizedBox(height: 18),
        const Text(
          'Belum ada catatan harian',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        const Text(
          'Isi catatan untuk memantau kondisi GERD-mu.',
          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
        ),
        const SizedBox(height: 14),
        OutlinedButton(onPressed: () {}, child: const Text('+ Isi Susulan')),
      ],
    ),
  );
}

const _dateStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w800);
