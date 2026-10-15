import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/daily_log_models.dart';
import '../../domain/entities/daily_log_draft.dart';
import '../widgets/daily_summary_gerd_card.dart';
import '../widgets/daily_summary_habits_card.dart';
import '../widgets/daily_summary_profile_card.dart';
import '../widgets/daily_summary_recommendations_card.dart';
import '../widgets/daily_summary_trigger_card.dart';
import '../models/profile_data.dart';
import 'home_page.dart';

class DailyLogSummaryPage extends StatefulWidget {
  const DailyLogSummaryPage({
    this.response,
    this.draft,
    this.initialProfile,
    this.client,
    this.finishLabel = 'Kembali ke Beranda',
    this.onFinish,
    super.key,
  });

  final DailyLogResponse? response;
  final DailyLogDraft? draft;
  final ProfileData? initialProfile;
  final ApiClient? client;
  final String finishLabel;
  final VoidCallback? onFinish;

  @override
  State<DailyLogSummaryPage> createState() => _DailyLogSummaryPageState();
}

class _DailyLogSummaryPageState extends State<DailyLogSummaryPage> {
  ProfileData? _profile;

  @override
  void initState() {
    super.initState();
    _profile = widget.initialProfile;
    if (_profile == null) _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final response = await (widget.client ?? ApiClient()).get('/api/profile');
      final data = response['data'];
      if (!mounted || data is! Map) return;
      setState(() {
        _profile = ProfileData.fromJson(Map<String, dynamic>.from(data));
      });
    } catch (_) {
      // The summary remains usable and displays unavailable profile values.
    }
  }

  void _finish() {
    if (widget.onFinish != null) {
      widget.onFinish!();
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: Scaffold(
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
                  Text(
                    _summaryTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
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
                  DailySummaryProfileCard(
                    profile: _profile,
                    response: widget.response,
                  ),
                  const SizedBox(height: 16),
                  DailySummaryRecommendationsCard(
                    recommendations:
                        widget.response?.recommendations ?? const [],
                  ),
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
                      child: Text(widget.finishLabel),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  String _dateLabel(DateTime date) =>
      '${_weekday(date.weekday)}, ${date.day} ${_month(date.month)} ${date.year}';

  String get _summaryTitle {
    final date = widget.draft?.logDate ?? _responseDate;
    final today = DateTime.now();
    final isToday =
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
    return isToday ? 'Ringkasan Hari Ini' : 'Ringkasan ${_dateLabel(date)}';
  }

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
