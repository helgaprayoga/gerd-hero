import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/daily_log_draft.dart';

part 'daily_log_step_two_step_two_header.dart';
part 'daily_log_step_two_progress_segment.dart';
part 'daily_log_step_two_section_title.dart';
part 'daily_log_step_two_food_card.dart';
part 'daily_log_step_two_food_row.dart';
part 'daily_log_step_two_yes_no_toggle.dart';
part 'daily_log_step_two_toggle_choice.dart';
part 'daily_log_step_two_frequency_card.dart';
part 'daily_log_step_two_meal_time_card.dart';
part 'daily_log_step_two_choice_button.dart';
part 'daily_log_step_two_meal_time_row.dart';
part 'daily_log_step_two_meal_time_chip.dart';
part 'daily_log_step_two_stress_card.dart';
part 'daily_log_step_two_stress_choice.dart';
part 'daily_log_step_two_sleep_card.dart';
part 'daily_log_step_two_time_box.dart';
part 'daily_log_step_two_medicine_card.dart';
part 'daily_log_step_two_medicine_entry.dart';
part 'daily_log_step_two_info_pill.dart';
part 'daily_log_step_two_card_shell.dart';
part 'daily_log_step_two_icon_box.dart';
part 'daily_log_step_two_bottom_actions.dart';

class DailyLogStepTwoView extends StatefulWidget {
  const DailyLogStepTwoView({
    this.draft,
    this.dateLabel = 'hari ini',
    this.initialSameAsYesterday = true,
    this.onContinue,
    super.key,
  });

  final DailyLogDraft? draft;
  final bool initialSameAsYesterday;
  final String dateLabel;
  final ValueChanged<DailyLogDraft>? onContinue;

  @override
  State<DailyLogStepTwoView> createState() => _DailyLogStepTwoViewState();
}

