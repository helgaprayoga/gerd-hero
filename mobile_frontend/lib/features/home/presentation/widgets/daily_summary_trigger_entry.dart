import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class DailySummaryTriggerEntry extends StatelessWidget {
  const DailySummaryTriggerEntry({
    required this.emoji,
    required this.title,
    required this.description,
    this.subtitle,
    super.key,
  });

  final String emoji;
  final String title;
  final String? subtitle;
  final String description;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!),
              ],
              const SizedBox(height: 6),
              Text(description),
            ],
          ),
        ),
      ],
    ),
  );
}
