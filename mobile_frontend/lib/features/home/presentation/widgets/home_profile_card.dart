import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'home_card_icon.dart';
import 'home_card_shell.dart';

class HomeProfileCard extends StatelessWidget {
  const HomeProfileCard({
    required this.onPressed,
    required this.completion,
    super.key,
  });

  final VoidCallback onPressed;
  final double completion;

  @override
  Widget build(BuildContext context) => HomeCardShell(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeCardIcon(icon: Icons.person_add_alt_1),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lengkapi profilmu: kebiasaan, riwayat, & obat rutin',
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 16,
                  height: 1.38,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Bantu Gerdie memberikan analisis pemicu dan panduan jam makan yang lebih akurat.',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Status Pengisian Data', style: _SmallTextStyle()),
                  Text(
                    '${(completion * 100).round()}% Selesai',
                    style: const _SmallAccentStyle(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: completion,
                minHeight: 8,
                borderRadius: BorderRadius.all(Radius.circular(999)),
                backgroundColor: AppColors.secondaryContainer,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryContainer,
                ),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonal(
                  onPressed: onPressed,
                  style: FilledButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    backgroundColor: AppColors.secondaryContainer,
                  ),
                  child: const Text('Lengkapi'),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SmallTextStyle extends TextStyle {
  const _SmallTextStyle()
    : super(
        color: AppColors.onSurfaceVariant,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      );
}

class _SmallAccentStyle extends TextStyle {
  const _SmallAccentStyle()
    : super(
        color: AppColors.primary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      );
}
