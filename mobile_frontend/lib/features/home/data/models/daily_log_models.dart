class DailyLogResponse {
  const DailyLogResponse({required this.data});

  final Map<String, dynamic> data;

  factory DailyLogResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return DailyLogResponse(
      data: data is Map<String, dynamic> ? data : <String, dynamic>{},
    );
  }

  factory DailyLogResponse.demo() => DailyLogResponse(
    data: {
      'log_date': '2026-10-14',
      'symptoms': ['Heartburn', 'Regurgitasi'],
      'triggers': {'Pedas': 1, 'Berkafein': 1},
      'meal_frequency': 3,
      'meal_times': ['07:30', '12:30', '19:00'],
      'stress_level': 3,
      'sleep_time': '23:00',
      'wake_time': '06:30',
      'sleep_duration_minutes': 450,
      'took_medication': true,
      'medications': [],
      'gerd_level': 0.39,
      'indicators': {
        'jeda_makan_tidur': {'jam': 4.0},
      },
      'ai_analysis': {
        'analisis_pemicu_gejala': [
          {
            'pemicu': 'Pedas',
            'penjelasan_korelasi':
                'Berpotensi berkaitan dengan sensasi heartburn.',
          },
        ],
        'ringkasan_analisis': 'Data log berhasil disimpan.',
        'rekomendasi': <String>[],
      },
    },
  );

  String get date => data['log_date']?.toString() ?? '';
  double get gerdLevel => _number(data['gerd_level']);
  int get gerdPercent => (gerdLevel * 100).round();
  List<String> get symptoms => _strings(data['symptoms']);
  Map<String, dynamic> get triggers => _map(data['triggers']);
  Map<String, dynamic> get indicators => _map(data['indicators']);
  Map<String, dynamic> get aiAnalysis => _map(data['ai_analysis']);
  String get analysisSource =>
      aiAnalysis['analysis_source']?.toString() ?? 'gemini';
  List<String> get recommendations => _strings(aiAnalysis['rekomendasi']);

  List<Map<String, dynamic>> get aiTriggerAnalysis {
    final values = aiAnalysis['analisis_pemicu_gejala'];
    if (values is! List) return const [];
    return values
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static double _number(dynamic value) => value is num ? value.toDouble() : 0;
  static List<String> _strings(dynamic value) =>
      value is List ? value.map((item) => item.toString()).toList() : const [];
  static Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
}

class DailyHistoryLog {
  const DailyHistoryLog({required this.data});

  factory DailyHistoryLog.fromData(Map<String, dynamic> data) =>
      DailyHistoryLog(data: data);

  final Map<String, dynamic> data;

  String get date => data['log_date']?.toString() ?? '';
  int get index =>
      ((data['gerd_level'] is num)
              ? (data['gerd_level'] as num).toDouble() * 100
              : 0)
          .round();
  List<String> get symptoms => DailyLogResponse._strings(data['symptoms']);
  Map<String, dynamic> get triggers => DailyLogResponse._map(data['triggers']);
}
