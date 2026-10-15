class AnalyticsPeriod {
  const AnalyticsPeriod({
    required this.type,
    required this.start,
    required this.end,
  });

  final String type;
  final DateTime start;
  final DateTime end;

  bool get monthly => type == 'monthly';

  factory AnalyticsPeriod.fromJson(Map<String, dynamic> json) {
    return AnalyticsPeriod(
      type: json['type']?.toString() ?? 'weekly',
      start:
          DateTime.tryParse(json['start']?.toString() ?? '') ?? DateTime.now(),
      end: DateTime.tryParse(json['end']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class AnalyticsTrendPoint {
  const AnalyticsTrendPoint({required this.date, required this.level});

  final DateTime date;
  final double level;

  int get percent => (level * 100).round();

  factory AnalyticsTrendPoint.fromJson(Map<String, dynamic> json) {
    final rawLevel = json['gerd_level'];
    final parsed = rawLevel is num ? rawLevel.toDouble() : 0.0;
    return AnalyticsTrendPoint(
      date:
          DateTime.tryParse(json['tanggal']?.toString() ?? '') ??
          DateTime.now(),
      level: parsed > 1 ? parsed / 100 : parsed,
    );
  }
}

class AnalyticsTrigger {
  const AnalyticsTrigger({
    required this.name,
    required this.frequency,
    required this.symptomaticDays,
    required this.percentOfSymptomaticDays,
  });

  final String name;
  final int frequency;
  final int symptomaticDays;
  final double percentOfSymptomaticDays;

  factory AnalyticsTrigger.fromJson(Map<String, dynamic> json) {
    return AnalyticsTrigger(
      name: json['pemicu']?.toString() ?? 'Tidak diketahui',
      frequency: (json['frekuensi'] as num?)?.toInt() ?? 0,
      symptomaticDays: (json['total_hari_bergejala'] as num?)?.toInt() ?? 0,
      percentOfSymptomaticDays:
          (json['persen_hari_bergejala'] as num?)?.toDouble() ?? 0,
    );
  }
}

class AnalyticsFactor {
  const AnalyticsFactor({
    required this.name,
    required this.activeAverage,
    required this.inactiveAverage,
    required this.difference,
    required this.differencePercentagePoints,
  });

  final String name;
  final double activeAverage;
  final double inactiveAverage;
  final double difference;
  final double differencePercentagePoints;

  double get magnitude => difference.abs();

  factory AnalyticsFactor.fromJson(Map<String, dynamic> json) {
    final difference = (json['selisih'] as num?)?.toDouble() ?? 0;
    return AnalyticsFactor(
      name: json['faktor']?.toString() ?? 'Faktor',
      activeAverage: (json['rata_rata_saat_aktif'] as num?)?.toDouble() ?? 0,
      inactiveAverage:
          (json['rata_rata_saat_tidak_aktif'] as num?)?.toDouble() ?? 0,
      difference: difference,
      differencePercentagePoints:
          (json['selisih_persen_poin'] as num?)?.toDouble() ?? difference * 100,
    );
  }
}

class AnalyticsInfluencingFactors {
  const AnalyticsInfluencingFactors({
    required this.increasing,
    required this.protective,
  });

  final List<AnalyticsFactor> increasing;
  final List<AnalyticsFactor> protective;

  factory AnalyticsInfluencingFactors.fromJson(Map<String, dynamic> json) {
    List<AnalyticsFactor> parse(dynamic value) => value is List
        ? value
              .whereType<Map>()
              .map(
                (item) =>
                    AnalyticsFactor.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList(growable: false)
        : const [];
    return AnalyticsInfluencingFactors(
      increasing: parse(json['menaikkan']),
      protective: parse(json['menurunkan']),
    );
  }
}

class AnalyticsAttentionFlag {
  const AnalyticsAttentionFlag({required this.label, required this.days});

  final String label;
  final int days;

  factory AnalyticsAttentionFlag.fromJson(Map<String, dynamic> json) {
    return AnalyticsAttentionFlag(
      label: json['label']?.toString() ?? 'Gejala perhatian',
      days: (json['jumlah_hari'] as num?)?.toInt() ?? 0,
    );
  }
}

class AnalyticsAttention {
  const AnalyticsAttention({
    required this.level,
    required this.flags,
    required this.message,
  });

  final String level;
  final List<AnalyticsAttentionFlag> flags;
  final String message;

  bool get needsAttention => level == 'perlu_diperhatikan';

  factory AnalyticsAttention.fromJson(Map<String, dynamic> json) {
    final rawFlags = json['flags'];
    return AnalyticsAttention(
      level: json['level']?.toString() ?? 'tidak_terdeteksi',
      flags: rawFlags is List
          ? rawFlags
                .whereType<Map>()
                .map(
                  (item) => AnalyticsAttentionFlag.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList(growable: false)
          : const [],
      message: json['message']?.toString() ?? '',
    );
  }
}

class AnalyticsRecommendation {
  const AnalyticsRecommendation({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  factory AnalyticsRecommendation.fromJson(dynamic value) {
    if (value is Map) {
      return AnalyticsRecommendation(
        title:
            value['judul']?.toString() ??
            value['title']?.toString() ??
            'Rekomendasi',
        description:
            value['penjelasan']?.toString() ??
            value['description']?.toString() ??
            '',
      );
    }
    return AnalyticsRecommendation(
      title: 'Langkah yang bisa dicoba',
      description: value?.toString() ?? '',
    );
  }
}

class AnalyticsAiAnalysis {
  const AnalyticsAiAnalysis({
    required this.summaryPoints,
    required this.attentionExplanation,
    required this.recommendations,
    required this.source,
  });

  final List<String> summaryPoints;
  final String attentionExplanation;
  final List<AnalyticsRecommendation> recommendations;
  final String source;

  factory AnalyticsAiAnalysis.fromJson(Map<String, dynamic> json) {
    final rawPoints = json['summary_points'] ?? json['summary'];
    final rawRecommendations = json['recommendations'] ?? json['rekomendasi'];
    return AnalyticsAiAnalysis(
      summaryPoints: rawPoints is List
          ? rawPoints
                .map((item) => item.toString())
                .where((item) => item.isNotEmpty)
                .take(3)
                .toList()
          : const [],
      attentionExplanation: json['attention_explanation']?.toString() ?? '',
      recommendations: rawRecommendations is List
          ? rawRecommendations
                .map(AnalyticsRecommendation.fromJson)
                .where((item) => item.description.isNotEmpty)
                .toList(growable: false)
          : const [],
      source: json['analysis_source']?.toString() ?? 'llm',
    );
  }
}

class AnalyticsData {
  const AnalyticsData({
    required this.period,
    required this.trend,
    required this.topTriggers,
    required this.influencingFactors,
    required this.attention,
    required this.aiAnalysis,
    required this.logCount,
    required this.symptomaticDayCount,
    required this.cached,
  });

  final AnalyticsPeriod period;
  final List<AnalyticsTrendPoint> trend;
  final List<AnalyticsTrigger> topTriggers;
  final AnalyticsInfluencingFactors influencingFactors;
  final AnalyticsAttention attention;
  final AnalyticsAiAnalysis aiAnalysis;
  final int logCount;
  final int symptomaticDayCount;
  final bool cached;

  bool get hasData => logCount > 0;

  double get averageLevel {
    if (trend.isEmpty) return 0;
    return trend.map((point) => point.level).reduce((a, b) => a + b) /
        trend.length;
  }

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    List<T> parseList<T>(
      dynamic value,
      T Function(Map<String, dynamic>) parser,
    ) {
      return value is List
          ? value
                .whereType<Map>()
                .map((item) => parser(Map<String, dynamic>.from(item)))
                .toList(growable: false)
          : <T>[];
    }

    final rawAi = json['ai_analysis'] is Map
        ? Map<String, dynamic>.from(json['ai_analysis'] as Map)
        : <String, dynamic>{
            'summary': json['summary'],
            'recommendations': json['recommendations'],
          };
    return AnalyticsData(
      period: AnalyticsPeriod.fromJson(
        json['period'] is Map
            ? Map<String, dynamic>.from(json['period'] as Map)
            : const {},
      ),
      trend: parseList(json['trend'], AnalyticsTrendPoint.fromJson),
      topTriggers: parseList(json['top_triggers'], AnalyticsTrigger.fromJson),
      influencingFactors: AnalyticsInfluencingFactors.fromJson(
        json['influencing_factors'] is Map
            ? Map<String, dynamic>.from(json['influencing_factors'] as Map)
            : const {},
      ),
      attention: AnalyticsAttention.fromJson(
        json['complication_attention'] is Map
            ? Map<String, dynamic>.from(json['complication_attention'] as Map)
            : const {},
      ),
      aiAnalysis: AnalyticsAiAnalysis.fromJson(rawAi),
      logCount: (json['log_count'] as num?)?.toInt() ?? 0,
      symptomaticDayCount:
          (json['symptomatic_day_count'] as num?)?.toInt() ?? 0,
      cached: json['cached'] == true,
    );
  }
}
