part of 'daily_log_step_two_view.dart';

class _FoodRow extends StatelessWidget {
  const _FoodRow({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onChanged,
  });
  final String emoji;
  final String label;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.onSurface, fontSize: 12),
          ),
        ),
        _YesNoToggle(selected: selected, onChanged: onChanged),
      ],
    ),
  );
}
