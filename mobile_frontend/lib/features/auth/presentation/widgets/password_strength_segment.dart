import 'package:flutter/material.dart';

class PasswordStrengthSegment extends StatelessWidget {
  const PasswordStrengthSegment({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    height: 6,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(999),
    ),
  );
}
