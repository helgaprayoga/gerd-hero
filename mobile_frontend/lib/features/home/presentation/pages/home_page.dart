import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/navigation/slide_page_route.dart';
import '../../../../core/navigation/menu_swipe.dart';
import '../../../../features/onboarding/presentation/pages/gerdq_intro_page.dart';
import '../../../../features/onboarding/presentation/pages/profile_page.dart';
import '../models/home_scenario.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/home_daily_chart.dart';
import '../widgets/home_evaluation_card.dart';
import '../widgets/home_header.dart';
import '../widgets/home_streak_badge.dart';
import '../widgets/home_empty_log_card.dart';
import '../widgets/home_hero_card.dart';
import '../widgets/home_profile_card.dart';
import '../widgets/home_gerd_summary.dart';
import '../pages/daily_log_step_one_page.dart';
import '../widgets/home_today_log_card.dart';
import 'daily_history_page.dart';
import 'analytics_page.dart';
import 'reports_page.dart';
import 'profile_settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({this.scenario = HomeScenario.profileIncomplete, super.key});

  final HomeScenario scenario;

  bool get hasProfile => scenario != HomeScenario.profileIncomplete;
  bool get hasLogs => scenario != HomeScenario.emptyData && hasProfile;
  bool get isSymptomatic => scenario == HomeScenario.symptomatic;
  bool get isEvaluationDue => scenario == HomeScenario.evaluationDue;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surface,
    floatingActionButton: Padding(
      padding: const EdgeInsets.only(bottom: 56),
      child: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          SlidePageRoute<void>(
            builder: (_) => const DailyLogStepOnePage(),
            begin: const Offset(0, 1),
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_note),
        label: const Text('Isi Log Harian'),
      ),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    body: MenuSwipe(
      onSwipeLeft: () => Navigator.of(context).pushReplacement(
        SlidePageRoute<void>(
          builder: (_) => const AnalyticsPage(),
          begin: const Offset(1, 0),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeHeader(
                      onProfileTap: () => Navigator.of(context).push(
                        SlidePageRoute<void>(
                          builder: (_) => const ProfileSettingsPage(),
                          begin: const Offset(1, 0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const HomeStreakBadge(),
                    const SizedBox(height: 16),
                    HomeHeroCard(
                      scenario: scenario,
                      onAction: isEvaluationDue
                          ? () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const GerdQIntroPage(),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    if (!hasProfile) ...[
                      HomeProfileCard(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ProfilePage(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ] else if (!hasLogs) ...[
                      const HomeEmptyLogCard(),
                      const SizedBox(height: 20),
                    ] else if (scenario == HomeScenario.loggedToday) ...[
                      const HomeTodayLogCard(),
                      const SizedBox(height: 20),
                    ] else if (isEvaluationDue) ...[
                      HomeEvaluationCard(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const GerdQIntroPage(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    HomeGerdSummary(
                      isSymptomatic: isSymptomatic,
                      onHistoryTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const RiwayatLengkapPage(),
                        ),
                      ),
                    ),
                    if (hasLogs) ...[
                      const SizedBox(height: 20),
                      const HomeDailyChart(),
                    ],
                    const SizedBox(height: 72),
                  ],
                ),
              ),
            ),
            HomeBottomNav(
              onAnalytics: () => Navigator.of(context).push(
                SlidePageRoute<void>(
                  builder: (_) => const AnalyticsPage(),
                  begin: const Offset(1, 0),
                ),
              ),
              onReports: () => Navigator.of(context).push(
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
