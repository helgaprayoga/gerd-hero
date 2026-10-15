import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CheckEmailActions extends StatelessWidget {
  const CheckEmailActions({
    required this.secondsLeft,
    required this.onOpenEmail,
    required this.onResend,
    required this.onBackToLogin,
    super.key,
    this.isResending = false,
  });

  final int secondsLeft;
  final VoidCallback onOpenEmail;
  final VoidCallback onResend;
  final VoidCallback onBackToLogin;
  final bool isResending;

  @override
  Widget build(BuildContext context) {
    final canResend = secondsLeft == 0 && !isResending;
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
                  Text('Saya sudah membuka email'),
                  SizedBox(width: 8),
                  Icon(Icons.info_outline, size: 20),
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
              child: isResending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Row(
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
