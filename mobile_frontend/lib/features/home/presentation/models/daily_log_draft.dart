import '../../../../core/utils/local_date.dart';

class DailyLogDraft {
  DailyLogDraft({DateTime? logDate}) : logDate = localDateOnly(logDate);

  DateTime logDate;
  List<String> symptoms = [];
  bool noSymptoms = false;
  String? symptomDescription;
  Map<String, bool> triggers = {
    'Pedas': false,
    'Berlemak/gorengan': false,
    'Asam': false,
    'Berkafein': false,
    'Bersoda': false,
  };
  int mealFrequency = 3;
  List<String> mealTimes = ['07:30', '12:30', '19:00'];
  int stressLevel = 3;
  String sleepTime = '23:00';
  String wakeTime = '06:30';
  List<Map<String, String>> medications = [
    {'name': 'Omeprazole 20mg', 'schedule': 'Sebelum makan'},
  ];
  bool tookMedication = true;

  Map<String, dynamic> toPayload() => {
    'log_date': _isoDate(logDate),
    'symptoms': noSymptoms ? <String>[] : symptoms,
    'no_symptoms': noSymptoms,
    'symptom_description': symptomDescription,
    'triggers': triggers,
    'meal_frequency': mealFrequency,
    'meal_times': mealTimes,
    'stress_level': stressLevel,
    'sleep_time': sleepTime,
    'wake_time': wakeTime,
    'medications': tookMedication ? medications : <Map<String, String>>[],
    'took_medication': tookMedication,
  };

  static String _isoDate(DateTime value) => dateOnlyString(value);
}
