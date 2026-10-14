import 'package:flutter/material.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/daily_log_service.dart';
import '../models/daily_log_draft.dart';
import '../widgets/daily_summary_attention_callout.dart';
import '../widgets/daily_summary_gerd_card.dart';
import '../widgets/daily_summary_habits_card.dart';
import '../widgets/daily_summary_profile_card.dart';
import '../widgets/daily_summary_trigger_card.dart';
import 'home_page.dart';

class DailyLogSummaryPage extends StatefulWidget {
  const DailyLogSummaryPage({this.draft, super.key});

  final DailyLogDraft? draft;

  @override
  State<DailyLogSummaryPage> createState() => _DailyLogSummaryPageState();
}

class _DailyLogSummaryPageState extends State<DailyLogSummaryPage> {
  late final DailyLogDraft _draft;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _draft = widget.draft ?? DailyLogDraft();
  }

  Future<void> _finish() async {
    if (_isSubmitting) return;

    // Summary yang dibuka dari prototype/detail lama tidak memiliki draft.
    // Alur Daily Log baru selalu membawa draft dan menyimpannya ke backend.
    if (widget.draft == null) {
      _goHome();
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await DailyLogService.instance.submit(_draft);
      if (!mounted) return;
      _goHome();
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat menyimpan log harian.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _goHome() {
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
                    _dateLabel(_draft.logDate),
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
                    onPressed: _isSubmitting ? null : _finish,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: const StadiumBorder(),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Selesai • Kembali ke Beranda'),
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
}
