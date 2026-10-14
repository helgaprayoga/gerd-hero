import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/navigation/menu_swipe.dart';
import '../../../../core/navigation/slide_page_route.dart';
import '../widgets/analytics_bottom_nav.dart';
import '../widgets/analytics_period_controls.dart';
import '../widgets/analytics_ranked_factors_card.dart';
import '../widgets/analytics_recommendations.dart';
import '../widgets/analytics_summary_card.dart';
import '../widgets/analytics_score_dynamics.dart';
import '../widgets/analytics_trend_card.dart';
import 'home_page.dart';
import 'reports_page.dart';
import '../models/home_scenario.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  bool _monthly = false;
  int _periodOffset = 0;

  String get _periodLabel {
    if (_monthly) return _periodOffset == 0 ? 'Oktober 2026' : 'September 2026';
    return _periodOffset == 0 ? '6 – 12 Okt 2026' : '29 Sep – 5 Okt 2026';
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
                      onMonthlyChanged: (value) => setState(() {
                        _monthly = value;
                        _periodOffset = 0;
                      }),
                      onPrevious: () => setState(() => _periodOffset = -1),
                      onNext: _periodOffset < 0
                          ? () => setState(() => _periodOffset = 0)
                          : null,
                    ),
                    const SizedBox(height: 20),
                    AnalyticsTrendCard(monthly: _monthly),
                    const SizedBox(height: 20),
                    const AnalyticsSummaryCard(),
                    const SizedBox(height: 20),
                    const AnalyticsRankedFactorsCard(),
                    const SizedBox(height: 20),
                    const AnalyticsScoreDynamics(),
                    const SizedBox(height: 20),
                    const AnalyticsRecommendations(),
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
}
