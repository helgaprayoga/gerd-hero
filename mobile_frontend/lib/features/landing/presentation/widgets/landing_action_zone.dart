import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class LandingActionZone extends StatelessWidget {
  const LandingActionZone({required this.onPrimaryTap, super.key});

  final VoidCallback onPrimaryTap;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton(
          onPressed: onPrimaryTap,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: Colors.white,
            elevation: 3,
            shadowColor: const Color(0x33000000),
            shape: const StadiumBorder(),
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Mulai'),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 18),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'Bukan pengganti diagnosis klinis dokter darurat.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.outline,
          fontSize: 10,
          height: 1.1,
        ),
      ),
    ],
  );
}
