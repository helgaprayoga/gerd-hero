import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/daily_history_entry.dart';
import '../widgets/history_detail_actions.dart';
import '../widgets/history_detail_confirmation_sheets.dart';
import '../widgets/history_detail_habits_card.dart';
import '../widgets/history_detail_symptoms_card.dart';
import '../widgets/history_detail_wellness_card.dart';
import 'daily_log_summary_page.dart';

class DailyHistoryDetailPage extends StatefulWidget {
  const DailyHistoryDetailPage({required this.entry, super.key});

  final DailyHistoryEntry entry;

  @override
  State<DailyHistoryDetailPage> createState() => _DailyHistoryDetailPageState();
}

class _DailyHistoryDetailPageState extends State<DailyHistoryDetailPage> {
  late final TextEditingController _noteController;
  late final Set<String> _symptoms;
  late final Set<String> _triggers;
  int _mealCount = 3;
  final _mealTimes = <String>['07:30', '12:30', '19:00'];
  double _stress = 3;
  bool _tookMedicine = true;
  bool _hasChanges = false;
  TimeOfDay _sleepTime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 6, minute: 30);

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _noteController.addListener(_markChanged);
    _symptoms = widget.entry.symptoms
        .where((item) => item != 'Tanpa Gejala' && !item.startsWith('+'))
        .map(_detailSymptomLabel)
        .toSet();
    _triggers = widget.entry.triggers.map(_cleanLabel).toSet();
  }

  @override
  void dispose() {
    _noteController.removeListener(_markChanged);
    _noteController.dispose();
    super.dispose();
  }

  String _cleanLabel(String value) =>
      value.replaceFirst(RegExp(r'^[^\u0000-\u007F]+\s*'), '');

  String _detailSymptomLabel(String value) =>
      _cleanLabel(value) == 'Gejala Sementara'
      ? 'Regurgitasi Asam'
      : _cleanLabel(value);

  void _toggle(Set<String> values, String value) => setState(() {
    _hasChanges = true;
    values.contains(value) ? values.remove(value) : values.add(value);
  });

  void _markChanged() {
    if (mounted && _noteController.text.isNotEmpty && !_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _save() async {
    final saved = await showHistorySaveSheet(
      context,
      date: '${widget.entry.day}, ${widget.entry.date} 2026',
    );
    if (saved == true && mounted) {
      setState(() => _hasChanges = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perubahan catatan berhasil disimpan')),
      );
    }
  }

  Future<void> _continueToSummary() async {
    if (!_hasChanges) {
      _openSummary();
      return;
    }
    final result = await showHistoryChangedSheet(context);
    if (!mounted) return;
    if (result == 'save') {
      setState(() => _hasChanges = false);
      _openSummary();
    } else if (result == 'discard') {
      _openSummary();
    }
  }

  void _openSummary() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const DailyLogSummaryPage()),
    );
  }

  void _markAndSetMealCount(int value) {
    setState(() {
      _hasChanges = true;
      _setMealCount(value);
    });
  }

  void _setMealCount(int value) {
    _mealCount = value;
    while (_mealTimes.length < value) {
      _mealTimes.add('--:--');
    }
    while (_mealTimes.length > value) {
      _mealTimes.removeLast();
    }
  }

  Future<void> _pickMealTimeAndMark(int index) async {
    await _pickMealTime(index);
    if (mounted) setState(() => _hasChanges = true);
  }

  Future<void> _pickSleepTimeAndMark({required bool sleep}) async {
    await _pickSleepTime(sleep: sleep);
    if (mounted) setState(() => _hasChanges = true);
  }

  Future<void> _pickMealTime(int index) async {
    final current = _mealTimes[index] == '--:--'
        ? const TimeOfDay(hour: 12, minute: 0)
        : _parseTime(_mealTimes[index]);
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked != null && mounted) {
      setState(() => _mealTimes[index] = _formatTime(picked));
    }
  }

  Future<void> _pickSleepTime({required bool sleep}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: sleep ? _sleepTime : _wakeTime,
    );
    if (picked != null && mounted) {
      setState(() {
        if (sleep) {
          _sleepTime = picked;
        } else {
          _wakeTime = picked;
        }
      });
    }
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surface,
    appBar: AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail & Catatan Harian',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Text(
            '${widget.entry.day}, ${widget.entry.date} 2026',
            style: const TextStyle(color: AppColors.secondary, fontSize: 12),
          ),
        ],
      ),
    ),
    bottomNavigationBar: HistoryDetailActions(
      onSave: _save,
      onSummary: _continueToSummary,
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SavedDataCard(entry: widget.entry),
                const SizedBox(height: 20),
                HistoryDetailSymptomsCard(
                  selected: _symptoms,
                  onChanged: (value) => _toggle(_symptoms, value),
                  noteController: _noteController,
                ),
                const SizedBox(height: 12),
                HistoryDetailHabitsCard(
                  triggers: _triggers,
                  onChanged: (value) => _toggle(_triggers, value),
                ),
                const SizedBox(height: 12),
                HistoryDetailWellnessCard(
                  mealCount: _mealCount,
                  onMealCountChanged: _markAndSetMealCount,
                  mealTimes: _mealTimes,
                  onPickMealTime: _pickMealTimeAndMark,
                  stress: _stress,
                  onStressChanged: (value) => setState(() {
                    _stress = value;
                    _hasChanges = true;
                  }),
                  tookMedicine: _tookMedicine,
                  onMedicineChanged: (value) => setState(() {
                    _tookMedicine = value;
                    _hasChanges = true;
                  }),
                  sleepTime: _sleepTime,
                  wakeTime: _wakeTime,
                  onPickSleep: () => _pickSleepTimeAndMark(sleep: true),
                  onPickWake: () => _pickSleepTimeAndMark(sleep: false),
                  onChanged: () => setState(() => _hasChanges = true),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _SavedDataCard extends StatelessWidget {
  const _SavedDataCard({required this.entry});
  final DailyHistoryEntry entry;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0C000000),
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(width: 6, height: 6),
              ),
              SizedBox(width: 4),
              Text(
                'Data Tersimpan',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${entry.day}, ${entry.date} 2026',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.22,
          ),
        ),
      ],
    ),
  );
}
