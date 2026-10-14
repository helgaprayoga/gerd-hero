import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/auth_mode.dart';
import 'auth_mode_button.dart';

class AuthModeSwitcher extends StatelessWidget {
  const AuthModeSwitcher({
    required this.mode,
    required this.onChanged,
    super.key,
  });

  final AuthMode mode;
  final ValueChanged<AuthMode> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      children: [
        AuthModeButton(
          label: 'Masuk',
          selected: mode == AuthMode.login,
          onTap: () => onChanged(AuthMode.login),
        ),
        AuthModeButton(
          label: 'Daftar',
          selected: mode == AuthMode.register,
          onTap: () => onChanged(AuthMode.register),
        ),
      ],
    ),
  );
}
