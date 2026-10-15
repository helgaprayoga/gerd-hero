import 'package:flutter/material.dart';

import '../../../../core/navigation/menu_swipe.dart';
import '../../../../core/navigation/slide_page_route.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/analytics_service.dart';
import '../../data/models/analytics_models.dart';
import '../models/home_scenario.dart';
import '../widgets/analytics_attention_card.dart';
import '../widgets/analytics_bottom_nav.dart';
import '../widgets/analytics_period_controls.dart';
import '../widgets/analytics_ranked_factors_card.dart';
import '../widgets/analytics_recommendations.dart';
import '../widgets/analytics_score_dynamics.dart';
import '../widgets/analytics_summary_card.dart';
import '../widgets/analytics_trend_card.dart';
import 'home_page.dart';
import 'reports_page.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  bool _monthly = false;
  DateTime _anchor = _dateOnly(DateTime.now());
  AnalyticsData? _data;
  Object? _error;
  bool _loading = true;

  String get _periodType => _monthly ? 'monthly' : 'weekly';

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await AnalyticsService.instance.load(
        period: _periodType,
        anchor: _anchor,
      );
      if (!mounted) return;
      setState(() {
        _data = data;
        _anchor = data.period.start;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  void _changePeriodType(bool monthly) {
    setState(() {
      _monthly = monthly;
      _anchor = _dateOnly(DateTime.now());
    });
    _loadAnalytics();
  }

  void _shiftPeriod(int amount) {
    setState(() {
      _anchor = _monthly
          ? DateTime(_anchor.year, _anchor.month + amount, 1)
          : _anchor.add(Duration(days: amount * 7));
    });
    _loadAnalytics();
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _anchor,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: _monthly ? 'Pilih bulan' : 'Pilih tanggal dalam minggu',
    );
    if (selected == null || !mounted) return;
    setState(() => _anchor = _dateOnly(selected));
    _loadAnalytics();
  }

  bool get _isCurrentPeriod {
    final today = _dateOnly(DateTime.now());
    if (_monthly) {
      return _anchor.year == today.year && _anchor.month == today.month;
    }
    final start = _anchor.subtract(Duration(days: _anchor.weekday - 1));
    final currentStart = today.subtract(Duration(days: today.weekday - 1));
    return _dateOnly(start) == _dateOnly(currentStart);
  }

  String get _periodLabel {
    final data = _data;
    if (data != null) {
      final start = data.period.start;
      final end = data.period.end;
      if (data.period.monthly) {
        return '${_monthName(start.month)} ${start.year}';
      }
      return '${start.day}–${end.day} ${_monthName(end.month)} ${end.year}';
    }
    return _monthly
        ? '${_monthName(_anchor.month)} ${_anchor.year}'
        : 'Memuat periode...';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surface,
    body: MenuSwipe(
      onSwipeLeft: () => Navigator.of(context).pushReplacement(
        SlidePageRoute<void>(
          builder: (_) => const ReportsPage(),
          begin: const Offset(1, 0),
        ),
      ),
      onSwipeRight: () => Navigator.of(context).pushReplacement(
        SlidePageRoute<void>(
          builder: (_) => const HomePage(scenario: HomeScenario.loggedToday),
          begin: const Offset(-1, 0),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Analitik',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pahami pola gejala dan kebiasaanmu',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnalyticsPeriodControls(
                      monthly: _monthly,
                      periodLabel: _periodLabel,
                      onMonthlyChanged: _changePeriodType,
                      onPrevious: () => _shiftPeriod(-1),
                      onNext: _isCurrentPeriod ? null : () => _shiftPeriod(1),
                      onPickDate: _pickDate,
                    ),
                    const SizedBox(height: 20),
                    if (_loading)
                      const _AnalyticsLoading()
                    else if (_error != null)
                      _AnalyticsError(onRetry: _loadAnalytics)
                    else if (_data != null) ...[
                      if (!_data!.hasData) const _AnalyticsEmptyState(),
                      AnalyticsTrendCard(data: _data!),
                      const SizedBox(height: 20),
                      AnalyticsSummaryCard(data: _data!),
                      const SizedBox(height: 20),
                      AnalyticsRankedFactorsCard(data: _data!),
                      const SizedBox(height: 20),
                      AnalyticsScoreDynamics(data: _data!),
                      const SizedBox(height: 20),
                      AnalyticsAttentionCard(data: _data!),
                      const SizedBox(height: 20),
                      AnalyticsRecommendations(data: _data!),
                    ],
                  ],
                ),
              ),
            ),
            AnalyticsBottomNav(
              onHome: () => Navigator.of(context).pushReplacement(
                SlidePageRoute<void>(
                  builder: (_) =>
                      const HomePage(scenario: HomeScenario.loggedToday),
                  begin: const Offset(-1, 0),
                ),
              ),
              onReports: () => Navigator.of(context).pushReplacement(
                SlidePageRoute<void>(
                  builder: (_) => const ReportsPage(),
                  begin: const Offset(1, 0),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static String _monthName(int month) => const [
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
  ][month];
}

class _AnalyticsLoading extends StatelessWidget {
  const _AnalyticsLoading();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 80),
    child: Center(child: CircularProgressIndicator()),
  );
}

class _AnalyticsError extends StatelessWidget {
  const _AnalyticsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            color: AppColors.secondary,
            size: 40,
          ),
          const SizedBox(height: 12),
          const Text(
            'Analitik belum dapat dimuat.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Periksa koneksi lalu coba lagi.',
            style: TextStyle(color: AppColors.secondary),
          ),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    ),
  );
}

class _AnalyticsEmptyState extends StatelessWidget {
  const _AnalyticsEmptyState();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      children: [
        Icon(Icons.info_outline, color: AppColors.primary),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Belum ada log pada periode ini. Isi log harian untuk melihat pola gejalamu.',
          ),
        ),
      ],
    ),
  );
}
