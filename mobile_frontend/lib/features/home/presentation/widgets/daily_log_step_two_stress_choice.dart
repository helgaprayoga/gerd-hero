part of 'daily_log_step_two_view.dart';

class _StressChoice extends StatelessWidget {
  const _StressChoice({
    required this.emoji,
    required this.score,
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String emoji;
  final int score;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 3),
      decoration: BoxDecoration(
        color: active ? AppColors.surfaceContainerLow : const Color(0xFFF8FCFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active ? AppColors.primary : AppColors.secondaryContainer,
          width: active ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          Text(
            '$score',
            style: TextStyle(
              color: active ? AppColors.primary : AppColors.onSurface,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                color: active ? AppColors.primary : AppColors.onSurfaceVariant,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
