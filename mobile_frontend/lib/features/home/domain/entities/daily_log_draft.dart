import '../../../../core/utils/local_date.dart';

enum DailySymptom {
  heartburn,
  regurgitasi,
  nyeriDada,
  kesulitanMenelan,
  kembungGas,
  suaraSerak,
  keringatDingin,
  kramPerut,
  ketidaknyamananTenggorokan,
}

extension DailySymptomDetails on DailySymptom {
  String get id => switch (this) {
    DailySymptom.heartburn => 'heartburn',
    DailySymptom.regurgitasi => 'regurgitasi',
    DailySymptom.nyeriDada => 'nyeri_dada',
    DailySymptom.kesulitanMenelan => 'kesulitan_menelan',
    DailySymptom.kembungGas => 'kembung_gas',
    DailySymptom.suaraSerak => 'suara_serak',
    DailySymptom.keringatDingin => 'keringat_dingin',
    DailySymptom.kramPerut => 'kram_perut',
    DailySymptom.ketidaknyamananTenggorokan => 'ketidaknyamanan_tenggorokan',
  };

  String get apiValue => switch (this) {
    DailySymptom.heartburn => 'Heartburn',
    DailySymptom.regurgitasi => 'Regurgitasi',
    DailySymptom.nyeriDada => 'Nyeri dada',
    DailySymptom.kesulitanMenelan => 'Kesulitan menelan',
    DailySymptom.kembungGas => 'Kembung & gas',
    DailySymptom.suaraSerak => 'Suara serak',
    DailySymptom.keringatDingin => 'Keringat dingin',
    DailySymptom.kramPerut => 'Kram perut',
    DailySymptom.ketidaknyamananTenggorokan => 'Ketidaknyamanan tenggorokan',
  };

  String get title => switch (this) {
    DailySymptom.heartburn => 'Heartburn (rasa terbakar di dada)',
    DailySymptom.regurgitasi => 'Regurgitasi (asam naik ke mulut)',
    DailySymptom.nyeriDada => 'Nyeri dada',
    DailySymptom.kesulitanMenelan => 'Kesulitan menelan',
    DailySymptom.kembungGas => 'Kembung dan gas di perut',
    DailySymptom.suaraSerak => 'Suara serak',
    DailySymptom.keringatDingin => 'Keringat dingin',
    DailySymptom.kramPerut => 'Kram perut',
    DailySymptom.ketidaknyamananTenggorokan => 'Ketidaknyamanan tenggorokan',
  };

  String get subtitle => switch (this) {
    DailySymptom.heartburn => 'Sensasi panas menjalar ke kerongkongan',
    DailySymptom.regurgitasi => 'Rasa masam atau pahit di pangkal lidah',
    DailySymptom.nyeriDada => 'Rasa tertekan di tengah tulang dada',
    DailySymptom.kesulitanMenelan => 'Sensasi makanan menyangkut di leher',
    DailySymptom.kembungGas => 'Perut terasa begah dan sering bersendawa',
    DailySymptom.suaraSerak => 'Pita suara teriritasi terutama di pagi hari',
    DailySymptom.keringatDingin =>
      'Keringat dingin yang muncul bersama keluhan',
    DailySymptom.kramPerut => 'Rasa kram atau mulas pada perut',
    DailySymptom.ketidaknyamananTenggorokan =>
      'Rasa mengganjal atau tidak nyaman di tenggorokan',
  };
}

enum DailyTrigger { pedas, berlemak, asam, berkafein, bersoda }

extension DailyTriggerDetails on DailyTrigger {
  String get apiValue => switch (this) {
    DailyTrigger.pedas => 'Pedas',
    DailyTrigger.berlemak => 'Berlemak/gorengan',
    DailyTrigger.asam => 'Asam',
    DailyTrigger.berkafein => 'Berkafein',
    DailyTrigger.bersoda => 'Bersoda',
  };

  String get label => switch (this) {
    DailyTrigger.pedas => 'Makanan pedas',
    DailyTrigger.berlemak => 'Makanan berlemak / gorengan',
    DailyTrigger.asam => 'Makanan asam (sitrus/tomat/cuka)',
    DailyTrigger.berkafein => 'Minuman berkafein (kopi/teh)',
    DailyTrigger.bersoda => 'Makanan / minuman bersoda',
  };
}

class MedicationDraft {
  MedicationDraft({
    required this.name,
    required this.timing,
    this.frequency = '1x hari ini',
  });

  String name;
  String timing;
  String frequency;

  Map<String, dynamic> toJson() => {
    'name': name,
    'timing': timing,
    'frequency': frequency,
  };
}

class DailyLogDraft {
  DailyLogDraft({required this.logDate});

  final DateTime logDate;
  final Set<DailySymptom> symptoms = <DailySymptom>{};
  bool noSymptoms = false;
  String symptomDescription = '';
  final Map<DailyTrigger, bool> triggers = {
    for (final trigger in DailyTrigger.values) trigger: false,
  };
  int mealFrequency = 3;
  final List<String> mealTimes = <String>['07:30', '12:30', '19:00'];
  int stressLevel = 3;
  String sleepTime = '23:00';
  String wakeTime = '06:30';
  bool tookMedication = false;
  final List<MedicationDraft> medications = <MedicationDraft>[];

  Map<String, dynamic> toJson() => {
    'log_date': _dateString(logDate),
    'symptoms': noSymptoms
        ? <String>[]
        : symptoms.map((item) => item.apiValue).toList(),
    'no_symptoms': noSymptoms,
    'symptom_description': symptomDescription.trim().isEmpty
        ? null
        : symptomDescription.trim(),
    'triggers': {
      for (final trigger in DailyTrigger.values)
        trigger.apiValue: triggers[trigger] == true ? 1 : 0,
    },
    'meal_frequency': mealFrequency,
    'meal_times': List<String>.from(mealTimes),
    'stress_level': stressLevel,
    'sleep_time': sleepTime,
    'wake_time': wakeTime,
    'medications': tookMedication
        ? medications.map((item) => item.toJson()).toList()
        : <dynamic>[],
    'took_medication': tookMedication,
  };
}

String _dateString(DateTime date) => dateOnlyString(date);
