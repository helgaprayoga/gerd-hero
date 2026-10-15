import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class GerdQHeader extends StatelessWidget {
  const GerdQHeader({required this.onSkip, this.onBack, super.key});

  final VoidCallback onSkip;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.90),
        border: const Border(bottom: BorderSide(color: Color(0x0C006A61))),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: onBack == null ? 16 : 56,
            right: 72,
            child: const Text(
              'Kuesioner GERD-Q',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ),
          if (onBack != null)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: onBack,
                tooltip: 'Kembali ke profil',
                icon: const Icon(Icons.arrow_back),
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: onSkip, child: const Text('Lewati')),
          ),
        ],
      ),
    ),
  );
}
