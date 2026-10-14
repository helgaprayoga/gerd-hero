import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/auth_privacy_note.dart';
import '../widgets/gerdq_header.dart';
import '../widgets/gerdq_progress_card.dart';
import '../widgets/gerdq_question_card.dart';
import '../widgets/gerdq_heartburn_info_card.dart';
import 'gerdq_result_page.dart';

class GerdQQuestionPage extends StatefulWidget {
  const GerdQQuestionPage({super.key});

  @override
  State<GerdQQuestionPage> createState() => _GerdQQuestionPageState();
}

class _GerdQQuestionPageState extends State<GerdQQuestionPage> {
  String? _selectedAnswer = '2–3 hari';

  static const _answers = ['0 hari', '1 hari', '2–3 hari', '4–7 hari'];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surface,
    body: Column(
      children: [
        GerdQHeader(onSkip: () => Navigator.of(context).pop()),
        Expanded(
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GerdQProgressCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'Seberapa sering kamu merasakan\nnyeri terbakar di dada (heartburn)?',
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 24,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Dalam 7 hari terakhir',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const GerdQHeartburnInfoCard(),
                  const SizedBox(height: 20),
                  GerdQQuestionCard(
                    answers: _answers,
                    selectedAnswer: _selectedAnswer,
                    onAnswerSelected: (answer) {
                      setState(() => _selectedAnswer = answer);
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _selectedAnswer == null
                          ? null
                          : () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    const GerdQResultPage(score: 11),
                              ),
                            ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Lanjut'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
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
