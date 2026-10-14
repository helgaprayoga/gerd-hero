import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../utils/auth_validators.dart';
import 'auth_field.dart';

class ForgotPasswordFormCard extends StatelessWidget {
  const ForgotPasswordFormCard({
    required this.formKey,
    required this.emailController,
    required this.onEmailChanged,
    required this.onSubmit,
    required this.onBackToLogin,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final ValueChanged<String> onEmailChanged;
  final VoidCallback onSubmit;
  final VoidCallback onBackToLogin;

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
            errorText: emailError(emailController.text),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: const StadiumBorder(),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Kirim Tautan'),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: onBackToLogin,
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Kembali ke Masuk'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ],
      ),
    ),
  );
}
