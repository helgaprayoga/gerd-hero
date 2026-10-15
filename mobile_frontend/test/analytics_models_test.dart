import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_frontend/features/home/data/models/analytics_models.dart';

void main() {
  test('parses the analytics response contract', () {
    final data = AnalyticsData.fromJson({
      'period': {
        'type': 'weekly',
        'start': '2026-10-05',
        'end': '2026-10-11',
      },
      'trend': [
        {'tanggal': '2026-10-05', 'gerd_level': 0.72},
      ],
      'top_triggers': [
        {
          'pemicu': 'kafein',
          'frekuensi': 2,
          'total_hari_bergejala': 3,
          'persen_hari_bergejala': 66.67,
        },
      ],
      'influencing_factors': {
        'menaikkan': [
          {'faktor': 'stres', 'selisih': 0.18},
        ],
        'menurunkan': [],
      },
      'complication_attention': {
        'level': 'perlu_diperhatikan',
        'flags': [
          {'label': 'Nyeri dada', 'jumlah_hari': 1},
        ],
        'message': 'Pantau gejala.',
      },
      'ai_analysis': {
        'summary_points': ['Satu', 'Dua', 'Tiga'],
        'attention_explanation': 'Perhatikan pola.',
        'recommendations': [
          {'judul': 'Jeda makan', 'penjelasan': 'Beri jeda sebelum tidur.'},
        ],
        'analysis_source': 'llm',
      },
      'log_count': 4,
      'symptomatic_day_count': 3,
      'cached': true,
    });

    expect(data.period.type, 'weekly');
    expect(data.trend.single.level, 0.72);
    expect(data.topTriggers.single.name, 'kafein');
    expect(data.influencingFactors.increasing.single.name, 'stres');
    expect(data.attention.needsAttention, isTrue);
    expect(data.aiAnalysis.summaryPoints, ['Satu', 'Dua', 'Tiga']);
    expect(data.aiAnalysis.recommendations.single.title, 'Jeda makan');
    expect(data.cached, isTrue);
  });
}
