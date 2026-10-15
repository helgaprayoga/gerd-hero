import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../utils/auth_validators.dart';
import 'auth_field.dart';
import 'password_strength_meter.dart';

class NewPasswordFormCard extends StatelessWidget {
  const NewPasswordFormCard({
    required this.formKey,
    required this.passwordController,
    required this.confirmController,
    required this.passwordVisible,
    required this.confirmVisible,
    required this.onPasswordChanged,
    required this.onConfirmChanged,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onSubmit,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool passwordVisible;
  final bool confirmVisible;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onConfirmChanged;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0C000000),
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthField(
            label: 'Kata sandi baru',
            hint: 'Minimal 8 karakter',
            icon: Icons.lock,
            controller: passwordController,
            onChanged: onPasswordChanged,
            obscureText: !passwordVisible,
            errorText: passwordError(passwordController.text),
            suffixIcon: IconButton(
              onPressed: onTogglePassword,
              icon: Icon(
                passwordVisible ? Icons.visibility_off : Icons.visibility,
                size: 20,
              ),
            ),
          ),
          PasswordStrengthMeter(password: passwordController.text),
          const SizedBox(height: 16),
          AuthField(
            label: 'Konfirmasi kata sandi baru',
            hint: 'Ketik ulang kata sandi',
            icon: Icons.lock,
            controller: confirmController,
            onChanged: onConfirmChanged,
            obscureText: !confirmVisible,
            errorText: confirmPasswordError(
              passwordController.text,
              confirmController.text,
            ),
            suffixIcon: IconButton(
              onPressed: onToggleConfirm,
              icon: Icon(
                confirmVisible ? Icons.visibility_off : Icons.visibility,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.white,
                elevation: 3,
                shape: const StadiumBorder(),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Simpan Kata Sandi'),
                  SizedBox(width: 8),
                  Icon(Icons.check, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
