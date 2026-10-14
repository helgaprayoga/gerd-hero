import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/agreement_card.dart';
import '../widgets/continue_button.dart';
import '../widgets/disclaimer_flow_indicator.dart';
import '../widgets/disclaimer_header.dart';
import '../widgets/disclaimer_intro_card.dart';
import '../widgets/lifestyle_callout.dart';
import '../widgets/medical_disclaimer_card.dart';

class DisclaimerPage extends StatefulWidget {
  const DisclaimerPage({super.key, this.onContinue});

  final VoidCallback? onContinue;

  @override
  State<DisclaimerPage> createState() => _DisclaimerPageState();
}

class _DisclaimerPageState extends State<DisclaimerPage> {
  bool _isAgreed = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surface,
    body: Column(
      children: [
        DisclaimerHeader(onBack: () => Navigator.of(context).pop()),
        Expanded(
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const DisclaimerFlowIndicator(),
                  const SizedBox(height: 20),
                  const DisclaimerIntroCard(),
                  const SizedBox(height: 20),
                  const MedicalDisclaimerCard(),
                  const SizedBox(height: 20),
                  const LifestyleCallout(),
                  const SizedBox(height: 20),
                  AgreementCard(
                    isAgreed: _isAgreed,
                    onTap: () => setState(() => _isAgreed = !_isAgreed),
                  ),
                  const SizedBox(height: 10),
                  ContinueButton(
                    enabled: _isAgreed,
                    onPressed: _isAgreed ? widget.onContinue : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bukan pengganti diagnosis klinis dokter darurat.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
