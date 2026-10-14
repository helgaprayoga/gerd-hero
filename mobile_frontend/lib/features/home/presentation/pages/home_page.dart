import 'package:flutter/material.dart';

import '../../../../core/navigation/menu_swipe.dart';
import '../../../../core/navigation/slide_page_route.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/onboarding/presentation/pages/gerdq_intro_page.dart';
import '../models/home_scenario.dart';
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

  @override
  void initState() {
    super.initState();
    profile = widget.profile;
    if (profile == null) _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final response = await ApiService.instance.get('/api/profile');
      final rawData = response['data'];
      if (rawData is! Map) return;
      if (mounted) {
        setState(() {
          profile = ProfileData.fromJson(Map<String, dynamic>.from(rawData));
        });
      }
    } catch (_) {
      // Keep the page usable with the local scenario if the profile request
      // fails. The next visit will retry the request.
    }
  }

  Future<void> _openProfileSettings() async {
    await Navigator.of(context).push(
      SlidePageRoute<void>(
        builder: (_) => const ProfileSettingsPage(),
        begin: const Offset(1, 0),
      ),
    );
    if (mounted) _loadProfile();
  }

  bool get hasProfile =>
      profile?.hasBasicProfile ??
      widget.scenario != HomeScenario.profileIncomplete;

  bool get hasLogs => widget.scenario != HomeScenario.emptyData && hasProfile;

  bool get isSymptomatic => widget.scenario == HomeScenario.symptomatic;

  bool get isEvaluationDue => widget.scenario == HomeScenario.evaluationDue;

  bool get shouldShowProfileCard => profile == null
      ? widget.scenario == HomeScenario.profileIncomplete
      : profile!.completion < 1;

  @override
  Widget build(BuildContext context) {
    final displayName = profile?.displayName ?? 'Dion';
    final avatarLabel = profile?.avatarLabel ?? 'DN';
    final completion = profile?.completion ?? 0.4;

    return Scaffold(
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
                        nickname: displayName,
                        avatarLabel: avatarLabel,
                        onProfileTap: _openProfileSettings,
                      ),
                      const SizedBox(height: 18),
                      const HomeStreakBadge(),
                      const SizedBox(height: 16),
                      HomeHeroCard(
                        scenario: widget.scenario,
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
                      ] else if (widget.scenario ==
                          HomeScenario.loggedToday) ...[
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
}
