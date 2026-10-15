part of 'daily_log_step_two_view.dart';

class _StressCard extends StatelessWidget {
  const _StressCard({required this.selected, required this.onChanged});
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => _CardShell(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          icon: Icons.psychology_outlined,
          title: 'Tingkat stres',
          subtitle: 'Stres dapat memicu ketegangan lambung & refluks',
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            for (final (index, item) in [
              (0, ('😌', 'Rileks')),
              (1, ('🙂', 'Tenang')),
              (2, ('😐', 'Sedang')),
              (3, ('😟', 'Tinggi')),
              (4, ('😫', 'Berat')),
            ]) ...[
              if (index > 0) const SizedBox(width: 5),
              Expanded(
                child: _StressChoice(
                  emoji: item.$1,
                  score: _stressIndex(item.$2),
                  label: item.$2,
                  active: selected == _stressIndex(item.$2),
                  onTap: () => onChanged(_stressIndex(item.$2)),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Tingkat stres ${_stressLabel(selected).toLowerCase()}. Relaksasi pernapasan 3 menit dapat membantu meredakan ketegangan diafragma.',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}
