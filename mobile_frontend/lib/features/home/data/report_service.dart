import '../../../core/services/api_service.dart';

class ReportService {
  ReportService._();

  static final instance = ReportService._();

  Future<Map<String, dynamic>> preview({
    required DateTime start,
    required DateTime end,
  }) async {
    final response = await ApiService.instance.post('/api/report/preview', {
      'period_start': _date(start),
      'period_end': _date(end),
    });
    final data = response['data'];
    if (data is! Map) throw const FormatException('Data laporan tidak valid.');
    return Map<String, dynamic>.from(data);
  }

  Future<List<int>> previewPdf({
    required DateTime start,
    required DateTime end,
  }) => ApiService.instance.postBytes('/api/report/preview-pdf', {
    'period_start': _date(start),
    'period_end': _date(end),
  });

  Future<Map<String, dynamic>> generate({
    required DateTime start,
    required DateTime end,
  }) async {
    final response = await ApiService.instance.post('/api/report/generate', {
      'period_start': _date(start),
      'period_end': _date(end),
    });
    final data = response['data'];
    if (data is! Map) throw const FormatException('Data ekspor tidak valid.');
    return Map<String, dynamic>.from(data);
  }

  Future<List<int>> download(String reportId) =>
      ApiService.instance.download('/api/report/$reportId/download');

  String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
