import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_privacy_note.dart';
import '../widgets/check_email_actions.dart';
import '../widgets/check_email_hero.dart';
import '../widgets/check_email_tips.dart';
import 'new_password_page.dart';

class CheckEmailPage extends StatefulWidget {
  const CheckEmailPage({required this.email, super.key});

  final String email;

  @override
  State<CheckEmailPage> createState() => _CheckEmailPageState();
}

class _CheckEmailPageState extends State<CheckEmailPage> {
  static const _initialSeconds = 45;
  Timer? _timer;
  int _secondsLeft = _initialSeconds;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _initialSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _showMessage(String message) {
    showAppFeedback(
      context,
      title: 'Informasi email',
      message: message,
      icon: Icons.mail_outline,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surface,
    body: Column(
      children: [
        AuthHeader(onBack: () => Navigator.of(context).pop()),
        Expanded(
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                children: [
                  CheckEmailHero(email: widget.email),
                  const SizedBox(height: 20),
                  CheckEmailActions(
                    secondsLeft: _secondsLeft,
                    onOpenEmail: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const NewPasswordPage(),
                        ),
                      );
                    },
                    onResend: () {
                      _startCountdown();
                      _showMessage('Email telah dikirim ulang.');
                    },
                    onBackToLogin: () => Navigator.of(
                      context,
                    ).popUntil((route) => route.isFirst),
                  ),
                  const SizedBox(height: 16),
                  const CheckEmailTips(),
                  const SizedBox(height: 20),
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
