part of 'daily_log_step_two_view.dart';

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, this.size = 28});
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(icon, color: AppColors.primary, size: size * 0.62),
  );
}
