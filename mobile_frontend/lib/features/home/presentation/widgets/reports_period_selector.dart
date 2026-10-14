import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ReportsPeriodSelector extends StatelessWidget {
  const ReportsPeriodSelector({
    required this.selected,
    required this.onChanged,
    super.key,
  });
  final int selected;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      children: [
        _Tab(
          label: '7 Hari',
          value: 7,
          selected: selected,
          onChanged: onChanged,
        ),
        _Tab(
          label: '30 Hari',
          value: 30,
          selected: selected,
          onChanged: onChanged,
        ),
        _Tab(
          label: 'Kustom',
          value: 0,
          selected: selected,
          onChanged: onChanged,
        ),
      ],
    ),
  );
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.value,
    required this.selected,
    required this.onChanged,
  });
  final String label;
  final int value;
  final int selected;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected == value
              ? AppColors.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected == value
                ? Colors.white
                : AppColors.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}
