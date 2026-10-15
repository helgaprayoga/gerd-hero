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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Faktor Pemicu',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final trigger in triggers)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFFFE4B5)),
                ),
                child: Text(trigger, style: const TextStyle(fontSize: 12)),
              ),
          ],
        ),
      ],
    ),
  );
}
