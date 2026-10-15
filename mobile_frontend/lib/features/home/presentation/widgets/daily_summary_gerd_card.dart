import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/daily_log_models.dart';
import 'daily_summary_card_shell.dart';

class DailySummaryGerdCard extends StatelessWidget {
  const DailySummaryGerdCard({this.response, super.key});

  final DailyLogResponse? response;

  @override
  Widget build(BuildContext context) {
    final result = response ?? DailyLogResponse.demo();
    final percent = result.gerdPercent;
    return DailySummaryCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_outline,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Level GERD',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 112,
                height: 112,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: 1,
                        strokeWidth: 10,
                        color: AppColors.surfaceContainerHigh,
                      ),
                    ),
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: percent / 100,
                        strokeWidth: 10,
                        color: AppColors.primary,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$percent%',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        Text(
                          'Indeks',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.trending_down,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        result.indicators.isEmpty
                            ? 'Data hari ini berhasil\ntersimpan di server.'
                            : 'Indikator harian berhasil\ndihitung dari log kamu.',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Indeks ini adalah gambaran pemantauan\nmandiri, bukan diagnosis klinis absolut.',
            ),
          ),
        ],
      ),
    );
  }
}
