import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_frontend/features/onboarding/domain/gerdq.dart';

GerdQFrequency frequency(int index) => GerdQFrequency.values[index];

void main() {
  test('semua jawaban 0 hari menghasilkan skor 6', () {
    final result = calculateGerdQ(List.filled(6, frequency(0)));

    expect(result.score, 6);
    expect(result.likelyGerd, isFalse);
  });

  test('semua jawaban 4-7 hari menghasilkan skor 12', () {
    final result = calculateGerdQ(List.filled(6, frequency(3)));

    expect(result.score, 12);
    expect(result.likelyGerd, isTrue);
  });

  test('skor minimum dan maksimum sesuai aturan pembalikan', () {
    final minimum = calculateGerdQ([
      frequency(0),
      frequency(0),
      frequency(3),
      frequency(3),
      frequency(0),
      frequency(0),
    ]);
    final maximum = calculateGerdQ([
      frequency(3),
      frequency(3),
      frequency(0),
      frequency(0),
      frequency(3),
      frequency(3),
    ]);

    expect(minimum.score, 0);
    expect(maximum.score, 18);
  });

  test('cutoff 7 negatif dan 8 positif', () {
    final seven = calculateGerdQ([
      frequency(3),
      frequency(3),
      frequency(3),
      frequency(3),
      frequency(1),
      frequency(0),
    ]);
    final eight = calculateGerdQ([
      frequency(3),
      frequency(3),
      frequency(3),
      frequency(3),
      frequency(1),
      frequency(1),
    ]);

    expect(seven.score, 7);
    expect(seven.likelyGerd, isFalse);
    expect(eight.score, 8);
    expect(eight.likelyGerd, isTrue);
  });

  test('jumlah jawaban harus tepat enam', () {
    expect(() => calculateGerdQ([frequency(0)]), throwsArgumentError);
  });
}
