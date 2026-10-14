/// Opsi frekuensi gejala dalam 7 hari terakhir.
enum GerdQFrequency {
  zeroDays('0 hari'),
  oneDay('1 hari'),
  twoToThreeDays('2–3 hari'),
  fourToSevenDays('4–7 hari');

  const GerdQFrequency(this.label);

  final String label;
}

class GerdQQuestion {
  const GerdQQuestion({
    required this.text,
    required this.info,
    required this.isNegative,
  });

  final String text;
  final String info;
  final bool isNegative;

  int pointsFor(GerdQFrequency answer) =>
      isNegative ? 3 - answer.index : answer.index;
}

const String gerdQPeriodHint =
    'Jawab berdasarkan keluhan yang kamu rasakan dalam 7 hari terakhir.';

const List<GerdQQuestion> gerdQQuestions = [
  GerdQQuestion(
    text: 'Seberapa sering kamu merasakan nyeri terbakar di dada (heartburn)?',
    info:
        'Heartburn adalah sensasi terbakar di dada yang bisa terasa naik hingga ke tenggorokan.',
    isNegative: false,
  ),
  GerdQQuestion(
    text:
        'Seberapa sering kamu merasakan makanan atau cairan dari lambung naik ke tenggorokan atau mulut (regurgitasi)?',
    info:
        'Regurgitasi adalah naiknya makanan atau cairan dari lambung ke tenggorokan atau mulut, sering terasa asam atau pahit.',
    isNegative: false,
  ),
  GerdQQuestion(
    text: 'Seberapa sering kamu merasakan nyeri di ulu hati?',
    info:
        'Ulu hati adalah area di tengah perut bagian atas, tepat di bawah tulang dada.',
    isNegative: true,
  ),
  GerdQQuestion(
    text: 'Seberapa sering kamu merasa mual?',
    info:
        'Mual adalah rasa tidak nyaman di perut atau tenggorokan yang membuat kamu merasa ingin muntah.',
    isNegative: true,
  ),
  GerdQQuestion(
    text:
        'Seberapa sering kamu kesulitan tidur nyenyak di malam hari karena heartburn dan/atau naiknya isi lambung?',
    info:
        'Hitung malam ketika tidurmu terganggu atau kamu terbangun karena rasa terbakar di dada atau cairan lambung yang naik.',
    isNegative: false,
  ),
  GerdQQuestion(
    text:
        'Seberapa sering kamu minum obat tambahan untuk heartburn dan/atau naiknya isi lambung, di luar obat dari dokter?',
    info:
        'Obat tambahan misalnya obat maag atau antasida yang dibeli bebas, di luar resep dokter.',
    isNegative: false,
  ),
];

const int gerdQCutoff = 8;

class GerdQResult {
  const GerdQResult({
    required this.score,
    required this.pointsPerQuestion,
    required this.likelyGerd,
    required this.highImpact,
  });

  final int score;
  final List<int> pointsPerQuestion;
  final bool likelyGerd;
  final bool highImpact;

  String get label => likelyGerd
      ? 'Kemungkinan menderita GERD'
      : 'Kemungkinan tidak menderita GERD';
}

GerdQResult calculateGerdQ(List<GerdQFrequency> answers) {
  if (answers.length != gerdQQuestions.length) {
    throw ArgumentError(
      'GerdQ membutuhkan ${gerdQQuestions.length} jawaban, diterima ${answers.length}.',
    );
  }

  final points = [
    for (var index = 0; index < answers.length; index++)
      gerdQQuestions[index].pointsFor(answers[index]),
  ];
  final score = points.fold<int>(0, (sum, point) => sum + point);

  return GerdQResult(
    score: score,
    pointsPerQuestion: List.unmodifiable(points),
    likelyGerd: score >= gerdQCutoff,
    highImpact: points[4] + points[5] > 3,
  );
}
