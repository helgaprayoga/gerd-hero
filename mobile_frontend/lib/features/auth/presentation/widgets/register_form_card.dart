import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'auth_divider.dart';
import 'auth_field.dart';
import 'google_mark.dart';
import 'password_strength_meter.dart';

class RegisterFormCard extends StatelessWidget {
  const RegisterFormCard({
    required this.formKey,
    required this.passwordVisible,
    required this.confirmPasswordVisible,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onSubmit,
    required this.onGoogle,
    super.key,
    this.isLoading = false,
    this.emailController,
    this.passwordController,
    this.confirmPasswordController,
    this.onEmailChanged,
    this.onPasswordChanged,
    this.onConfirmPasswordChanged,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
  });

  final GlobalKey<FormState> formKey;
  final bool passwordVisible;
  final bool confirmPasswordVisible;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final VoidCallback onSubmit;
  final VoidCallback onGoogle;
  final bool isLoading;
  final TextEditingController? emailController;
  final TextEditingController? passwordController;
  final TextEditingController? confirmPasswordController;
  final ValueChanged<String>? onEmailChanged;
  final ValueChanged<String>? onPasswordChanged;
  final ValueChanged<String>? onConfirmPasswordChanged;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;

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
            label: 'Email',
            hint: 'nama@email.com',
            icon: Icons.mail,
            keyboardType: TextInputType.emailAddress,
            controller: emailController,
            onChanged: onEmailChanged,
            errorText: emailError,
          ),
          const SizedBox(height: 16),
          AuthField(
            label: 'Kata sandi',
            hint: 'Minimal 8 karakter',
            icon: Icons.lock,
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
          const SizedBox(height: 8),
          PasswordStrengthMeter(password: passwordController?.text ?? ''),
          const SizedBox(height: 16),
          AuthField(
            label: 'Konfirmasi kata sandi',
            hint: 'Ketik ulang kata sandi',
            icon: Icons.lock,
            obscureText: !confirmPasswordVisible,
            controller: confirmPasswordController,
            onChanged: onConfirmPasswordChanged,
            suffixIcon: IconButton(
              onPressed: onToggleConfirmPassword,
              icon: Icon(
                confirmPasswordVisible
                    ? Icons.visibility_off
                    : Icons.visibility,
                size: 20,
              ),
            ),
            errorText: confirmPasswordError,
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
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Daftar'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
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
                  Text('Daftar dengan Google'),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
