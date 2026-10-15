part of 'daily_log_step_two_view.dart';

class _FrequencyCard extends StatelessWidget {
  const _FrequencyCard({
    required this.count,
    required this.dateLabel,
    required this.onChanged,
  });
  final int count;
  final String dateLabel;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => _CardShell(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          icon: Icons.repeat,
          title: 'Frekuensi makan',
          subtitle: 'Jumlah waktu makan berat $dateLabel',
        ),
        const SizedBox(height: 14),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: count > 1 ? () => onChanged(count - 1) : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Column(
                children: [
                  Text(
                    '${count}x',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'makan berat',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => onChanged(count + 1),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pilih jumlah makan berat yang kamu lakukan $dateLabel.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}
