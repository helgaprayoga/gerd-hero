import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/auth_privacy_note.dart';
import '../../domain/gerdq.dart';
import '../widgets/gerdq_answer_option.dart';
import '../widgets/gerdq_header.dart';
import '../widgets/gerdq_progress_card.dart';
import '../widgets/gerdq_question_info_card.dart';
import 'gerdq_result_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/onboarding_service.dart';

class GerdQQuestionPage extends StatefulWidget {
  const GerdQQuestionPage({super.key});

  @override
  State<GerdQQuestionPage> createState() => _GerdQQuestionPageState();
}

class _GerdQQuestionPageState extends State<GerdQQuestionPage> {
  late final List<GerdQFrequency?> _answers;
  int _currentIndex = 0;
  bool _isLoading = false;

  GerdQQuestion get _question => gerdQQuestions[_currentIndex];
  GerdQFrequency? get _selectedAnswer => _answers[_currentIndex];

  @override
  void initState() {
    super.initState();
    _answers = List<GerdQFrequency?>.filled(gerdQQuestions.length, null);
  }

  Future<void> _skip() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await OnboardingService.instance.setGerdqStatus('skipped');
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomePage()),
        (route) => false,
      );
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goBack() {
    if (_isLoading) return;
    if (_currentIndex == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _currentIndex--);
  }

  void _goNext() {
    if (_selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jawaban terlebih dahulu.')),
      );
      return;
    }

    if (_currentIndex < gerdQQuestions.length - 1) {
      setState(() => _currentIndex++);
      return;
    }

    final answers = _answers.cast<GerdQFrequency>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GerdQResultPage(answers: answers),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surface,
    body: Column(
      children: [
        GerdQHeader(onBack: _goBack, onSkip: _skip),
        Expanded(
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GerdQProgressCard(
                    currentQuestion: _currentIndex + 1,
                    totalQuestions: gerdQQuestions.length,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _question.text,
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 24,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    gerdQPeriodHint,
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),
                  GerdQQuestionInfoCard(info: _question.info),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      for (final answer in GerdQFrequency.values) ...[
                        GerdQAnswerOption(
                          label: answer.label,
                          selected: answer == _selectedAnswer,
                          onTap: () =>
                              setState(() => _answers[_currentIndex] = answer),
                        ),
                        if (answer != GerdQFrequency.values.last)
                          const SizedBox(height: 10),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _goNext,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentIndex == gerdQQuestions.length - 1
                                ? 'Lihat hasil'
                                : 'Lanjut',
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const AuthPrivacyNote(),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
