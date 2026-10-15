import '../../../../core/services/api_service.dart';
import 'models/analytics_models.dart';

class AnalyticsService {
  AnalyticsService._();

  static final instance = AnalyticsService._();

  Future<AnalyticsData> load({
    required String period,
    required DateTime anchor,
  }) async {
    final date = _dateOnly(anchor);
    final uri = Uri(
      path: '/api/analytics',
      queryParameters: {'period': period, 'date': _formatDate(date)},
    );
    final response = await ApiService.instance.get(uri.toString());
    final rawData = response['data'];
    if (rawData is! Map) {
      throw const FormatException('Data analitik tidak valid.');
    }
    return AnalyticsData.fromJson(Map<String, dynamic>.from(rawData));
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static String _formatDate(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
