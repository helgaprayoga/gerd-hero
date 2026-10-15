import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../widgets/auth_greeting.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_mode_switcher.dart';
import '../widgets/auth_privacy_note.dart';
import '../widgets/register_form_card.dart';
import '../models/auth_mode.dart';
import '../utils/auth_validators.dart';
import '../utils/auth_error_message.dart';
import 'check_email_page.dart';
import 'profile_gate_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final hasError =
        !(_formKey.currentState?.validate() ?? false) ||
        emailError(_emailController.text) != null ||
        passwordError(_passwordController.text) != null ||
        confirmPasswordError(
              _passwordController.text,
              _confirmPasswordController.text,
            ) !=
            null;
    if (hasError) {
      setState(() {});
      return;
    }
    final email = _emailController.text.trim().toLowerCase();
    setState(() => _isSubmitting = true);
    try {
      final response = await AuthService.instance.register(
        email: email,
        password: _passwordController.text,
      );

      if (!mounted) return;
      if (response.session == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => CheckEmailPage(email: email)),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const ProfileGatePage()),
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        _showMessage(authErrorMessage(error, isLogin: false));
      }
    } catch (error) {
      if (mounted) {
        _showMessage(authErrorMessage(error, isLogin: false));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      await AuthService.instance.signInWithGoogle();
    } catch (error) {
      if (mounted) {
        _showMessage(authErrorMessage(error, isLogin: true));
      }
    }
  }

  void _showMessage(String message) {
    showAppFeedback(
      context,
      title: 'Informasi pendaftaran',
      message: message,
      icon: Icons.info_outline,
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
                    title: 'Buat akun baru',
                    subtitle: 'Mulai catat gejala dan kenali pemicumu.',
                  ),
                  const SizedBox(height: 20),
                  AuthModeSwitcher(
                    mode: AuthMode.register,
                    onChanged: (mode) {
                      if (mode == AuthMode.login) Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(height: 20),
                  RegisterFormCard(
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                    emailError: emailError(_emailController.text),
                    passwordError: passwordError(_passwordController.text),
                    confirmPasswordError: confirmPasswordError(
                      _passwordController.text,
                      _confirmPasswordController.text,
                    ),
                    onEmailChanged: (_) => setState(() {}),
                    onPasswordChanged: (_) => setState(() {}),
                    onConfirmPasswordChanged: (_) => setState(() {}),
                    passwordVisible: _passwordVisible,
                    confirmPasswordVisible: _confirmPasswordVisible,
                    onTogglePassword: () =>
                        setState(() => _passwordVisible = !_passwordVisible),
                    onToggleConfirmPassword: () => setState(
                      () => _confirmPasswordVisible = !_confirmPasswordVisible,
                    ),
                    onSubmit: _submit,
                    isLoading: _isSubmitting,
                    onGoogle: _signInWithGoogle,
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
