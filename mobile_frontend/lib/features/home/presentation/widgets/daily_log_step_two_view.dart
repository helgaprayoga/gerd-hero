import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/daily_log_draft.dart';

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
    this.dateLabel = 'hari ini',
    this.initialSameAsYesterday = true,
    this.draft,
    this.onContinue,
    super.key,
  });

  final bool initialSameAsYesterday;
  final String dateLabel;
  final DailyLogDraft? draft;
  final VoidCallback? onContinue;

  @override
  State<DailyLogStepTwoView> createState() => _DailyLogStepTwoViewState();
}

class _DailyLogStepTwoViewState extends State<DailyLogStepTwoView> {
  late final DailyLogDraft _draft;
  late bool _sameAsYesterday;
  late int _mealCount;
  late int _stressLevel;
  late bool _tookMedicine;
  final _medicineController = TextEditingController();
  bool _showMedicineForm = false;
  late final List<MedicationDraft> _medicines;
  late final Map<String, bool> _foods;
  late final List<String> _mealTimes;
  late TimeOfDay _sleepTime;
  late TimeOfDay _wakeTime;
  String _medicineTiming = 'Sebelum Makan';

  @override
  void initState() {
    super.initState();
    _draft = widget.draft ?? DailyLogDraft(logDate: DateTime.now());
    _sameAsYesterday = widget.initialSameAsYesterday;
    _mealCount = _draft.mealFrequency;
    _stressLevel = _draft.stressLevel;
    _tookMedicine = _draft.tookMedication;
    _medicines = _draft.medications;
    _foods = {
      for (final trigger in DailyTrigger.values)
        trigger.label: _draft.triggers[trigger] == true,
    };
    _mealTimes = List<String>.from(_draft.mealTimes);
    while (_mealTimes.length < _mealCount) {
      _mealTimes.add('--:--');
    }
    while (_mealTimes.length > _mealCount) {
      _mealTimes.removeLast();
    }
    _sleepTime = _parseTime(_draft.sleepTime);
    _wakeTime = _parseTime(_draft.wakeTime);
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
      _medicines.add(MedicationDraft(name: name, timing: _medicineTiming));
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

  void _syncDraft() {
    _draft.mealFrequency = _mealCount;
    _draft.mealTimes
      ..clear()
      ..addAll(_mealTimes);
    _draft.stressLevel = _stressLevel;
    _draft.sleepTime = _formatTime(_sleepTime);
    _draft.wakeTime = _formatTime(_wakeTime);
    _draft.tookMedication = _tookMedicine;
    _draft.triggers
      ..clear()
      ..addEntries(
        DailyTrigger.values.map(
          (trigger) => MapEntry(trigger, _foods[trigger.label] == true),
        ),
      );
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
                    onChanged: (food, value) => setState(() {
                      _foods[food] = value;
                      final trigger = _triggerForLabel(food);
                      if (trigger != null) _draft.triggers[trigger] = value;
                    }),
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
                    onTookMedicineChanged: (value) => setState(() {
                      _tookMedicine = value;
                      _draft.tookMedication = value;
                    }),
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
            onContinue: () {
              _syncDraft();
              widget.onContinue?.call();
            },
          ),
        ],
      ),
    ),
  );
}

DailyTrigger? _triggerForLabel(String label) {
  for (final trigger in DailyTrigger.values) {
    if (trigger.label == label) return trigger;
  }
  return null;
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
