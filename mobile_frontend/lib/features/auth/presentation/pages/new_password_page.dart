import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/auth_greeting.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_privacy_note.dart';
import '../widgets/new_password_form_card.dart';
import 'login_page.dart';

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _passwordVisible = false;
  bool _confirmVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (route) => false,
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
                    isRegister: true,
                    title: 'Buat kata sandi baru',
                    subtitle:
                        'Gunakan kata sandi yang berbeda dari sebelumnya.',
                  ),
                  const SizedBox(height: 20),
                  NewPasswordFormCard(
                    formKey: _formKey,
                    passwordController: _passwordController,
                    confirmController: _confirmController,
                    passwordVisible: _passwordVisible,
                    confirmVisible: _confirmVisible,
                    onPasswordChanged: (_) => setState(() {}),
                    onConfirmChanged: (_) => setState(() {}),
                    onTogglePassword: () =>
                        setState(() => _passwordVisible = !_passwordVisible),
                    onToggleConfirm: () =>
                        setState(() => _confirmVisible = !_confirmVisible),
                    onSubmit: _submit,
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
