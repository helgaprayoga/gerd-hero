import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ReportsPreviewButton extends StatelessWidget {
  const ReportsPreviewButton({required this.onPressed, super.key});
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 48,
    child: FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
      label: const Text('Pratinjau laporan klinis'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        elevation: 3,
      ),
    ),
  );
}
