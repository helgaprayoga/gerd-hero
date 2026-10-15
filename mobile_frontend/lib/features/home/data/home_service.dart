import '../../../../core/services/api_service.dart';
import '../presentation/models/home_dashboard_data.dart';
import '../presentation/models/profile_data.dart';

class HomeService {
  HomeService._();

  static final instance = HomeService._();

  Future<HomeDashboardData> loadDashboard() async {
    final profileResponse = await ApiService.instance.get('/api/profile');
    final rawProfile = profileResponse['data'];
    if (rawProfile is! Map) {
      throw const FormatException('Data profil tidak valid.');
    }

    final profile = ProfileData.fromJson(Map<String, dynamic>.from(rawProfile));
    final week = _currentIsoWeek(DateTime.now());

    final results = await Future.wait<Object?>([
      _loadLatestGerdq(),
      _loadWeeklyLogs(week),
    ]);

    return HomeDashboardData(
      profile: profile,
      latestGerdq: results[0] as HomeGerdqData?,
      weeklyLogs: results[1] as List<HomeDailyLog>,
    );
  }

  Future<List<HomeDailyLog>> _loadWeeklyLogs(String week) async {
    try {
      final response = await ApiService.instance.get('/api/logs?week=$week');
      final rawLogs = response['data'];
      return rawLogs is List
          ? rawLogs
                .whereType<Map>()
                .map(
                  (row) =>
                      HomeDailyLog.fromJson(Map<String, dynamic>.from(row)),
                )
                .toList(growable: false)
          : const <HomeDailyLog>[];
    } catch (_) {
      // Data GERD-Q dan profil tetap dapat tampil walaupun log mingguan gagal.
      return const <HomeDailyLog>[];
    }
  }

  Future<HomeGerdqData?> _loadLatestGerdq() async {
    try {
      final response = await ApiService.instance.get('/api/gerdq/latest');
      final data = response['data'];
      return data is Map
          ? HomeGerdqData.fromJson(Map<String, dynamic>.from(data))
          : null;
    } catch (_) {
      // GERD-Q bersifat independen dari profil dan log mingguan. Jika endpoint
      // gagal, Home tetap menampilkan data lain dan kartu empty state GERD-Q.
      return null;
    }
  }

  String _currentIsoWeek(DateTime date) {
    final thursday = date.add(Duration(days: 4 - date.weekday));
    final firstThursday = DateTime(thursday.year, 1, 4);
    final week =
        1 +
        (thursday
                .difference(
                  firstThursday.subtract(
                    Duration(days: firstThursday.weekday - 1),
                  ),
                )
                .inDays ~/
            7);
    return '${thursday.year}-W${week.toString().padLeft(2, '0')}';
  }
}
