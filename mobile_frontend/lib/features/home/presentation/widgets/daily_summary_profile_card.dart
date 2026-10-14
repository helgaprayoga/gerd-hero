import 'package:flutter/material.dart';

import 'daily_summary_card_shell.dart';
import 'daily_summary_profile_panel.dart';

class DailySummaryProfileCard extends StatelessWidget {
  const DailySummaryProfileCard({super.key});

  @override
  Widget build(BuildContext context) => DailySummaryCardShell(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Diri yang Mendukung',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DailySummaryProfilePanel(
                label: 'Usia',
                value: '28',
                unit: 'Tahun',
                description:
                    'Faktor metabolisme &\nelastisitas sfingter\nesofagus.',
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: DailySummaryProfilePanel(
                label: 'BMI (IMT)',
                value: '27,1',
                unit: 'Overweight',
                description:
                    'Peningkatan tekanan\nintra-abdomen dapat\nmemicu refluks.',
                badge: true,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
