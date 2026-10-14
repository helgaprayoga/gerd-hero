import 'package:flutter/material.dart';

class HistoryTriggerBox extends StatelessWidget {
  const HistoryTriggerBox({required this.triggers, super.key});

  final List<String> triggers;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF8EC),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFFFE4B5)),
    ),
    child: Wrap(
      spacing: 14,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Faktor Pemicu',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        ),
        for (final trigger in triggers)
          Text(trigger, style: const TextStyle(fontSize: 12)),
      ],
    ),
  );
}
