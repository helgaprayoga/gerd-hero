import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'history_status_badge.dart';

class HistoryEmptyCard extends StatelessWidget {
  const HistoryEmptyCard({
    required this.day,
    required this.date,
    this.onFill,
    super.key,
  });

  final String day;
  final String date;
  final VoidCallback? onFill;

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
            Expanded(
              child: Text(
                '$day, $date',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _dateStyle,
              ),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: HistoryStatusBadge(label: 'Kosong'),
              ),
            ),
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
        OutlinedButton.icon(
          onPressed: onFill,
          icon: const Icon(Icons.edit_note, size: 17),
          label: const Text('+ Isi Susulan'),
        ),
      ],
    ),
  );
}

const _dateStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w800);
