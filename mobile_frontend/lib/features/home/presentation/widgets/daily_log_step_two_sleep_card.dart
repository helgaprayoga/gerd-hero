part of 'daily_log_step_two_view.dart';

class _SleepCard extends StatelessWidget {
  const _SleepCard({
    required this.sleepTime,
    required this.wakeTime,
    required this.onPickSleep,
    required this.onPickWake,
    required this.durationLabel,
  });
  final TimeOfDay sleepTime;
  final TimeOfDay wakeTime;
  final VoidCallback onPickSleep;
  final VoidCallback onPickWake;
  final String durationLabel;

  @override
  Widget build(BuildContext context) => _CardShell(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          icon: Icons.bedtime_outlined,
          title: 'Tidur semalam',
          subtitle: 'Kualitas durasi istirahat malam',
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _TimeBox(
                label: 'Jam tidur',
                value: sleepTime.format(context),
                onTap: onPickSleep,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TimeBox(
                label: 'Jam bangun',
                value: wakeTime.format(context),
                onTap: onPickWake,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _InfoPill(label: 'Durasi Tidur:', value: durationLabel),
      ],
    ),
  );
}
