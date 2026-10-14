# Panduan Penghitungan GerdQ (Dart / Flutter)

Panduan ini menjelaskan cara menghitung skor **Gastroesophageal Reflux Disease Questionnaire (GerdQ)** dan implementasinya dalam Dart.

## 1. Ringkasan Aturan

- Kuesioner terdiri dari **6 pertanyaan** tentang gejala selama **7 hari terakhir**.
- Setiap pertanyaan punya 4 opsi jawaban: **0 hari, 1 hari, 2-3 hari, 4-7 hari**.
- Pertanyaan **1, 2, 5, 6** adalah prediktor positif GERD. Skornya naik seiring frekuensi (0, 1, 2, 3).
- Pertanyaan **3 dan 4** adalah prediktor negatif GERD. Skornya **dibalik** (3, 2, 1, 0).
- Skor total berkisar **0 sampai 18**.
- Skor **≥ 8** berarti kemungkinan menderita GERD. Skor **0-7** berarti kemungkinan tidak menderita GERD.

## 2. Pertanyaan, Info Singkat, dan Tabel Skor

Semua pertanyaan merujuk pada **7 hari terakhir**. Tampilkan petunjuk ini di atas daftar pertanyaan, misalnya: "Jawab berdasarkan keluhan yang kamu rasakan dalam 7 hari terakhir."

### 2.1 Teks pertanyaan dan info singkat

| No | Pertanyaan | Info singkat |
|----|------------|--------------|
| 1 | Seberapa sering kamu merasakan nyeri terbakar di dada (heartburn)? | Heartburn adalah sensasi terbakar di dada yang bisa terasa naik hingga ke tenggorokan. |
| 2 | Seberapa sering kamu merasakan makanan atau cairan dari lambung naik ke tenggorokan atau mulut (regurgitasi)? | Regurgitasi adalah naiknya makanan atau cairan dari lambung ke tenggorokan atau mulut, sering terasa asam atau pahit. |
| 3 | Seberapa sering kamu merasakan nyeri di ulu hati? | Ulu hati adalah area di tengah perut bagian atas, tepat di bawah tulang dada. |
| 4 | Seberapa sering kamu merasa mual? | Mual adalah rasa tidak nyaman di perut atau tenggorokan yang membuat kamu merasa ingin muntah. |
| 5 | Seberapa sering kamu kesulitan tidur nyenyak di malam hari karena heartburn dan/atau naiknya isi lambung? | Hitung malam ketika tidurmu terganggu atau kamu terbangun karena rasa terbakar di dada atau cairan lambung yang naik. |
| 6 | Seberapa sering kamu minum obat tambahan untuk heartburn dan/atau naiknya isi lambung, di luar obat dari dokter? | Obat tambahan misalnya obat maag atau antasida yang dibeli bebas, di luar resep dokter. |

### 2.2 Tabel skor

| No | Gejala | Jenis | 0 hari | 1 hari | 2-3 hari | 4-7 hari |
|----|--------|-------|:------:|:------:|:--------:|:--------:|
| 1 | Heartburn | Positif | 0 | 1 | 2 | 3 |
| 2 | Regurgitasi | Positif | 0 | 1 | 2 | 3 |
| 3 | Nyeri ulu hati | Negatif | 3 | 2 | 1 | 0 |
| 4 | Mual | Negatif | 3 | 2 | 1 | 0 |
| 5 | Sulit tidur malam | Positif | 0 | 1 | 2 | 3 |
| 6 | Obat tambahan | Positif | 0 | 1 | 2 | 3 |

## 3. Rumus

```
Skor total = Q1 + Q2 + Q3 + Q4 + Q5 + Q6

Poin positif (Q1, Q2, Q5, Q6) = indeks opsi          -> 0, 1, 2, 3
Poin negatif (Q3, Q4)         = 3 - indeks opsi      -> 3, 2, 1, 0
```

Dalam Dart, urutan `enum` dibuat sama dengan urutan opsi sehingga `index` langsung menjadi poin untuk pertanyaan positif. Untuk pertanyaan negatif, poinnya adalah `3 - index`.

## 4. Implementasi Dart

Simpan sebagai `lib/gerdq/gerdq.dart`.

