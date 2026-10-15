import 'package:flutter/material.dart';

import '../models/profile_data.dart';
import 'daily_summary_card_shell.dart';
import 'daily_summary_profile_panel.dart';

class DailySummaryProfileCard extends StatelessWidget {
  const DailySummaryProfileCard({this.profile, super.key});

  final ProfileData? profile;

  @override
  Widget build(BuildContext context) {
    final age = _age;
    final bmi = profile?.bmi;
    return DailySummaryCardShell(
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DailySummaryProfilePanel(
                  label: 'Usia',
                  value: age?.toString() ?? '—',
                  unit: age == null ? 'Belum diisi' : 'Tahun',
                  description:
                      'Faktor metabolisme &\nelastisitas sfingter\nesofagus.',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: DailySummaryProfilePanel(
                  label: 'BMI (IMT)',
                  value: bmi == null
                      ? '—'
                      : bmi.toStringAsFixed(1).replaceAll('.', ','),
                  unit: bmi == null ? 'Belum diisi' : _bmiLabel(bmi),
                  description:
                      'Peningkatan tekanan\nintra-abdomen dapat\nmemicu refluks.',
                  badge: bmi != null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int? get _age {
    final birthDate = profile?.birthDate;
    if (birthDate == null) return null;
    final today = DateTime.now();
    var age = today.year - birthDate.year;
    if (DateTime(today.year, birthDate.month, birthDate.day).isAfter(today)) {
      age--;
    }
    return age;
  }

  String _bmiLabel(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obesitas';
  }
}
