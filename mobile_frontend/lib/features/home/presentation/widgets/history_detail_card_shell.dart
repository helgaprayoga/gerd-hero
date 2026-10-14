import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HistoryDetailCardShell extends StatelessWidget {
  const HistoryDetailCardShell({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0C000000),
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ],
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.04)),
    ),
    child: child,
  );
}