```dart
/// Opsi frekuensi gejala. Urutan enum HARUS 0 hari -> 4-7 hari
/// karena `index` dipakai langsung sebagai poin.
enum GerdQFrequency {
  zeroDays('0 hari'),
  oneDay('1 hari'),
  twoToThreeDays('2-3 hari'),
  fourToSevenDays('4-7 hari');

  const GerdQFrequency(this.label);
  final String label;
}

/// Definisi satu pertanyaan GerdQ.
class GerdQQuestion {
  const GerdQQuestion({
    required this.text,
    required this.info,
    required this.isNegative,
  });

  /// Teks pertanyaan yang ditampilkan ke pengguna.
  final String text;

  /// Info singkat untuk membantu pengguna memahami istilah pada pertanyaan.
  final String info;

  /// true untuk pertanyaan 3 dan 4 (skor dibalik).
  final bool isNegative;

  /// Poin 0-3 untuk satu jawaban.
  int pointsFor(GerdQFrequency answer) =>
      isNegative ? 3 - answer.index : answer.index;
}

/// Petunjuk yang ditampilkan di atas daftar pertanyaan.
const String gerdQPeriodHint =
    'Jawab berdasarkan keluhan yang kamu rasakan dalam 7 hari terakhir.';

/// Enam pertanyaan GerdQ, urutan Q1..Q6.
const List<GerdQQuestion> gerdQQuestions = [
  GerdQQuestion(
    text: 'Seberapa sering kamu merasakan nyeri terbakar di dada (heartburn)?',
    info: 'Heartburn adalah sensasi terbakar di dada yang bisa terasa naik hingga ke tenggorokan.',
    isNegative: false,
  ),
  GerdQQuestion(
    text: 'Seberapa sering kamu merasakan makanan atau cairan dari lambung naik ke tenggorokan atau mulut (regurgitasi)?',
    info: 'Regurgitasi adalah naiknya makanan atau cairan dari lambung ke tenggorokan atau mulut, sering terasa asam atau pahit.',
    isNegative: false,
  ),
  GerdQQuestion(
    text: 'Seberapa sering kamu merasakan nyeri di ulu hati?',
    info: 'Ulu hati adalah area di tengah perut bagian atas, tepat di bawah tulang dada.',
    isNegative: true,
  ),
  GerdQQuestion(
    text: 'Seberapa sering kamu merasa mual?',
    info: 'Mual adalah rasa tidak nyaman di perut atau tenggorokan yang membuat kamu merasa ingin muntah.',
    isNegative: true,
  ),
  GerdQQuestion(
    text: 'Seberapa sering kamu kesulitan tidur nyenyak di malam hari karena heartburn dan/atau naiknya isi lambung?',
    info: 'Hitung malam ketika tidurmu terganggu atau kamu terbangun karena rasa terbakar di dada atau cairan lambung yang naik.',
    isNegative: false,
  ),
  GerdQQuestion(
    text: 'Seberapa sering kamu minum obat tambahan untuk heartburn dan/atau naiknya isi lambung, di luar obat dari dokter?',
    info: 'Obat tambahan misalnya obat maag atau antasida yang dibeli bebas, di luar resep dokter.',
    isNegative: false,
  ),
];

/// Hasil perhitungan GerdQ.
class GerdQResult {
  const GerdQResult({
    required this.score,
    required this.pointsPerQuestion,
    required this.likelyGerd,
    required this.highImpact,
  });

  /// Skor total, 0-18.
  final int score;

  /// Poin tiap pertanyaan (Q1..Q6), berguna untuk ditampilkan atau disimpan.
  final List<int> pointsPerQuestion;

  /// true jika skor >= 8.
  final bool likelyGerd;

  /// Subskala dampak penyakit (Q5 + Q6 > 3). Opsional, bukan bagian diagnosis.
  final bool highImpact;

  String get label => likelyGerd
      ? 'Kemungkinan menderita GERD'
      : 'Kemungkinan tidak menderita GERD';
}

const int gerdQCutoff = 8;

/// Menghitung skor GerdQ dari 6 jawaban (urutan Q1..Q6).
GerdQResult calculateGerdQ(List<GerdQFrequency> answers) {
  if (answers.length != gerdQQuestions.length) {
    throw ArgumentError(
      'GerdQ membutuhkan ${gerdQQuestions.length} jawaban, '
      'diterima ${answers.length}.',
    );
  }

  final points = <int>[
    for (var i = 0; i < answers.length; i++)
      gerdQQuestions[i].pointsFor(answers[i]),
  ];

  final score = points.fold<int>(0, (sum, p) => sum + p);
  final impact = points[4] + points[5];

  return GerdQResult(
    score: score,
    pointsPerQuestion: List.unmodifiable(points),
    likelyGerd: score >= gerdQCutoff,
    highImpact: impact > 3,
  );
}
```

## 5. Contoh Pemakaian

```dart
final result = calculateGerdQ([
  GerdQFrequency.fourToSevenDays,  // Q1 heartburn      -> 3
  GerdQFrequency.twoToThreeDays,   // Q2 regurgitasi    -> 2
  GerdQFrequency.zeroDays,         // Q3 nyeri ulu hati -> 3 (dibalik)
  GerdQFrequency.zeroDays,         // Q4 mual           -> 3 (dibalik)
  GerdQFrequency.oneDay,           // Q5 sulit tidur    -> 1
  GerdQFrequency.zeroDays,         // Q6 obat tambahan  -> 0
]);

print(result.score);       // 12
print(result.likelyGerd);  // true
print(result.label);       // Kemungkinan menderita GERD
```

### Menghubungkan ke UI (state sederhana)

```dart
// Simpan jawaban sebagai List<GerdQFrequency?> dengan panjang 6.
final answers = List<GerdQFrequency?>.filled(6, null);

bool get isComplete => answers.every((a) => a != null);

void onSubmit() {
  if (!isComplete) return; // semua pertanyaan wajib dijawab
  final result = calculateGerdQ(answers.cast<GerdQFrequency>());
  // tampilkan result.score dan result.label
}
```

