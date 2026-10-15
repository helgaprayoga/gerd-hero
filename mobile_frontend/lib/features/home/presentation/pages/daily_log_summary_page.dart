import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/daily_log_models.dart';
import '../../domain/entities/daily_log_draft.dart';
import '../widgets/daily_summary_attention_callout.dart';
import '../widgets/daily_summary_gerd_card.dart';
import '../widgets/daily_summary_habits_card.dart';
import '../widgets/daily_summary_profile_card.dart';
import '../widgets/daily_summary_trigger_card.dart';
import 'home_page.dart';

class DailyLogSummaryPage extends StatefulWidget {
  const DailyLogSummaryPage({this.response, this.draft, super.key});

  final DailyLogResponse? response;
  final DailyLogDraft? draft;

  @override
  State<DailyLogSummaryPage> createState() => _DailyLogSummaryPageState();
}

class _DailyLogSummaryPageState extends State<DailyLogSummaryPage> {
  void _finish() {
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
                    _dateLabel(widget.draft?.logDate ?? _responseDate),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                DailySummaryGerdCard(response: widget.response),
                const SizedBox(height: 16),
                DailySummaryTriggerCard(response: widget.response),
                const SizedBox(height: 16),
                DailySummaryHabitsCard(response: widget.response),
                const SizedBox(height: 16),
                const DailySummaryProfileCard(),
                const SizedBox(height: 16),
                const DailySummaryAttentionCallout(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _finish,
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

  String _dateLabel(DateTime date) =>
      '${_weekday(date.weekday)}, ${date.day} ${_month(date.month)} ${date.year}';

  String _weekday(int value) => const [
    '',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ][value];

  String _month(int value) => const [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ][value];

  DateTime get _responseDate {
    final value = widget.response?.date;
    return value == null || value.isEmpty
        ? DateTime.now()
        : DateTime.tryParse(value) ?? DateTime.now();
  }
}
