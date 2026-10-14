import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ContinueButton extends StatelessWidget {
  const ContinueButton({
    required this.enabled,
    required this.onPressed,
    super.key,
  });

  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: enabled
            ? AppColors.primaryContainer
            : AppColors.secondaryContainer,
        foregroundColor: enabled
            ? Colors.white
            : AppColors.secondary.withValues(alpha: 0.60),
        elevation: enabled ? 3 : 0,
        shape: const StadiumBorder(),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Lanjutkan'),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward, size: 20),
        ],
      ),
    ),
  );
}
