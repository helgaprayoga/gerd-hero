import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({this.onProfileTap, super.key});

  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo, Dion',
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Selamat pagi, jaga kesehatan lambung',
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
      InkWell(
        onTap: onProfileTap,
        borderRadius: BorderRadius.circular(99),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Text(
            'DN',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    ],
  );
}
