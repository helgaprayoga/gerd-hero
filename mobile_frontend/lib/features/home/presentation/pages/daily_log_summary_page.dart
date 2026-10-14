import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/daily_summary_attention_callout.dart';
import '../widgets/daily_summary_gerd_card.dart';
import '../widgets/daily_summary_habits_card.dart';
import '../widgets/daily_summary_profile_card.dart';
import '../widgets/daily_summary_trigger_card.dart';
import 'home_page.dart';

class DailyLogSummaryPage extends StatelessWidget {
  const DailyLogSummaryPage({super.key});

  void _finish(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surface,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Kembali',
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Ringkasan Hari Ini',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    'Rabu, 14 Oktober 2026',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const DailySummaryGerdCard(),
                const SizedBox(height: 16),
                const DailySummaryTriggerCard(),
                const SizedBox(height: 16),
                const DailySummaryHabitsCard(),
                const SizedBox(height: 16),
                const DailySummaryProfileCard(),
                const SizedBox(height: 16),
                const DailySummaryAttentionCallout(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () => _finish(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Selesai • Kembali ke Beranda'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
