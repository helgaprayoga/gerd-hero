import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'history_detail_card_shell.dart';

class HistoryDetailWellnessCard extends StatefulWidget {
  const HistoryDetailWellnessCard({
    required this.mealCount,
    required this.onMealCountChanged,
    required this.mealTimes,
    required this.onPickMealTime,
    required this.stress,
    required this.onStressChanged,
    required this.tookMedicine,
    required this.onMedicineChanged,
    required this.sleepTime,
    required this.wakeTime,
    required this.onPickSleep,
    required this.onPickWake,
    required this.onChanged,
    super.key,
  });

  final int mealCount;
  final ValueChanged<int> onMealCountChanged;
  final List<String> mealTimes;
  final Future<void> Function(int index) onPickMealTime;
  final double stress;
  final ValueChanged<double> onStressChanged;
  final bool tookMedicine;
  final ValueChanged<bool> onMedicineChanged;
  final TimeOfDay sleepTime;
  final TimeOfDay wakeTime;
  final VoidCallback onPickSleep;
  final VoidCallback onPickWake;
  final VoidCallback onChanged;

  @override
  State<HistoryDetailWellnessCard> createState() =>
      _HistoryDetailWellnessCardState();
}

class _HistoryDetailWellnessCardState extends State<HistoryDetailWellnessCard> {
  final _medicineController = TextEditingController();
  bool _showMedicineForm = false;
  final _medicines = <_Medicine>[
    const _Medicine('Omeprazole\n20mg', '30 menit sebelum\nsarapan pagi'),
    const _Medicine(
      'Antasida\nDoen 500mg',
      '1 tablet kunyah\nsaat heartburn (pkl\n14:15)',
    ),
  ];

  @override
  void dispose() {
    _medicineController.dispose();
    super.dispose();
  }

  void _addMedicine() {
    final name = _medicineController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _medicines.add(_Medicine(name, 'Waktu konsumsi belum ditambahkan'));
      _medicineController.clear();
      _showMedicineForm = false;
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) => HistoryDetailCardShell(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _NumberBadge(number: '3'),
            const SizedBox(width: 8),
            const Expanded(
              child: _Heading(
                title: 'Kebiasaan Harian',
                subtitle: 'Jadwal makan, stres, tidur & obat',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _Panel(
          child: Row(
            children: [
              const Icon(Icons.restaurant_outlined, color: AppColors.primary),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Frekuensi Makan Berat',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Jumlah sesi santap utama',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _Stepper(
                value: widget.mealCount,
                onChanged: widget.onMealCountChanged,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Panel(
          child: _MealSchedule(
            times: widget.mealTimes,
            onPick: widget.onPickMealTime,
          ),
        ),
        const SizedBox(height: 12),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tingkat Beban Stres',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${widget.stress.round()} ${_stressLabel(widget.stress)}',
                    style: TextStyle(
                      color: _stressColor(widget.stress),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _StressScale(
                value: widget.stress,
                onChanged: widget.onStressChanged,
              ),
              const SizedBox(height: 8),
              const _InfoRow(
                icon: Icons.air,
                text:
                    'Tips: Lakukan pernapasan diafragma 5 menit\nuntuk merelaksasi LES lambung.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tidur Semalam',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _sleepDuration(widget.sleepTime, widget.wakeTime),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SleepTime(
                      label: 'Jam Mulai Tidur',
                      time: _formatTime(widget.sleepTime),
                      onTap: widget.onPickSleep,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SleepTime(
                      label: 'Jam Bangun',
                      time: _formatTime(widget.wakeTime),
                      onTap: widget.onPickWake,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Konsumsi Obat\nLambung',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.38,
                    ),
                  ),
                  _YesNo(
                    value: widget.tookMedicine,
                    onChanged: widget.onMedicineChanged,
                  ),
                ],
              ),
              if (widget.tookMedicine) ...[
                const SizedBox(height: 10),
                for (var index = 0; index < _medicines.length; index++) ...[
                  _MedicineRow(
                    medicine: _medicines[index],
                    onRemove: () {
                      setState(() => _medicines.removeAt(index));
                      widget.onChanged();
                    },
                  ),
                  const SizedBox(height: 8),
                ],
                OutlinedButton.icon(
                  onPressed: () =>
                      setState(() => _showMedicineForm = !_showMedicineForm),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Tambah Obat Lainnya'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                if (_showMedicineForm) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _medicineController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Nama obat',
                      hintText: 'Contoh: Famotidine 20mg',
                      suffixIcon: IconButton(
                        onPressed: _addMedicine,
                        icon: const Icon(Icons.check),
                        color: AppColors.primary,
                        tooltip: 'Tambah obat',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (_) => _addMedicine(),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: FilledButton.icon(
                      onPressed: _addMedicine,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Tambah Obat'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

String _stressLabel(double value) => const {
  1: 'Rileks',
  2: 'Tenang',
  3: 'Sedang',
  4: 'Tinggi',
  5: 'Berat',
}[value.round()]!;
Color _stressColor(double value) => const {
  1: Color(0xFF2BA89A),
  2: Color(0xFF059669),
  3: Color(0xFFD08800),
  4: Color(0xFFD97706),
  5: Color(0xFFBA1A1A),
}[value.round()]!;

String _formatTime(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

String _sleepDuration(TimeOfDay sleep, TimeOfDay wake) {
  var minutes =
      (wake.hour * 60 + wake.minute) - (sleep.hour * 60 + sleep.minute);
  if (minutes <= 0) minutes += 24 * 60;
  return '${minutes ~/ 60}j ${minutes % 60}m';
}

class _Medicine {
  const _Medicine(this.name, this.description);
  final String name;
  final String description;
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
    ),
    child: child,
  );
}

class _NumberBadge extends StatelessWidget {
  const _NumberBadge({required this.number});
  final String number;
  @override
  Widget build(BuildContext context) => Container(
    width: 32,
    height: 32,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      color: Color(0x19006A61),
      shape: BoxShape.circle,
    ),
    child: Text(
      number,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _Heading extends StatelessWidget {
  const _Heading({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.secondary,
          fontSize: 12,
          height: 1.5,
        ),
      ),
    ],
  );
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.secondaryContainer),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        IconButton(
          onPressed: value > 1 ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove, size: 16),
          constraints: const BoxConstraints.tightFor(width: 22, height: 22),
          padding: EdgeInsets.zero,
        ),
        Text(
          '${value}x',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        IconButton(
          onPressed: () => onChanged(value + 1),
          icon: const Icon(Icons.add, size: 16),
          constraints: const BoxConstraints.tightFor(width: 22, height: 22),
          padding: EdgeInsets.zero,
        ),
      ],
    ),
  );
}

class _MealSchedule extends StatelessWidget {
  const _MealSchedule({required this.times, required this.onPick});
  final List<String> times;
  final Future<void> Function(int) onPick;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Jadwal & Jam Makan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Jeda Tidur Aman',
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      LayoutBuilder(
        builder: (context, constraints) {
          final width = (constraints.maxWidth - 16) / 3;
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var index = 0; index < times.length; index++)
                SizedBox(
                  width: width,
                  child: _MealTime(
                    label: 'Makan ${index + 1}',
                    time: times[index],
                    name: _mealName(index),
                    onTap: () => onPick(index),
                  ),
                ),
            ],
          );
        },
      ),
      const SizedBox(height: 10),
      const _InfoRow(
        icon: Icons.bedtime_outlined,
        text:
            'Jeda makan malam hingga tidur: 4.5 Jam\n(rekomendasi medis min. 3 jam).',
      ),
    ],
  );
}

String _mealName(int index) => index == 0
    ? 'Sarapan'
    : index == 1
    ? 'Siang'
    : index == 2
    ? 'Malam'
    : 'Sesi tambahan';

class _MealTime extends StatelessWidget {
  const _MealTime({
    required this.label,
    required this.time,
    required this.name,
    required this.onTap,
  });
  final String label;
  final String time;
  final String name;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.secondaryContainer),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.secondary, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          Text(
            name,
            style: const TextStyle(color: AppColors.secondary, fontSize: 12),
          ),
          const Icon(Icons.access_time, color: AppColors.primary, size: 15),
        ],
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.secondaryContainer),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
}

