import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_frontend/features/home/presentation/models/home_dashboard_data.dart';
import 'package:mobile_frontend/features/home/presentation/models/profile_data.dart';

void main() {
  test('detects today log even when basic profile is incomplete', () {
    final dashboard = HomeDashboardData(
      profile: ProfileData(lastLogDate: DateTime.now()),
      weeklyLogs: const [],
    );

    expect(dashboard.hasLogToday, isTrue);
    expect(dashboard.status, HomeStatus.profileIncomplete);
  });

  test(
    'detects today log from weekly logs without relying on profile status',
    () {
      final dashboard = HomeDashboardData(
        profile: const ProfileData(),
        weeklyLogs: [
          HomeDailyLog(
            date: DateTime.now(),
            gerdLevel: 0,
            noSymptoms: true,
            symptoms: const [],
            triggers: const {},
          ),
        ],
      );

      expect(dashboard.hasLogToday, isTrue);
    },
  );

  test('does not report a log from yesterday as today log', () {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final dashboard = HomeDashboardData(
      profile: ProfileData(lastLogDate: yesterday),
      weeklyLogs: const [],
    );

    expect(dashboard.hasLogToday, isFalse);
  });

  test('uses first visit state when the user has no log data', () {
    final dashboard = HomeDashboardData(
      profile: const ProfileData(),
      weeklyLogs: const [],
    );

    expect(dashboard.gerdieState, GerdieState.firstVisit);
  });

  test('uses calm state for a symptom-free log', () {
    final dashboard = HomeDashboardData(
      profile: const ProfileData(),
      weeklyLogs: [
        HomeDailyLog(
          date: DateTime.now(),
          gerdLevel: 0,
          noSymptoms: true,
          symptoms: const [],
          triggers: const {},
        ),
      ],
    );

    expect(dashboard.gerdieState, GerdieState.noSymptoms);
  });

  test('uses moderate and high states from today symptom level', () {
    HomeDailyLog log(double level) => HomeDailyLog(
      date: DateTime.now(),
      gerdLevel: level,
      noSymptoms: false,
      symptoms: const ['Heartburn'],
      triggers: const {},
    );

    expect(
      HomeDashboardData(
        profile: const ProfileData(),
        weeklyLogs: [log(0.30)],
      ).gerdieState,
      GerdieState.moderateSymptoms,
    );
    expect(
      HomeDashboardData(
        profile: const ProfileData(),
        weeklyLogs: [log(0.60)],
      ).gerdieState,
      GerdieState.highSymptoms,
    );
  });
}
