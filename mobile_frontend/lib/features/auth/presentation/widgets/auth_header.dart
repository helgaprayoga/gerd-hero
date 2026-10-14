import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.94),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            tooltip: 'Kembali',
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.onSurfaceVariant,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 44, height: 44),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Akun Gerdhero',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, color: Colors.white, size: 18),
          ),
        ],
      ),
    ),
  );
}
