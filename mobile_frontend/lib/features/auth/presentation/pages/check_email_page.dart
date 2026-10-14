import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_privacy_note.dart';
import '../widgets/check_email_actions.dart';
import '../widgets/check_email_hero.dart';
import '../widgets/check_email_tips.dart';
import '../utils/auth_error_message.dart';
import 'login_page.dart';
import 'new_password_page.dart';

class CheckEmailPage extends StatefulWidget {
  const CheckEmailPage({
    required this.email,
    this.isPasswordReset = false,
    super.key,
  });

  final String email;
  final bool isPasswordReset;

  @override
  State<CheckEmailPage> createState() => _CheckEmailPageState();
}

class _CheckEmailPageState extends State<CheckEmailPage> {
  static const _initialSeconds = 45;
  Timer? _timer;
  int _secondsLeft = _initialSeconds;
  bool _isResending = false;

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

  Future<void> _resendVerificationEmail() async {
    if (_isResending || _secondsLeft != 0) return;

    if (widget.isPasswordReset) {
      _startCountdown();
      _showMessage('Email pengaturan ulang telah dikirim ulang.');
      return;
    }

    setState(() => _isResending = true);
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );
      if (!mounted) return;
      _startCountdown();
      _showMessage('Email verifikasi telah dikirim ulang.');
    } catch (error) {
      if (mounted) {
        _showMessage(authErrorMessage(error, isLogin: false));
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
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
                    isResending: _isResending,
                    onOpenEmail: widget.isPasswordReset
                        ? () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const NewPasswordPage(),
                            ),
                          )
                        : () => _showMessage(
                            'Silakan buka aplikasi email dan tekan tautan verifikasi dari Supabase.',
                          ),
                    onResend: _resendVerificationEmail,
                    onBackToLogin: () =>
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute<void>(
                            builder: (_) => const LoginPage(),
                          ),
                          (route) => false,
                        ),
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
