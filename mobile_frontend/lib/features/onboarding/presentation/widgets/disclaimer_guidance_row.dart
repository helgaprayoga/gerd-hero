import 'package:flutter/material.dart';

import 'disclaimer_card_text.dart';

class DisclaimerGuidanceRow extends StatelessWidget {
  const DisclaimerGuidanceRow({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.body,
    super.key,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        margin: const EdgeInsets.only(top: 2),
        decoration: BoxDecoration(
          color: iconBackground,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: DisclaimerCardText(title: title, body: body),
      ),
    ],
  );
}
