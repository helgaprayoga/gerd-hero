import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_frontend/features/home/domain/entities/daily_log_draft.dart';

void main() {
  test('serializes exactly the nine supported symptoms', () {
    final draft = DailyLogDraft(logDate: DateTime(2026, 10, 15));
    draft.symptoms.addAll(DailySymptom.values);

    final payload = draft.toJson();
    final symptoms = payload['symptoms'] as List<dynamic>;

    expect(DailySymptom.values, hasLength(9));
    expect(symptoms, hasLength(9));
    expect(symptoms, isNot(contains('Gejala sementara')));
    expect(symptoms, contains('Ketidaknyamanan tenggorokan'));
  });

  test('no symptoms always serializes an empty symptom list', () {
    final draft = DailyLogDraft(logDate: DateTime(2026, 10, 15));
    draft.symptoms.add(DailySymptom.heartburn);
    draft.noSymptoms = true;

    expect(draft.toJson()['symptoms'], isEmpty);
  });
}
