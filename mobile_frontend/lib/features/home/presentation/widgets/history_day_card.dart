import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/daily_history_entry.dart';
import 'history_index_gauge.dart';
import 'history_status_badge.dart';
import 'history_symptom_chip.dart';
import 'history_trigger_box.dart';
import '../pages/daily_history_detail_page.dart';

class HistoryDayCard extends StatelessWidget {
  const HistoryDayCard({required this.entry, super.key});

  final DailyHistoryEntry entry;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => DailyHistoryDetailPage(entry: entry),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
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
              children: [
                Expanded(
                  child: Text(
                    '${entry.day}, ${entry.date}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (entry.badge != null)
                  HistoryStatusBadge(label: entry.badge!),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                HistoryIndexGauge(value: entry.index!),
                const SizedBox(width: 14),
                const Text(
                  'Level GERD',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final symptom in entry.symptoms)
                  HistorySymptomChip(label: symptom),
              ],
            ),
            if (entry.triggers.isNotEmpty) ...[
              const SizedBox(height: 14),
              HistoryTriggerBox(triggers: entry.triggers),
            ],
          ],
        ),
      ),
    ),
  );
}
