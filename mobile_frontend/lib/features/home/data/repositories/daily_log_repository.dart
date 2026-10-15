import '../../../../core/network/api_client.dart';
import '../../domain/entities/daily_log_draft.dart';
import '../models/daily_log_models.dart';

class DailyLogRepository {
  DailyLogRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<DailyLogResponse> createOrUpdate(
    DailyLogDraft draft, {
    bool allowUpdate = false,
  }) async {
    final body = draft.toJson();
    if (allowUpdate) body['allow_update'] = true;
    final response = await _client.post('/api/logs', body: body);
    return DailyLogResponse.fromJson(response);
  }

  Future<List<DailyHistoryLog>> fetchWeek(String week) async {
    final response = await _client.get(
      '/api/logs',
      queryParameters: {'week': week},
    );
    final values = response['data'];
    if (values is! List) return const [];
    return values
        .whereType<Map>()
        .map(
          (item) => DailyHistoryLog.fromData(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<DailyHistoryLog> fetchDate(String date) async {
    final response = await _client.get('/api/logs/$date');
    final value = response['data'];
    if (value is! Map) {
      throw const ApiException('Detail log tidak memiliki data.');
    }
    return DailyHistoryLog.fromData(Map<String, dynamic>.from(value));
  }
}
