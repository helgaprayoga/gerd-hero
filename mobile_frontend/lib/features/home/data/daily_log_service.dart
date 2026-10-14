import '../../../../core/services/api_service.dart';
import '../presentation/models/daily_log_draft.dart';

class DailyLogService {
  DailyLogService._();

  static final instance = DailyLogService._();

  Future<Map<String, dynamic>> submit(DailyLogDraft draft) async {
    final response = await ApiService.instance.post(
      '/api/logs',
      draft.toPayload(),
    );
    return Map<String, dynamic>.from(response['data'] as Map);
  }
}
