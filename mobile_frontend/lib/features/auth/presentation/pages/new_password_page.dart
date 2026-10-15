import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/auth_service.dart';
import '../widgets/auth_greeting.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_privacy_note.dart';
import '../widgets/new_password_form_card.dart';
import '../utils/auth_error_message.dart';
import '../utils/auth_validators.dart';
import 'forgot_password_page.dart';
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
  bool _isSubmitting = false;
  bool _hasRecoverySession = false;

  @override
  void initState() {
    super.initState();
    try {
      _hasRecoverySession =
          AuthService.instance.isPasswordRecovery &&
          AuthService.instance.currentSession != null;
    } on AssertionError {
      _hasRecoverySession = false;
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    AuthService.instance.clearPasswordRecovery();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_isSubmitting ||
        !_hasRecoverySession ||
        !(_formKey.currentState?.validate() ?? false) ||
        passwordError(_passwordController.text) != null ||
        confirmPasswordError(
              _passwordController.text,
              _confirmController.text,
            ) !=
            null) {
      setState(() {});
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await AuthService.instance.updatePassword(_passwordController.text);
      await AuthService.instance.signOut();
    } on AuthException catch (error) {
      if (mounted) {
        if (_isExpiredRecoveryError(error)) {
          setState(() => _hasRecoverySession = false);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authErrorMessage(error, isLogin: false, isPasswordReset: true),
            ),
          ),
        );
      }
      return;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kata sandi gagal diperbarui.')),
        );
      }
      return;
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  bool _isExpiredRecoveryError(AuthException error) {
    final code = error.code?.toLowerCase() ?? '';
    final message = error.message.toLowerCase();
    return code == 'otp_expired' ||
        code == 'flow_state_expired' ||
        message.contains('expired') ||
        (message.contains('invalid') &&
            (message.contains('link') || message.contains('token')));
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
                  if (_hasRecoverySession)
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
                    )
                  else
                    _RecoveryLinkExpiredCard(
                      onRequestNewLink: () =>
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushAndRemoveUntil(
                            MaterialPageRoute<void>(
                              builder: (_) => const ForgotPasswordPage(),
                            ),
                            (route) => false,
                          ),
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

class _RecoveryLinkExpiredCard extends StatelessWidget {
  const _RecoveryLinkExpiredCard({required this.onRequestNewLink});

  final VoidCallback onRequestNewLink;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: const [
        BoxShadow(
          color: Color(0x10000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        const Icon(Icons.link_off, size: 36, color: AppColors.primary),
        const SizedBox(height: 12),
        const Text(
          'Tautan reset tidak tersedia atau sudah kedaluwarsa.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: onRequestNewLink,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
            child: const Text('Minta tautan baru'),
          ),
        ),
      ],
    ),
  );
}
