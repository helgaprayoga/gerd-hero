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
}
