part of 'daily_log_step_two_view.dart';

class _StepTwoHeader extends StatelessWidget {
  const _StepTwoHeader({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Kembali'),
          ),
          const Text(
            'LANGKAH 2 DARI 3',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      const Row(
        children: [
          Expanded(child: _ProgressSegment(active: false)),
          SizedBox(width: 6),
          Expanded(flex: 4, child: _ProgressSegment(active: true)),
          SizedBox(width: 6),
          Expanded(child: _ProgressSegment(active: false)),
        ],
      ),
      const SizedBox(height: 24),
      const Text(
        'Pemicu & Kebiasaan',
        style: TextStyle(
          color: AppColors.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}
