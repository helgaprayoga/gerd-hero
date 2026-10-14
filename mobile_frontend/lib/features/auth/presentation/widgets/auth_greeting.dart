import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/mascot.dart';

class AuthGreeting extends StatelessWidget {
  const AuthGreeting({
    required this.isRegister,
    super.key,
    this.title,
    this.subtitle,
  });

  final bool isRegister;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: const Mascot(animation: AlwaysStoppedAnimation(0)),
          ),
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              width: 16,
              height: 16,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primaryFixed,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite,
                size: 10,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        title ?? (isRegister ? 'Mulai Bersama Gery' : 'Selamat Datang Kembali'),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 4),
      Text(
        subtitle ??
            (isRegister
                ? 'Daftar untuk menjaga kenyamanan pencernaan setiap hari.'
                : 'Masuk untuk melanjutkan pemantauan kesehatan lambungmu.'),
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
      ),
    ],
  );
}
