part of 'daily_log_step_two_view.dart';

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      backgroundColor: active ? AppColors.primary : Colors.white,
      foregroundColor: active ? Colors.white : AppColors.onSurfaceVariant,
      side: BorderSide(
        color: active ? AppColors.primary : AppColors.secondaryContainer,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(vertical: 9),
    ),
    child: Text(label, textAlign: TextAlign.center),
  );
}
