import 'profile_data.dart';

enum HomeStatus {
  profileIncomplete,
  evaluationDue,
  symptomaticToday,
  loggedToday,
  noTodayLog,
  noData,
}

enum GerdieState { firstVisit, noSymptoms, moderateSymptoms, highSymptoms }

const gerdieHighThreshold = 0.60;

class HomeGerdqData {
  const HomeGerdqData({
    required this.score,
    required this.result,
    required this.evaluation,
    required this.createdAt,
  });

  final int score;
  final String result;
  final String evaluation;
  final DateTime createdAt;

  factory HomeGerdqData.fromJson(Map<String, dynamic> json) {
    return HomeGerdqData(
      score: (json['score'] as num?)?.toInt() ?? 0,
      result: json['result']?.toString() ?? 'no_gerd',
      evaluation:
          json['evaluation']?.toString() ??
          (json['score'] is num && (json['score'] as num) >= 8
              ? 'Kemungkinan menderita GERD'
              : 'Kemungkinan tidak menderita GERD'),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class HomeDailyLog {
  const HomeDailyLog({
    required this.date,
    required this.gerdLevel,
    required this.noSymptoms,
    required this.symptoms,
    required this.triggers,
  });

  final DateTime date;
  final double gerdLevel;
  final bool noSymptoms;
  final List<String> symptoms;
  final Map<String, dynamic> triggers;

  bool get isSymptomatic =>
      !noSymptoms && (symptoms.isNotEmpty || gerdLevel > 0);

  factory HomeDailyLog.fromJson(Map<String, dynamic> json) {
    return HomeDailyLog(
      date:
          DateTime.tryParse(json['log_date']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      gerdLevel: (json['gerd_level'] as num?)?.toDouble() ?? 0,
      noSymptoms: json['no_symptoms'] == true,
      symptoms:
          (json['symptoms'] as List?)?.whereType<String>().toList(
            growable: false,
          ) ??
          const [],
      triggers: json['triggers'] is Map
          ? Map<String, dynamic>.from(json['triggers'] as Map)
          : const {},
    );
  }
}

class HomeDashboardData {
  const HomeDashboardData({
    required this.profile,
    required this.weeklyLogs,
    this.latestGerdq,
  });

  final ProfileData profile;
  final List<HomeDailyLog> weeklyLogs;
  final HomeGerdqData? latestGerdq;

  int get streakDays => profile.streakDays;

  DateTime? get lastLogDate => profile.lastLogDate;

  bool get hasLogToday {
    final today = _dateOnly(DateTime.now());
    final logExists = weeklyLogs.any((log) => _dateOnly(log.date) == today);
    final profileLogExists =
        lastLogDate != null && _dateOnly(lastLogDate!) == today;
    return logExists || profileLogExists;
  }

  GerdieState get gerdieState {
    final hasAnyLog = profile.lastLogDate != null || weeklyLogs.isNotEmpty;
    if (!hasAnyLog) return GerdieState.firstVisit;

    final today = weeklyLogs.cast<HomeDailyLog?>().firstWhere(
      (log) => log != null && _dateOnly(log.date) == _dateOnly(DateTime.now()),
      orElse: () => null,
    );
    if (today == null || today.noSymptoms || today.gerdLevel <= 0) {
      return GerdieState.noSymptoms;
    }
    if (today.gerdLevel >= gerdieHighThreshold) {
      return GerdieState.highSymptoms;
    }
    return GerdieState.moderateSymptoms;
  }

  HomeStatus get status {
    if (!profile.hasBasicProfile) return HomeStatus.profileIncomplete;

    final now = _dateOnly(DateTime.now());
    final today = weeklyLogs.cast<HomeDailyLog?>().firstWhere(
      (log) => log != null && _dateOnly(log.date) == now,
      orElse: () => null,
    );
    if (today != null) {
      return today.isSymptomatic
          ? HomeStatus.symptomaticToday
          : HomeStatus.loggedToday;
    }
    if (latestGerdq != null &&
        now.difference(_dateOnly(latestGerdq!.createdAt)).inDays >= 7) {
      return HomeStatus.evaluationDue;
    }
    return weeklyLogs.isEmpty ? HomeStatus.noData : HomeStatus.noTodayLog;
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
