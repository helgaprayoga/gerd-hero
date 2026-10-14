import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HomeNavItem extends StatelessWidget {
  const HomeNavItem({
    required this.icon,
    required this.label,
    this.active = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        color: active ? AppColors.primary : AppColors.secondary,
        size: 22,
      ),
      const SizedBox(height: 3),
      Text(
        label,
        style: TextStyle(
          color: active ? AppColors.primary : AppColors.secondary,
          fontSize: 11,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    ],
  );
}
