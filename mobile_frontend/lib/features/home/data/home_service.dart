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

    final results = await Future.wait([
      _loadLatestGerdq(),
      ApiService.instance.get('/api/logs?week=$week'),
    ]);

    final logsResponse = results[1] as Map<String, dynamic>;
    final rawLogs = logsResponse['data'];
    final logs = rawLogs is List
        ? rawLogs
              .whereType<Map>()
              .map(
                (row) => HomeDailyLog.fromJson(Map<String, dynamic>.from(row)),
              )
              .toList(growable: false)
        : const <HomeDailyLog>[];

    return HomeDashboardData(
      profile: profile,
      latestGerdq: results[0] as HomeGerdqData?,
      weeklyLogs: logs,
    );
  }

  Future<HomeGerdqData?> _loadLatestGerdq() async {
    try {
      final response = await ApiService.instance.get('/api/gerdq/latest');
      final data = response['data'];
      return data is Map
          ? HomeGerdqData.fromJson(Map<String, dynamic>.from(data))
          : null;
    } on ApiException catch (error) {
      if (error.statusCode == 404) return null;
      rethrow;
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
