import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HomeCardIcon extends StatelessWidget {
  const HomeCardIcon({required this.icon, this.large = false, super.key});

  final IconData icon;
  final bool large;

  @override
  Widget build(BuildContext context) => Container(
    width: large ? 76 : 40,
    height: large ? 76 : 40,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(large ? 20 : 12),
    ),
    child: Icon(icon, color: AppColors.primary, size: large ? 38 : 21),
  );
}
