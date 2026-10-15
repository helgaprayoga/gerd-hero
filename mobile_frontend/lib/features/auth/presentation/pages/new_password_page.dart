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

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_isSubmitting ||
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authErrorMessage(error, isLogin: false))),
        );
      }
      return;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password gagal diperbarui.')),
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