class _DailyLogStepTwoViewState extends State<DailyLogStepTwoView> {
  late bool _sameAsYesterday;
  late DailyLogDraft _draft;
  int _mealCount = 3;
  int _stressLevel = 3;
  bool _tookMedicine = true;
  final _medicineController = TextEditingController();
  bool _showMedicineForm = false;
  final _medicines = <String>['Omeprazole 20mg|Sebelum makan'];
  final _foods = <String, bool>{
    'Makanan pedas': true,
    'Makanan berlemak / gorengan': false,
    'Makanan asam (sitrus/tomat/cuka)': true,
    'Minuman berkafein (kopi/teh)': true,
    'Makanan / minuman bersoda': false,
  };
  final _mealTimes = <String>['07:30', '12:30', '19:00'];
  TimeOfDay _sleepTime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 6, minute: 30);
  String _medicineTiming = 'Sebelum Makan';

  @override
  void initState() {
    super.initState();
    _sameAsYesterday = widget.initialSameAsYesterday;
    _draft = widget.draft ?? DailyLogDraft();
  }

  @override
  void dispose() {
    _medicineController.dispose();
    super.dispose();
  }

  Future<void> _pickMealTime(int index) async {
    final parsed = _mealTimes[index] == '--:--'
        ? const TimeOfDay(hour: 12, minute: 0)
        : _parseTime(_mealTimes[index]);
    final picked = await showTimePicker(context: context, initialTime: parsed);
    if (picked != null) {
      setState(() => _mealTimes[index] = _formatTime(picked));
    }
  }

  void _setMealCount(int count) {
    setState(() {
      _mealCount = count;
      while (_mealTimes.length < count) {
        _mealTimes.add('--:--');
      }
      while (_mealTimes.length > count) {
        _mealTimes.removeLast();
      }
    });
  }

  void _addMedicine() {
    final name = _medicineController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _medicines.add('$name|$_medicineTiming');
      _medicineController.clear();
      _showMedicineForm = false;
    });
  }

  Future<void> _pickSleepTime({required bool sleep}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: sleep ? _sleepTime : _wakeTime,
    );
    if (picked != null) {
      setState(() {
        if (sleep) {
          _sleepTime = picked;
        } else {
          _wakeTime = picked;
        }
      });
    }
  }

  void _continue() {
    const triggerNames = {
      'Makanan pedas': 'Pedas',
      'Makanan berlemak / gorengan': 'Berlemak/gorengan',
      'Makanan asam (sitrus/tomat/cuka)': 'Asam',
      'Minuman berkafein (kopi/teh)': 'Berkafein',
      'Makanan / minuman bersoda': 'Bersoda',
    };
    _draft
      ..mealFrequency = _mealCount
      ..mealTimes = List<String>.from(_mealTimes)
      ..stressLevel = _stressLevel
      ..sleepTime = _formatTime(_sleepTime)
      ..wakeTime = _formatTime(_wakeTime)
      ..tookMedication = _tookMedicine
      ..triggers = {
        for (final entry in triggerNames.entries)
          entry.value: _foods[entry.key] ?? false,
      }
      ..medications = _tookMedicine
          ? [
              for (final medicine in _medicines)
                () {
                  final parts = medicine.split('|');
                  return {
                    'name': parts.first,
                    'schedule': parts.length > 1 ? parts[1] : '',
                  };
                }(),
            ]
          : [];
    widget.onContinue?.call(_draft);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surface,
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StepTwoHeader(onBack: () => Navigator.of(context).pop()),
                  const SizedBox(height: 24),
                  _SectionTitle(
                    icon: Icons.restaurant_outlined,
                    title: 'Makanan & minuman ${widget.dateLabel}',
                    subtitle: 'Pilih yang kamu konsumsi dalam 24 jam terakhir',
                  ),
                  const SizedBox(height: 12),
                  _FoodCard(
                    foods: _foods,
                    onChanged: (food, value) =>
                        setState(() => _foods[food] = value),
                  ),
                  const SizedBox(height: 16),
                  _FrequencyCard(
                    count: _mealCount,
                    dateLabel: widget.dateLabel,
                    onChanged: _setMealCount,
                  ),
                  const SizedBox(height: 16),
                  _MealTimeCard(
                    sameAsYesterday: _sameAsYesterday,
                    mealCount: _mealCount,
                    mealTimes: _mealTimes,
                    onSameChanged: (value) =>
                        setState(() => _sameAsYesterday = value),
                    onPickTime: _pickMealTime,
                  ),
                  const SizedBox(height: 16),
                  _StressCard(
                    selected: _stressLevel,
                    onChanged: (value) => setState(() => _stressLevel = value),
                  ),
                  const SizedBox(height: 16),
                  _SleepCard(
                    sleepTime: _sleepTime,
                    wakeTime: _wakeTime,
                    onPickSleep: () => _pickSleepTime(sleep: true),
                    onPickWake: () => _pickSleepTime(sleep: false),
                  ),
                  const SizedBox(height: 16),
                  _MedicineCard(
                    dateLabel: widget.dateLabel,
                    tookMedicine: _tookMedicine,
                    medicines: _medicines,
                    showForm: _showMedicineForm,
                    medicineController: _medicineController,
                    timing: _medicineTiming,
                    onTookMedicineChanged: (value) =>
                        setState(() => _tookMedicine = value),
                    onTimingChanged: (value) =>
                        setState(() => _medicineTiming = value),
                    onAddPressed: () =>
                        setState(() => _showMedicineForm = !_showMedicineForm),
                    onAddMedicine: _addMedicine,
                    onRemoveMedicine: (index) =>
                        setState(() => _medicines.removeAt(index)),
                  ),
                ],
              ),
            ),
          ),
          _BottomActions(
            onBack: () => Navigator.of(context).pop(),
            onContinue: _continue,
          ),
        ],
      ),
    ),
  );
}

TimeOfDay _parseTime(String value) {
  final parts = value.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}

String _formatTime(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

int _stressIndex(String label) => const {
  'Rileks': 1,
  'Tenang': 2,
  'Sedang': 3,
  'Tinggi': 4,
  'Berat': 5,
}[label]!;

String _stressLabel(int value) => const {
  1: 'Rileks',
  2: 'Tenang',
  3: 'Sedang',
  4: 'Tinggi',
  5: 'Berat',
}[value]!;
