import 'package:flutter/material.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/gerdq_service.dart';
import '../../../../core/services/onboarding_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/auth_privacy_note.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../widgets/gerdq_result_action.dart';
import '../widgets/gerdq_result_header.dart';
import '../widgets/gerdq_score_card.dart';
import '../widgets/gerdq_result_interpretation.dart';
import '../widgets/gerdq_result_intro.dart';
import '../../domain/gerdq.dart';

class GerdQResultPage extends StatefulWidget {
  const GerdQResultPage({required this.answers, super.key});

  final List<GerdQFrequency> answers;

  @override
  State<GerdQResultPage> createState() => _GerdQResultPageState();
}

class _GerdQResultPageState extends State<GerdQResultPage> {
  bool _isSubmitting = false;

  Future<void> _finish(BuildContext context) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await GerdQService.instance.submit(widget.answers);
      await OnboardingService.instance.setGerdqStatus('completed');
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomePage()),
        (route) => false,
      );
    } on ApiException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat menyimpan hasil GERD-Q.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = calculateGerdQ(widget.answers);

    return PopScope(
      canPop: false,
      child: Scaffold(
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
                      GerdQScoreCard(score: result.score),
                      const SizedBox(height: 20),
                      GerdQResultInterpretation(score: result.score),
                      const SizedBox(height: 32),
                      GerdQResultAction(
                        onPressed: _isSubmitting
                            ? null
                            : () => _finish(context),
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
      ),
    );
  }
}
