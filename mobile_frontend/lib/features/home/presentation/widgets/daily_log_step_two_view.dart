import 'package:flutter/material.dart';

import '../../../../core/layout/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/daily_log_repository.dart';
import '../../domain/entities/daily_log_draft.dart';

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
    this.repository,
    this.onContinue,
    super.key,
  });

  final DailyLogDraft? draft;
  final bool initialSameAsYesterday;
  final DailyLogRepository? repository;
  final String dateLabel;
  final VoidCallback? onContinue;

  @override
  State<DailyLogStepTwoView> createState() => _DailyLogStepTwoViewState();
}

class _DailyLogStepTwoViewState extends State<DailyLogStepTwoView> {
  late final DailyLogDraft _draft;
  bool _sameAsYesterday = false;
  int? _yesterdayMealCount;
  List<String>? _yesterdayMealTimes;
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
    _loadYesterdayLog();
  }

  @override
  void dispose() {
    _medicineController.dispose();
    super.dispose();
  }

  Future<void> _pickMealTime(int index) async {
    if (_sameAsYesterday) return;
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
      _sameAsYesterday = _yesterdayMealCount == count;
      while (_mealTimes.length < count) {
        _mealTimes.add('--:--');
      }
      while (_mealTimes.length > count) {
        _mealTimes.removeLast();
      }
      if (_sameAsYesterday && _yesterdayMealTimes != null) {
        _mealTimes
          ..clear()
          ..addAll(_yesterdayMealTimes!.take(count));
      }
    });
  }

  Future<void> _loadYesterdayLog() async {
    final date = _draft.logDate.subtract(const Duration(days: 1));
    final dateText =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    try {
      final log = await (widget.repository ?? DailyLogRepository()).fetchDate(
        dateText,
      );
      final count = (log.data['meal_frequency'] as num?)?.toInt();
      final rawTimes = log.data['meal_times'];
      final times = rawTimes is List
          ? rawTimes.map((item) => item.toString()).toList()
          : <String>[];
      if (!mounted || count == null || times.length != count) return;
      setState(() {
        _yesterdayMealCount = count;
        _yesterdayMealTimes = times;
        if (_mealCount == count) {
          _sameAsYesterday = true;
          _mealTimes
            ..clear()
            ..addAll(times);
        } else {
          _sameAsYesterday = false;
        }
      });
    } catch (_) {
      // Jika log kemarin belum ada, jam makan diisi manual.
    }
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

  int get _sleepDurationMinutes {
    var minutes =
        (_wakeTime.hour * 60 + _wakeTime.minute) -
        (_sleepTime.hour * 60 + _sleepTime.minute);
    if (minutes <= 0) minutes += 24 * 60;
    return minutes;
  }

  String get _sleepDurationLabel {
    final hours = _sleepDurationMinutes ~/ 60;
    final minutes = _sleepDurationMinutes % 60;
    return minutes == 0 ? '$hours jam' : '$hours jam $minutes menit';
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
    _draft.medications
      ..clear()
      ..addAll(_medicines);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surface,
    appBar: AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: const Text(
        'LANGKAH 2 DARI 3',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Row(
            children: const [
              Expanded(child: _ProgressSegment(active: false)),
              SizedBox(width: 6),
              Expanded(flex: 4, child: _ProgressSegment(active: true)),
              SizedBox(width: 6),
              Expanded(child: _ProgressSegment(active: false)),
            ],
          ),
        ),
      ),
    ),
    body: SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Pemicu & Kebiasaan',
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
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
                    showComparison:
                        _yesterdayMealCount != null &&
                        _yesterdayMealCount == _mealCount,
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
                    durationLabel: _sleepDurationLabel,
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
                      if (!value) _showMedicineForm = false;
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
