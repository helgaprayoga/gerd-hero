import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/auth_mode.dart';
import 'auth_divider.dart';
import 'auth_field.dart';
import 'google_mark.dart';

class AuthFormCard extends StatelessWidget {
  const AuthFormCard({
    required this.formKey,
    required this.mode,
    required this.passwordVisible,
    required this.confirmPasswordVisible,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onSubmit,
    required this.onForgotPassword,
    required this.onGoogle,
    super.key,
    this.isLoading = false,
    this.emailController,
    this.passwordController,
    this.onEmailChanged,
    this.onPasswordChanged,
    this.emailError,
    this.passwordError,
  });

  final GlobalKey<FormState> formKey;
  final AuthMode mode;
  final bool passwordVisible;
  final bool confirmPasswordVisible;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;
  final VoidCallback onGoogle;
  final bool isLoading;
  final TextEditingController? emailController;
  final TextEditingController? passwordController;
  final ValueChanged<String>? onEmailChanged;
  final ValueChanged<String>? onPasswordChanged;
  final String? emailError;
  final String? passwordError;

  bool get isRegister => mode == AuthMode.register;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x10000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthField(
            label: 'Alamat Email',
            hint: 'nama@email.com',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            controller: emailController,
            onChanged: onEmailChanged,
            errorText: emailError,
          ),
          const SizedBox(height: 16),
          AuthField(
            label: 'Kata Sandi',
            hint: 'Minimal 8 karakter',
            icon: Icons.lock_outline,
            obscureText: !passwordVisible,
            controller: passwordController,
            onChanged: onPasswordChanged,
            errorText: passwordError,
            suffixIcon: IconButton(
              onPressed: onTogglePassword,
              icon: Icon(
                passwordVisible ? Icons.visibility_off : Icons.visibility,
                size: 20,
              ),
            ),
          ),
          if (isRegister) ...[
            const SizedBox(height: 16),
            AuthField(
              label: 'Konfirmasi Kata Sandi',
              hint: 'Ketik ulang kata sandi',
              icon: Icons.verified_user_outlined,
              obscureText: !confirmPasswordVisible,
              suffixIcon: IconButton(
                onPressed: onToggleConfirmPassword,
                icon: Icon(
                  confirmPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                  size: 20,
                ),
              ),
            ),
          ],
          if (!isRegister)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onForgotPassword,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                ),
                child: const Text('Lupa kata sandi?'),
              ),
            ),
          const SizedBox(height: 4),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: isLoading ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: const StadiumBorder(),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(isRegister ? 'Daftar Sekarang' : 'Masuk'),
                        const SizedBox(width: 8),
                        Icon(
                          isRegister ? Icons.check_circle : Icons.arrow_forward,
                          size: 18,
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),
          const AuthDivider(),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: FilledButton.tonal(
              onPressed: onGoogle,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.surfaceContainerLow,
                foregroundColor: AppColors.onSurface,
                shape: const StadiumBorder(),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GoogleMark(),
                  SizedBox(width: 12),
                  Text('Lanjutkan dengan Google'),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
