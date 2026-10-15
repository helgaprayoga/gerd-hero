import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/navigation/menu_swipe.dart';
import '../../../../core/navigation/slide_page_route.dart';
import '../models/home_scenario.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/reports_content_card.dart';
import '../widgets/reports_period_selector.dart';
import '../widgets/reports_preview_button.dart';
import 'analytics_page.dart';
import 'home_page.dart';
import 'report_preview_page.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});
  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  int _period = 7;
  DateTimeRange? _customRange;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surface,
    body: MenuSwipe(
      onSwipeRight: () => Navigator.of(context).pushReplacement(
        SlidePageRoute<void>(
          builder: (_) => const AnalyticsPage(),
          begin: const Offset(-1, 0),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Laporan Klinis',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Ringkasan untuk konsultasi dokter',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.description_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Periode data',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ReportsPeriodSelector(
                      selected: _period,
                      onChanged: _selectPeriod,
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Isi laporan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Informasi terstruktur yang disertakan dalam berkas PDF:',
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const ReportsContentCard(),
                    const SizedBox(height: 20),
                    ReportsPreviewButton(
                      onPressed: () => _showPreview(context),
                    ),
                  ],
                ),
              ),
            ),
            HomeBottomNav(
              active: 'Laporan',
              onHome: () => Navigator.of(context).pushReplacement(
                SlidePageRoute<void>(
                  builder: (_) =>
                      const HomePage(scenario: HomeScenario.loggedToday),
                  begin: const Offset(-1, 0),
                ),
              ),
              onAnalytics: () => Navigator.of(context).pushReplacement(
                SlidePageRoute<void>(
                  builder: (_) => const AnalyticsPage(),
                  begin: const Offset(-1, 0),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _selectPeriod(int value) async {
    if (value != 0) {
      setState(() {
        _period = value;
        _customRange = null;
      });
      return;
    }
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customRange,
    );
    if (range != null && mounted) {
      if (range.duration.inDays + 1 > 90) {
        _showError('Periode laporan maksimal 90 hari.');
        return;
      }
      setState(() {
        _period = 0;
        _customRange = range;
      });
    }
  }

  Future<void> _showPreview(BuildContext context) async {
    final end = _period == 0 ? _customRange?.end : DateTime.now();
    if (end == null) {
      _showError('Pilih periode kustom terlebih dahulu.');
      return;
    }
    final start = _period == 0
        ? _customRange!.start
        : end.subtract(Duration(days: _period - 1));
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReportPreviewPage(start: start, end: end),
      ),
    );
  }

  void _showError(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}
