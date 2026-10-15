part of 'daily_log_step_two_view.dart';

class _MealTimeChip extends StatelessWidget {
  const _MealTimeChip({
    required this.label,
    required this.time,
    required this.onTap,
  });
  final String label;
  final String time;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(999),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAF8),
        border: Border.all(color: const Color(0xFFD8E9E4)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $time',
        style: const TextStyle(
          color: AppColors.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
