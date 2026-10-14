import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/auth_privacy_note.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../widgets/gerdq_result_action.dart';
import '../widgets/gerdq_result_header.dart';
import '../widgets/gerdq_score_card.dart';
import '../widgets/gerdq_result_interpretation.dart';
import '../widgets/gerdq_result_intro.dart';

class GerdQResultPage extends StatelessWidget {
  const GerdQResultPage({this.score = 11, super.key});

  final int score;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surface,
    body: Column(
      children: [
        const GerdQResultHeader(),
        Expanded(
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                children: [
                  const GerdQResultIntro(),
                  const SizedBox(height: 16),
                  GerdQScoreCard(score: score),
                  const SizedBox(height: 20),
                  GerdQResultInterpretation(score: score),
                  const SizedBox(height: 32),
                  GerdQResultAction(
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(builder: (_) => const HomePage()),
                      (route) => false,
                    ),
                  ),
                  const SizedBox(height: 16),
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
