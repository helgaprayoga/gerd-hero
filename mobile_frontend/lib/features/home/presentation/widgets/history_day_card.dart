import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/navigation/slide_page_route.dart';
import '../models/daily_history_entry.dart';
import '../../data/repositories/daily_log_repository.dart';
import 'history_symptom_chip.dart';
import 'history_trigger_box.dart';
import '../pages/daily_history_summary_page.dart';
// The editable DailyHistoryDetailPage route is intentionally disabled for now.
// Keep that page and its widgets for the future edit-history flow.

class HistoryDayCard extends StatelessWidget {
  const HistoryDayCard({required this.entry, this.repository, super.key});

  final DailyHistoryEntry entry;
  final DailyLogRepository? repository;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => Navigator.of(context).push(
        SlidePageRoute<void>(
          builder: (_) =>
              DailyHistorySummaryPage(entry: entry, repository: repository),
          begin: const Offset(1, 0),
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
            Text(
              '${entry.day}, ${entry.date}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Level GERD',
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${entry.index ?? 0}%',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: ((entry.index ?? 0) / 100).clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: AppColors.surfaceContainerHigh,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Gejala yang dialami',
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
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
