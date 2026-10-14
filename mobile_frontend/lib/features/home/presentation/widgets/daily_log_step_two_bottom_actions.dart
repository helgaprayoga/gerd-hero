part of 'daily_log_step_two_view.dart';

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.onBack, required this.onContinue});
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    decoration: const BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Color(0x0C000000),
          blurRadius: 20,
          offset: Offset(0, -4),
        ),
      ],
    ),
    child: Row(
      children: [
        OutlinedButton(
          onPressed: onBack,
          style: OutlinedButton.styleFrom(minimumSize: const Size(96, 48)),
          child: const Text('Kembali'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: onContinue,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(0, 48),
              shape: const StadiumBorder(),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Simpan & Lanjutkan'),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
