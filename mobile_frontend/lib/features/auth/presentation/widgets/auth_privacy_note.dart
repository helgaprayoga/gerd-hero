import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AuthPrivacyNote extends StatelessWidget {
  const AuthPrivacyNote({super.key});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.lock_clock, color: AppColors.primary, size: 16),
      const SizedBox(width: 8),
      Flexible(
        child: Text(
          'Data catatan kesehatanmu dienkripsi dan 100% terlindungi secara privat.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ),
    ],
  );
}
