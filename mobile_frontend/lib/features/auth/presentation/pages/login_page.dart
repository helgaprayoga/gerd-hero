import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../models/auth_mode.dart';
import '../utils/auth_validators.dart';
import '../widgets/auth_form_card.dart';
import '../widgets/auth_greeting.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_mode_switcher.dart';
import '../widgets/auth_privacy_note.dart';
import '../widgets/register_form_card.dart';
import 'forgot_password_page.dart';
import 'check_email_page.dart';
import '../utils/auth_error_message.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AuthMode _mode = AuthMode.login;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isRegister = _mode == AuthMode.register;
    final hasError =
        !(_formKey.currentState?.validate() ?? false) ||
        (isRegister
            ? emailError(_registerEmailController.text) != null ||
                  passwordError(_registerPasswordController.text) != null ||
                  confirmPasswordError(
                        _registerPasswordController.text,
                        _confirmPasswordController.text,
                      ) !=
                      null
            : emailError(_emailController.text) != null ||
                  passwordError(_passwordController.text) != null);

    if (hasError) {
      setState(() {});
      return;
    }

    final email =
        (isRegister ? _registerEmailController.text : _emailController.text)
            .trim()
            .toLowerCase();
    final password = isRegister
        ? _registerPasswordController.text
        : _passwordController.text;

    setState(() => _isSubmitting = true);
    try {
      if (isRegister) {
        final response = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );

        if (!mounted) return;
        if (response.session == null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => CheckEmailPage(email: email),
            ),
          );
        }
        // Jika session langsung tersedia, auth listener pada app.dart
        // menangani navigasi ke ProfilePage.
      } else {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        // Navigasi ditangani oleh auth listener agar alur email dan OAuth
        // tetap menggunakan satu sumber perubahan status autentikasi.
      }
    } on AuthException catch (error) {
      if (mounted) {
        _showMessage(authErrorMessage(error, isLogin: !isRegister));
      }
    } catch (error) {
      if (mounted) {
        _showMessage(authErrorMessage(error, isLogin: !isRegister));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String message) {
    showAppFeedback(
      context,
      title: 'Periksa kembali',
      message: message,
      icon: Icons.info_outline,
    );
  }

  // ── Fungsi Login Google ──────────────────────────────────────────
  Future<void> _signInWithGoogle() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.gerdhero://login-callback',
      );
    } catch (e) {
      _showMessage('Gagal login dengan Google: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRegister = _mode == AuthMode.register;

    return Scaffold(
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
                    AuthGreeting(
                      isRegister: isRegister,
                      title: isRegister ? 'Buat akun baru' : null,
                      subtitle: isRegister
                          ? 'Mulai catat gejala dan kenali pemicumu.'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    AuthModeSwitcher(
                      mode: _mode,
                      onChanged: (mode) => setState(() => _mode = mode),
                    ),
                    const SizedBox(height: 20),
                    if (isRegister)
                      RegisterFormCard(
                        formKey: _formKey,
                        emailController: _registerEmailController,
                        passwordController: _registerPasswordController,
                        confirmPasswordController: _confirmPasswordController,
                        emailError: emailError(_registerEmailController.text),
                        passwordError: passwordError(
                          _registerPasswordController.text,
                        ),
                        confirmPasswordError: confirmPasswordError(
                          _registerPasswordController.text,
                          _confirmPasswordController.text,
                        ),
                        onEmailChanged: (_) => setState(() {}),
                        onPasswordChanged: (_) => setState(() {}),
                        onConfirmPasswordChanged: (_) => setState(() {}),
                        passwordVisible: _passwordVisible,
                        confirmPasswordVisible: _confirmPasswordVisible,
                        onTogglePassword: () => setState(
                          () => _passwordVisible = !_passwordVisible,
                        ),
                        onToggleConfirmPassword: () => setState(
                          () => _confirmPasswordVisible =
                              !_confirmPasswordVisible,
                        ),
                        onSubmit: _submit,
                        isLoading: _isSubmitting,
                        onGoogle: _signInWithGoogle, // 👈 Tersambung ke Google
                      )
                    else
                      AuthFormCard(
                        formKey: _formKey,
                        mode: _mode,
                        passwordVisible: _passwordVisible,
                        confirmPasswordVisible: _confirmPasswordVisible,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        emailError: emailError(_emailController.text),
                        passwordError: passwordError(_passwordController.text),
                        onEmailChanged: (_) => setState(() {}),
                        onPasswordChanged: (_) => setState(() {}),
                        onTogglePassword: () => setState(
                          () => _passwordVisible = !_passwordVisible,
                        ),
                        onToggleConfirmPassword: () => setState(
                          () => _confirmPasswordVisible =
                              !_confirmPasswordVisible,
                        ),
                        onSubmit: _submit,
                        isLoading: _isSubmitting,
                        onForgotPassword: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const ForgotPasswordPage(),
                            ),
                          );
                        },
                        onGoogle: _signInWithGoogle, // 👈 Tersambung ke Google
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
}
