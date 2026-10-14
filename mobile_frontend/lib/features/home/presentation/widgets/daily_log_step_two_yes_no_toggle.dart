part of 'daily_log_step_two_view.dart';

class _YesNoToggle extends StatelessWidget {
  const _YesNoToggle({required this.selected, required this.onChanged});
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow,
      border: Border.all(color: AppColors.secondaryContainer),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        _ToggleChoice(
          label: 'Ya',
          active: selected,
          onTap: () => onChanged(true),
        ),
        _ToggleChoice(
          label: 'Tidak',
          active: !selected,
          onTap: () => onChanged(false),
        ),
      ],
    ),
  );
}
