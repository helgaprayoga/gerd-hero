import 'package:flutter/material.dart';

class GerdQDisclaimer extends StatelessWidget {
  const GerdQDisclaimer({super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xE5F1F5F9),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xCCE2E8F0)),
    ),
    child: const Row(
      children: [
        Icon(Icons.info_outline, color: Color(0xFF475569), size: 18),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Hasil ini bukan diagnosis dan tidak menggantikan pemeriksaan dokter.',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 11,
              height: 1.38,
            ),
          ),
        ),
      ],
    ),
  );
}
