import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/onboarding_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/auth_privacy_note.dart';
import '../widgets/gerdq_disclaimer.dart';
import '../widgets/gerdq_header.dart';
import '../widgets/gerdq_hero.dart';
import '../widgets/gerdq_info_card.dart';
import '../widgets/gerdq_start_action.dart';
import 'gerdq_question_page.dart';
import 'profile_page.dart';
import '../../../home/presentation/pages/home_page.dart';

class GerdQIntroPage extends StatelessWidget {
  const GerdQIntroPage({super.key});

  void _backToProfile(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    navigator.pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
    );
  }

  Future<void> _skip(BuildContext context) async {
    try {
      await OnboardingService.instance.setGerdqStatus('skipped');
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomePage()),
        (route) => false,
      );
    } on ApiException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surface,
    body: Column(
      children: [
        GerdQHeader(
          onBack: () => _backToProfile(context),
          onSkip: () => _skip(context),
        ),
        Expanded(
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                children: [
                  const GerdQHero(),
                  const SizedBox(height: 20),
                  const GerdQInfoCard(),
                  const SizedBox(height: 12),
                  const GerdQDisclaimer(),
                  const SizedBox(height: 24),
                  GerdQStartAction(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const GerdQQuestionPage(),
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
