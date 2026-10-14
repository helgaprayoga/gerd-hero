import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../utils/auth_validators.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false) ||
        emailError(_emailController.text) != null) {
      setState(() {});
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CheckEmailPage(email: _emailController.text),
      ),
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
