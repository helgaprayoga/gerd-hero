part of 'daily_log_step_one_view.dart';

class _StepProgress extends StatelessWidget {
  const _StepProgress();

  @override
  Widget build(BuildContext context) => const Row(
    children: [
      Expanded(
        flex: 4,
        child: SizedBox(
          height: 8,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
          ),
        ),
      ),
      SizedBox(width: 6),
      Expanded(
        child: SizedBox(
          height: 8,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
          ),
        ),
      ),
      SizedBox(width: 6),
      Expanded(
        child: SizedBox(
          height: 8,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
          ),
        ),
      ),
    ],
  );
}
