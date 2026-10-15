import 'api_service.dart';
import '../../features/onboarding/domain/gerdq.dart';

class GerdQSubmission {
  const GerdQSubmission({
    required this.answers,
    required this.score,
    required this.result,
    required this.evaluation,
    this.id,
    this.createdAt,
  });

  final List<int> answers;
  final int score;
  final String result;
  final String evaluation;
  final String? id;
  final DateTime? createdAt;

  factory GerdQSubmission.fromJson(Map<String, dynamic> json) {
    final answers =
        (json['answers'] as List?)
            ?.whereType<num>()
            .map((value) => value.toInt())
            .toList(growable: false) ??
        const <int>[];

    return GerdQSubmission(
      answers: answers,
      score: (json['score'] as num?)?.toInt() ?? 0,
      result: json['result']?.toString() ?? 'no_gerd',
      evaluation: json['evaluation']?.toString() ?? '',
      id: json['id']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}

class GerdQService {
  GerdQService._();

  static final instance = GerdQService._();

  Future<GerdQSubmission> submit(List<GerdQFrequency> answers) async {
    final response = await ApiService.instance.post('/api/gerdq', {
      'answers': answers.map((answer) => answer.index).toList(),
    });
    return GerdQSubmission.fromJson(
      Map<String, dynamic>.from(response['data'] as Map),
    );
  }
}
