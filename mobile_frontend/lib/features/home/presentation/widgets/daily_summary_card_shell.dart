import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class DailySummaryCardShell extends StatelessWidget {
  const DailySummaryCardShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.10)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A006A61),
          blurRadius: 18,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: child,
  );
}