class _StressScale extends StatelessWidget {
  const _StressScale({required this.value, required this.onChanged});
  final double value;
  final ValueChanged<double> onChanged;
  static const _items = [('😊', 1), ('🙂', 2), ('😐', 3), ('🙁', 4), ('😫', 5)];
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        for (final item in _items)
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(item.$2.toDouble()),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: value.round() == item.$2
                      ? _stressColor(value)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(item.$1, style: const TextStyle(fontSize: 18)),
                    Text(
                      '${item.$2}',
                      style: TextStyle(
                        color: value.round() == item.$2
                            ? Colors.white
                            : AppColors.secondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _SleepTime extends StatelessWidget {
  const _SleepTime({
    required this.label,
    required this.time,
    required this.onTap,
  });
  final String label;
  final String time;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.secondaryContainer),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.secondary, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  time,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(Icons.access_time, color: AppColors.primary, size: 18),
            ],
          ),
        ],
      ),
    ),
  );
}

class _YesNo extends StatelessWidget {
  const _YesNo({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        _SmallChoice(label: 'Ya', active: value, onTap: () => onChanged(true)),
        _SmallChoice(
          label: 'Tidak',
          active: !value,
          onTap: () => onChanged(false),
        ),
      ],
    ),
  );
}

class _SmallChoice extends StatelessWidget {
  const _SmallChoice({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : AppColors.secondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

class _MedicineRow extends StatelessWidget {
  const _MedicineRow({required this.medicine, required this.onRemove});
  final _Medicine medicine;
  final VoidCallback onRemove;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.secondaryContainer),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFFFDDB5),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: const Icon(
            Icons.medication_outlined,
            color: AppColors.onSurfaceVariant,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                medicine.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.38,
                ),
              ),
              Text(
                medicine.description,
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Diminum',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close, size: 16),
              color: AppColors.secondary,
              tooltip: 'Hapus obat',
              constraints: const BoxConstraints.tightFor(width: 28, height: 28),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ],
    ),
  );
}
