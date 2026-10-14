import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class GerdQResultAction extends StatelessWidget {
  const GerdQResultAction({required this.onPressed, super.key});

  final VoidCallback onPressed;

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
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Ke Beranda'),
          SizedBox(width: 8),
          Icon(Icons.home_outlined, size: 18),
        ],
      ),
    ),
  );
}
