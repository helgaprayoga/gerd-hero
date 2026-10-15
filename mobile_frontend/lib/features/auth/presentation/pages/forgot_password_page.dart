import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../utils/auth_validators.dart';
import '../utils/auth_error_message.dart';
import '../widgets/auth_greeting.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_privacy_note.dart';
import '../widgets/forgot_password_form_card.dart';
import 'check_email_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false) ||
        emailError(_emailController.text) != null) {
      setState(() {});
      return;
    }

    setState(() => _isSubmitting = true);
    final email = _emailController.text.trim().toLowerCase();
    String? requestError;
    try {
      await AuthService.instance.requestPasswordReset(email);
    } on AuthException catch (error) {
      requestError = authErrorMessage(
        error,
        isLogin: false,
        isPasswordReset: true,
      );
    } catch (_) {
      requestError = 'Tidak dapat mengirim email reset.';
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }

    if (!mounted) return;
    if (requestError != null) {
      await showAppFeedback(
        context,
        title: 'Email belum terkirim',
        message: requestError,
        icon: Icons.error_outline,
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CheckEmailPage(email: email, isPasswordReset: true),
      ),
    );
    final errorMessage = requestError;
    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
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
                  const AuthGreeting(
                    isRegister: false,
                    title: 'Lupa kata sandi?',
                    subtitle:
                        'Masukkan email akunmu. Kami akan mengirim tautan untuk mengatur ulang kata sandi.',
                  ),
                  const SizedBox(height: 20),
                  ForgotPasswordFormCard(
                    formKey: _formKey,
                    emailController: _emailController,
                    onEmailChanged: (_) => setState(() {}),
                    onSubmit: _submit,
                    onBackToLogin: () => Navigator.of(context).pop(),
                    isLoading: _isSubmitting,
                  ),
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