### Menampilkan pertanyaan beserta info singkat

Contoh widget satu pertanyaan. Info ditampilkan sebagai teks kecil di bawah pertanyaan (bisa juga diganti tooltip atau ikon info yang membuka *bottom sheet*).

```dart
class GerdQQuestionTile extends StatelessWidget {
  const GerdQQuestionTile({
    super.key,
    required this.number,
    required this.question,
    required this.value,
    required this.onChanged,
  });

  final int number;
  final GerdQQuestion question;
  final GerdQFrequency? value;
  final ValueChanged<GerdQFrequency?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$number. ${question.text}', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          question.info,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final option in GerdQFrequency.values)
              ChoiceChip(
                label: Text(option.label),
                selected: value == option,
                onSelected: (_) => onChanged(option),
              ),
          ],
        ),
      ],
    );
  }
}
```

Pemakaian di halaman kuesioner:

```dart
Text(gerdQPeriodHint),
for (var i = 0; i < gerdQQuestions.length; i++)
  GerdQQuestionTile(
    number: i + 1,
    question: gerdQQuestions[i],
    value: answers[i],
    onChanged: (v) => setState(() => answers[i] = v),
  ),
```

## 6. Unit Test

Simpan sebagai `test/gerdq_test.dart`, jalankan dengan `flutter test`.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/gerdq/gerdq.dart'; // sesuaikan nama paket

GerdQFrequency f(int i) => GerdQFrequency.values[i];

void main() {
  test('semua jawaban 0 hari menghasilkan skor 6', () {
    // Q3 dan Q4 dibalik: 3 + 3 = 6
    final r = calculateGerdQ(List.filled(6, f(0)));
    expect(r.score, 6);
    expect(r.likelyGerd, false);
  });

  test('semua jawaban 4-7 hari menghasilkan skor 12', () {
    // Q1, Q2, Q5, Q6 = 3 masing-masing; Q3, Q4 = 0
    final r = calculateGerdQ(List.filled(6, f(3)));
    expect(r.score, 12);
    expect(r.likelyGerd, true);
  });

  test('skor maksimum 18', () {
    final r = calculateGerdQ([f(3), f(3), f(0), f(0), f(3), f(3)]);
    expect(r.score, 18);
  });

  test('skor minimum 0', () {
    final r = calculateGerdQ([f(0), f(0), f(3), f(3), f(0), f(0)]);
    expect(r.score, 0);
  });

  test('batas cut-off: 7 negatif, 8 positif', () {
    final seven = calculateGerdQ([f(3), f(3), f(3), f(3), f(1), f(0)]);
    final eight = calculateGerdQ([f(3), f(3), f(3), f(3), f(1), f(1)]);
    expect(seven.score, 7);
    expect(seven.likelyGerd, false);
    expect(eight.score, 8);
    expect(eight.likelyGerd, true);
  });

  test('jumlah jawaban salah melempar error', () {
    expect(() => calculateGerdQ([f(0)]), throwsArgumentError);
  });
}
```

## 7. Catatan Penting

1. **Cut-off ≥ 8 vs > 8.** Paper validasi Zavala-González dkk. (2014) menulis "score > 8", tetapi pengelompokan skor di paper itu (3-7 dan 8-11) hanya konsisten jika skor 8 termasuk positif. Kalkulator Kalbemed dan literatur lain memakai 8-18 sebagai positif, jadi kode ini memakai `>= 8`.
2. **Bukan alat diagnosis.** Sensitivitas dan spesifisitas GerdQ sekitar 72-75% terhadap endoskopi dan/atau pH-metri. Tampilkan disclaimer bahwa hasil hanya untuk informasi dan perlu konfirmasi dokter.
3. **Gejala alarm.** Paper mengecualikan pasien dengan penurunan berat badan tanpa sebab, sulit menelan (disfagia) yang berat atau progresif, dan perdarahan saluran cerna. Pertimbangkan menambah pertanyaan penapisan ini sebelum kuesioner dan menampilkan anjuran ke dokter jika dijawab "ya", apa pun skor GerdQ-nya.
4. **Validasi input.** Pastikan keenam pertanyaan terjawab sebelum memanggil `calculateGerdQ`.
5. **Lisensi.** Penggunaan GerdQ pada produk yang dipublikasikan atau dikomersialkan dapat memerlukan izin pemegang hak kuesioner. Untuk keperluan akademik atau hackathon, tetap cantumkan referensi.

## 8. Referensi

1. Jones R, Junghard O, Dent J, dkk. Development of the GerdQ, a tool for the diagnosis and management of gastro-oesophageal reflux disease in primary care. *Aliment Pharmacol Ther.* 2009;30(10):1030-1038.
2. Zavala-González MA, Azamar-Jacome AA, Meixueiro-Daza A, dkk. Validation and diagnostic usefulness of gastroesophageal reflux disease questionnaire in a primary care level in Mexico. *J Neurogastroenterol Motil.* 2014;20(4):475-482.
3. Perkumpulan Gastroenterologi Indonesia. Revisi konsensus nasional penatalaksanaan penyakit refluks gastroesofageal (GERD) di Indonesia. Jakarta: PGI; 2013.
