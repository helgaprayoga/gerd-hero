part of 'daily_log_step_two_view.dart';

class _ProgressSegment extends StatelessWidget {
  const _ProgressSegment({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) => Container(
    height: 8,
    decoration: BoxDecoration(
      color: active ? AppColors.primary : AppColors.secondaryContainer,
      borderRadius: BorderRadius.circular(999),
    ),
  );
}
