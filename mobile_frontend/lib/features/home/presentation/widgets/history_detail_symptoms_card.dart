import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'history_detail_card_shell.dart';

class HistoryDetailSymptomsCard extends StatelessWidget {
  const HistoryDetailSymptomsCard({
    required this.selected,
    required this.onChanged,
    required this.noteController,
    super.key,
  });

  final Set<String> selected;
  final ValueChanged<String> onChanged;
  final TextEditingController noteController;

  @override
  Widget build(BuildContext context) => HistoryDetailCardShell(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          number: '1',
          title: 'Gejala yang Dirasakan',
          subtitle: '${selected.length} gejala aktif dilaporkan hari ini',
        ),
        const SizedBox(height: 16),
        for (final symptom in _symptomDetails.where(
          (item) => selected.contains(item.title),
        )) ...[
          _ActiveSymptom(
            detail: symptom,
            selected: selected.contains(symptom.title),
            onTap: () => onChanged(symptom.title),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.expand_more, color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_symptomDetails.length - selected.length} Gejala Lainnya (Tidak Dialami Hari Ini)',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final item in _symptomDetails.where(
                    (item) => !selected.contains(item.title),
                  ))
                    _OtherChip(
                      label: item.title,
                      selected: selected.contains(item.title),
                      onTap: () => onChanged(item.title),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow.withValues(alpha: 0.6),
            border: Border.all(color: AppColors.secondaryContainer),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '✎  Deskripsi Gejala (Opsional)',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Tersimpan',
                    style: TextStyle(color: AppColors.secondary, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteController,
                maxLines: 3,
                maxLength: 250,
                decoration: InputDecoration(
                  hintText: 'Tambahkan catatan...',
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.secondaryContainer),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

const _symptomDetails =
    <({String title, String description, IconData icon, Color color})>[
      (
        title: 'Heartburn',
        description: 'Sensasi panas terbakar di ulu hati & dada',
        icon: Icons.local_fire_department_outlined,
        color: Color(0xFFFFDAD6),
      ),
      (
        title: 'Regurgitasi',
        description: 'Asam lambung atau rasa pahit naik ke mulut',
        icon: Icons.north_outlined,
        color: AppColors.tertiaryFixed,
      ),
      (
        title: 'Nyeri dada',
        description: 'Rasa tertekan di tengah tulang dada',
        icon: Icons.favorite_border,
        color: Color(0xFFFFDDB5),
      ),
      (
        title: 'Kesulitan menelan',
        description: 'Sensasi makanan terasa tersangkut di tenggorokan',
        icon: Icons.restaurant_outlined,
        color: Color(0xFFE1F1EE),
      ),
      (
        title: 'Kembung & gas',
        description: 'Perut terasa penuh, begah, atau banyak gas',
        icon: Icons.air,
        color: Color(0xFFFFDAD6),
      ),
      (
        title: 'Suara serak',
        description: 'Suara terdengar serak akibat iritasi tenggorokan',
        icon: Icons.graphic_eq,
        color: Color(0xFFE1F1EE),
      ),
      (
        title: 'Keringat dingin',
        description: 'Keringat dingin yang muncul bersama keluhan',
        icon: Icons.ac_unit_outlined,
        color: Color(0xFFFFDDB5),
      ),
      (
        title: 'Kram perut',
        description: 'Rasa kram atau mulas pada perut',
        icon: Icons.healing_outlined,
        color: Color(0xFFFFDDB5),
      ),
      (
        title: 'Ketidaknyamanan tenggorokan',
        description: 'Rasa seperti ada sesuatu yang mengganjal di tenggorokan',
        icon: Icons.record_voice_over_outlined,
        color: Color(0xFFE1F1EE),
      ),
    ];

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.number,
    required this.title,
    required this.subtitle,
  });
  final String number;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0x19006A61),
          shape: BoxShape.circle,
        ),
        child: Text(
          number,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: AppColors.secondary, fontSize: 12),
            ),
          ],
        ),
      ),
    ],
  );
}

class _ActiveSymptom extends StatelessWidget {
  const _ActiveSymptom({
    required this.detail,
    required this.selected,
    required this.onTap,
  });
  final ({String title, String description, IconData icon, Color color}) detail;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.20),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: detail.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              detail.icon,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail.description,
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary
                  : AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
        ],
      ),
    ),
  );
}

class _OtherChip extends StatelessWidget {
  const _OtherChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? AppColors.surfaceContainerHigh : Colors.white,
        border: Border.all(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.35)
              : AppColors.surfaceContainer,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? AppColors.primary : AppColors.secondary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
