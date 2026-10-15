class ProfileData {
  const ProfileData({
    this.name,
    this.nickname,
    this.email,
    this.birthDate,
    this.gender,
    this.height,
    this.weight,
    this.bmi,
    this.streakDays = 0,
    this.lastLogDate,
    this.smoking,
    this.alcohol,
    this.workPattern,
    this.coffee,
    this.medicalHistory = const [],
    this.routineMeds = const [],
  });

  final String? name;
  final String? nickname;
  final String? email;
  final DateTime? birthDate;
  final String? gender;
  final double? height;
  final double? weight;
  final double? bmi;
  final int streakDays;
  final DateTime? lastLogDate;
  final String? smoking;
  final String? alcohol;
  final String? workPattern;
  final bool? coffee;
  final List<String> medicalHistory;
  final List<ProfileMedicine> routineMeds;

  bool get hasBasicProfile =>
      ((nickname?.trim().isNotEmpty ?? false) ||
          (name?.trim().isNotEmpty ?? false)) &&
      birthDate != null &&
      (gender == 'male' || gender == 'female');

  String get displayName {
    final value = nickname?.trim();
    if (value != null && value.isNotEmpty) return value;
    final fallback = name?.trim();
    return fallback == null || fallback.isEmpty ? 'Pengguna' : fallback;
  }

  String get avatarLabel {
    final words = displayName
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.length > 1) {
      return '${words.first[0]}${words.last[0]}'.toUpperCase();
    }
    return displayName[0].toUpperCase();
  }

  double get completion {
    var completed = 0;
    // Riwayat penyakit dan obat rutin bersifat opsional. Tidak semua pengguna
    // memiliki data tersebut, sehingga keduanya tidak menjadi syarat 100%.
    const total = 9;
    if (nickname?.trim().isNotEmpty ?? false) {
      completed++;
    }
    if (birthDate != null) completed++;
    if (gender == 'male' || gender == 'female') completed++;
    if (height != null && height! > 0) completed++;
    if (weight != null && weight! > 0) completed++;
    if (smoking != null) completed++;
    if (alcohol != null) completed++;
    if (workPattern != null) completed++;
    if (coffee != null) completed++;
    return completed / total;
  }

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    final extended = json['extended'] is Map
        ? Map<String, dynamic>.from(json['extended'] as Map)
        : const <String, dynamic>{};

    return ProfileData(
      name: _asString(json['name']),
      nickname: _asString(json['nickname']),
      email: _asString(json['email']),
      birthDate: _asDate(json['birth_date']),
      gender: _asString(json['gender']),
      height: _asDouble(json['height']),
      weight: _asDouble(json['weight']),
      bmi: _asDouble(json['bmi']),
      streakDays: (json['streak_days'] as num?)?.toInt() ?? 0,
      lastLogDate: _asDate(json['last_log_date']),
      smoking: _asString(extended['smoking']),
      alcohol: _asString(extended['alcohol']),
      workPattern: _asString(extended['work_pattern']),
      coffee: extended['coffee'] is bool ? extended['coffee'] as bool : null,
      medicalHistory: _asStringList(extended['medical_history']),
      routineMeds: _asMedicineList(extended['routine_meds']),
    );
  }

  static String? _asString(dynamic value) => value is String ? value : null;

  static double? _asDouble(dynamic value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '');

  static DateTime? _asDate(dynamic value) =>
      value is String ? DateTime.tryParse(value) : null;

  static List<String> _asStringList(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<String>().toList(growable: false);
  }

  static List<ProfileMedicine> _asMedicineList(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map(
          (medicine) => ProfileMedicine(
            name: medicine['name']?.toString() ?? '',
            schedule: medicine['schedule']?.toString() ?? '',
          ),
        )
        .where((medicine) => medicine.name.isNotEmpty)
        .toList(growable: false);
  }
}

class ProfileMedicine {
  const ProfileMedicine({required this.name, required this.schedule});

  final String name;
  final String schedule;
}
