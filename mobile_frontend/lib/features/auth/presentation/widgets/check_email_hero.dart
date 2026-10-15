import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/mascot.dart';

class CheckEmailHero extends StatelessWidget {
  const CheckEmailHero({required this.email, super.key});

  final String email;

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
      const SizedBox(height: 16),
      Text('Cek emailmu', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 4),
      Text.rich(
        TextSpan(
          text: 'Kami sudah mengirim tautan pengaturan ulang kata sandi ke ',
          children: [
            TextSpan(
              text: email,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                backgroundColor: AppColors.surfaceContainerLow,
              ),
            ),
            const TextSpan(text: '. Jika belum muncul, periksa folder spam.'),
          ],
        ),
        textAlign: TextAlign.center,
        softWrap: true,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
      ),
    ],
  );
}
