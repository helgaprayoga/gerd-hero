part of 'daily_log_step_two_view.dart';

class _MealTimeCard extends StatelessWidget {
  const _MealTimeCard({
    required this.sameAsYesterday,
    required this.showComparison,
    required this.mealCount,
    required this.mealTimes,
    required this.onSameChanged,
    required this.onPickTime,
  });
  final bool sameAsYesterday;
  final bool showComparison;
  final int mealCount;
  final List<String> mealTimes;
  final ValueChanged<bool> onSameChanged;
  final ValueChanged<int> onPickTime;

  @override
  Widget build(BuildContext context) => _CardShell(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          icon: Icons.schedule,
          title: 'Jam makan',
          subtitle: 'Pola waktu asupan harian',
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              if (showComparison) ...[
                const Text(
                  'Jam makanmu masih di rentang kemarin (±1 jam)?',
                  style: TextStyle(color: AppColors.onSurface, fontSize: 12),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _ChoiceButton(
                        label: 'Ya, sama persis',
                        active: sameAsYesterday,
                        onTap: () => onSameChanged(true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ChoiceButton(
                        label: 'Ubah / Sesuaikan',
                        active: !sameAsYesterday,
                        onTap: () => onSameChanged(false),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (showComparison && sameAsYesterday)
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: [
              for (var i = 0; i < mealCount; i++)
                _MealTimeChip(
                  label: 'Jam makan ${i + 1}',
                  time: mealTimes[i],
                  onTap: null,
                ),
            ],
          )
        else
          Column(
            children: [
              for (var i = 0; i < mealCount; i++)
                _MealTimeRow(
                  label: 'Makan ke-${i + 1}',
                  time: mealTimes[i],
                  onTap: () => onPickTime(i),
                ),
            ],
          ),
      ],
    ),
  );
}
