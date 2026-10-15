import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'password_strength_segment.dart';

class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({required this.password, super.key});

  final String password;

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final score = _score;
    final strengthColor = score == 1
        ? AppColors.error
        : score == 2
        ? AppColors.tertiary
        : AppColors.primary;

    return Column(
      children: [
        Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index == 2 ? 0 : 6),
                child: PasswordStrengthSegment(
                  color: index < score
                      ? strengthColor
                      : AppColors.surfaceContainerHigh,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'Minimal 8 karakter, kombinasi huruf dan angka.',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: strengthColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  int get _score {
    var score = password.length >= 8 ? 1 : 0;
    if (RegExp(r'[A-Za-z]').hasMatch(password) &&
        RegExp(r'\d').hasMatch(password)) {
      score = 2;
    }
    if (password.length >= 12 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      score = 3;
    }
    return score.clamp(1, 3);
  }

  String get _label => switch (_score) {
    1 => 'Rendah',
    2 => 'Sedang',
    _ => 'Tinggi',
  };
}
