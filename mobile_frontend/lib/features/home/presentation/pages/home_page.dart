import 'package:flutter/material.dart';

import '../../../../core/navigation/menu_swipe.dart';
import '../../../../core/navigation/slide_page_route.dart';
import '../../data/home_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/onboarding/presentation/pages/gerdq_intro_page.dart';
import '../models/home_scenario.dart';
import '../models/home_dashboard_data.dart';
import '../models/profile_data.dart';
import '../pages/analytics_page.dart';
import '../pages/daily_history_page.dart';
import '../pages/daily_log_step_one_page.dart';
import '../pages/profile_settings_page.dart';
import '../pages/reports_page.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/home_daily_chart.dart';
import '../widgets/home_empty_log_card.dart';
import '../widgets/home_evaluation_card.dart';
import '../widgets/home_gerd_summary.dart';
import '../widgets/home_header.dart';
import '../widgets/home_hero_card.dart';
import '../widgets/home_profile_card.dart';
import '../widgets/home_streak_badge.dart';
import '../widgets/home_today_log_card.dart';
import '../widgets/home_loading_skeleton.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    this.scenario = HomeScenario.profileIncomplete,
    this.profile,
    super.key,
  });

  final HomeScenario scenario;
  final ProfileData? profile;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ProfileData? profile;
  HomeDashboardData? _dashboard;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    profile = widget.profile;
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    if (mounted) setState(() => _isLoadingProfile = true);
    try {
      final dashboard = await HomeService.instance.loadDashboard();
      if (mounted) {
        setState(() {
          _dashboard = dashboard;
          profile = dashboard.profile;
        });
      }
    } catch (_) {
      // Keep the page usable with the local scenario if the profile request
      // fails. The next visit will retry the request.
    } finally {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _openProfileSettings() async {
    await Navigator.of(context).push(
      SlidePageRoute<void>(
        builder: (_) => const ProfileSettingsPage(),
        begin: const Offset(1, 0),
      ),
    );
    if (mounted) _loadDashboard();
  }

  HomeStatus get _status =>
      _dashboard?.status ??
      switch (widget.scenario) {
        HomeScenario.profileIncomplete => HomeStatus.profileIncomplete,
        HomeScenario.emptyData => HomeStatus.noData,
        HomeScenario.loggedToday => HomeStatus.loggedToday,
        HomeScenario.symptomatic => HomeStatus.symptomaticToday,
        HomeScenario.evaluationDue => HomeStatus.evaluationDue,
      };

  bool get hasProfile =>
      _dashboard?.profile.hasBasicProfile ??
      profile?.hasBasicProfile ??
      widget.scenario != HomeScenario.profileIncomplete;

  bool get hasLogs =>
      _dashboard?.weeklyLogs.isNotEmpty ??
      (widget.scenario != HomeScenario.emptyData && hasProfile);

  bool get isSymptomatic => _status == HomeStatus.symptomaticToday;

  bool get isEvaluationDue => _status == HomeStatus.evaluationDue;

  bool get shouldShowProfileCard {
    final currentProfile = _dashboard?.profile ?? profile;
    return currentProfile == null
        ? widget.scenario == HomeScenario.profileIncomplete
        : currentProfile.completion < 1;
  }

  DateTime get _periodStart {
    final today = DateTime.now();
    return DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: today.weekday - 1));
  }

  DateTime get _periodEnd => _periodStart.add(const Duration(days: 6));

  @override
  Widget build(BuildContext context) {
    final displayName = profile?.displayName ?? 'Dion';
    final avatarLabel = profile?.avatarLabel ?? 'DN';
    final completion =
        _dashboard?.profile.completion ?? profile?.completion ?? 0.4;
    final logs = _dashboard?.weeklyLogs ?? const <HomeDailyLog>[];

    return Scaffold(
      backgroundColor: AppColors.surface,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 56),
        child: FloatingActionButton.extended(
          onPressed: _isLoadingProfile
              ? null
              : () => Navigator.of(context).push(
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
                child: _isLoadingProfile
                    ? const HomeLoadingSkeleton()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HomeHeader(
                              nickname: displayName,
                              avatarLabel: avatarLabel,
                              onProfileTap: _openProfileSettings,
                            ),
                            const SizedBox(height: 18),
                            HomeStreakBadge(
                              streakDays:
                                  _dashboard?.streakDays ??
                                  profile?.streakDays ??
                                  0,
                            ),
                            const SizedBox(height: 16),
                            HomeHeroCard(
                              status: _status,
                              onAction: isEvaluationDue
                                  ? () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => const GerdQIntroPage(),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            if (shouldShowProfileCard) ...[
                              HomeProfileCard(
                                completion: completion,
                                onPressed: _openProfileSettings,
                              ),
                              const SizedBox(height: 20),
                            ] else if (!hasLogs) ...[
                              const HomeEmptyLogCard(),
                              const SizedBox(height: 20),
                            ] else if (_status == HomeStatus.loggedToday) ...[
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
                              logs: logs,
                              periodStart: _periodStart,
                              periodEnd: _periodEnd,
                              onHistoryTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const RiwayatLengkapPage(),
                                ),
                              ),
                            ),
                            if (hasLogs || _dashboard?.latestGerdq != null) ...[
                              const SizedBox(height: 20),
                              HomeDailyChart(
                                latestGerdq: _dashboard?.latestGerdq,
                              ),
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
}
