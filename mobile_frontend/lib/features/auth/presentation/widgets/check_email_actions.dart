import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CheckEmailActions extends StatelessWidget {
  const CheckEmailActions({
    required this.secondsLeft,
    required this.onOpenEmail,
    required this.onResend,
    required this.onBackToLogin,
    super.key,
  });

  final int secondsLeft;
  final VoidCallback onOpenEmail;
  final VoidCallback onResend;
  final VoidCallback onBackToLogin;

  @override
  Widget build(BuildContext context) {
    final canResend = secondsLeft == 0;
    return Container(
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
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: onOpenEmail,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.white,
                elevation: 3,
                shape: const StadiumBorder(),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Buka Aplikasi Email'),
                  SizedBox(width: 8),
                  Icon(Icons.open_in_new, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: canResend ? onResend : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondaryContainer,
                foregroundColor: canResend
                    ? AppColors.primary
                    : AppColors.secondary,
                shape: const StadiumBorder(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mail, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    canResend
                        ? 'Kirim Ulang Email Sekarang'
                        : 'Kirim ulang dalam ${secondsLeft}s',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onBackToLogin,
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Kembali ke Masuk'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
