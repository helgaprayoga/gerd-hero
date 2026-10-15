import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class GerdQResultAction extends StatelessWidget {
  const GerdQResultAction({required this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 48,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (onPressed == null)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          else ...[
            const Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('Ke Beranda'),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.home_outlined, size: 18),
          ],
        ],
      ),
    ),
  );
}
