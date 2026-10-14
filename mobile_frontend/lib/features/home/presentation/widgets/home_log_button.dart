import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HomeLogButton extends StatelessWidget {
  const HomeLogButton({required this.onPressed, super.key});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 56,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        elevation: 4,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_note, size: 22),
          SizedBox(width: 8),
          Text('Isi Log Harian'),
        ],
      ),
    ),
  );
}
