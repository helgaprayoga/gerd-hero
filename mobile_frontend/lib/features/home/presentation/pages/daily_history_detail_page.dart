import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../data/repositories/daily_log_repository.dart';
import '../../domain/entities/daily_log_draft.dart';
import '../models/daily_history_entry.dart';
import '../widgets/history_detail_actions.dart';
import '../widgets/history_detail_confirmation_sheets.dart';
import '../widgets/history_detail_habits_card.dart';
import '../widgets/history_detail_symptoms_card.dart';
import '../widgets/history_detail_wellness_card.dart';
import 'daily_history_summary_page.dart';

class DailyHistoryDetailPage extends StatefulWidget {
  const DailyHistoryDetailPage({
    required this.entry,
    this.repository,
    super.key,
  });

  final DailyHistoryEntry entry;
  final DailyLogRepository? repository;

  @override
  State<DailyHistoryDetailPage> createState() => _DailyHistoryDetailPageState();
}

class _DailyHistoryDetailPageState extends State<DailyHistoryDetailPage> {
  late final TextEditingController _noteController;
  late Set<String> _symptoms;
  late Set<String> _triggers;
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
        .toSet();
    _triggers = widget.entry.triggers.map(_cleanLabel).toSet();
    _loadDetail();
  }

  @override
  void dispose() {
    _noteController.removeListener(_markChanged);
    _noteController.dispose();
    super.dispose();
  }

  String _cleanLabel(String value) =>
      value.replaceFirst(RegExp(r'^[^\u0000-\u007F]+\s*'), '');

  bool get _hasSession {
    try {
      return Supabase.instance.client.auth.currentSession != null;
    } on AssertionError {
      return false;
    }
  }

  Future<void> _loadDetail() async {
    final date = widget.entry.dateIso;
    if (date == null || (!_hasSession && widget.repository == null)) return;
    try {
      final log = await (widget.repository ?? DailyLogRepository()).fetchDate(
        date,
      );
      if (!mounted) return;
      final data = log.data;
      final meals = data['meal_times'];
      setState(() {
        _symptoms = log.symptoms
            .where((item) => item != 'Tanpa Gejala')
            .toSet();
        _triggers = log.triggers.entries
            .where((entry) => entry.value == 1 || entry.value == true)
            .map((entry) => entry.key)
            .toSet();
        _noteController.removeListener(_markChanged);
        _noteController.text = data['symptom_description']?.toString() ?? '';
        _noteController.addListener(_markChanged);
        _mealCount = (data['meal_frequency'] as num?)?.toInt() ?? 1;
        _mealTimes
          ..clear()
          ..addAll(
            meals is List
                ? meals.map((item) => item.toString())
                : const <String>[],
          );
        _stress = ((data['stress_level'] as num?) ?? 1).toDouble();
        _tookMedicine = data['took_medication'] == true;
        _sleepTime = _parseTime(data['sleep_time']?.toString() ?? '23:00');
        _wakeTime = _parseTime(data['wake_time']?.toString() ?? '06:30');
      });
    } catch (_) {
      // Initial entry data remains visible if the detail request fails.
    }
  }

  void _toggle(Set<String> values, String value) => setState(() {
    _hasChanges = true;
    values.contains(value) ? values.remove(value) : values.add(value);
  });

  void _markChanged() {
    if (mounted && _noteController.text.isNotEmpty && !_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<bool> _persistChanges() async {
    if (widget.entry.dateIso == null) return false;
    try {
      final draft = _toDraft();
      await (widget.repository ?? DailyLogRepository()).createOrUpdate(
        draft,
        allowUpdate: true,
      );
      return true;
    } on ApiException catch (error) {
      if (mounted) {
        showAppFeedback(
          context,
          title: 'Gagal menyimpan',
          message: error.message,
          icon: Icons.error_outline,
        );
      }
      return false;
    }
  }

  Future<void> _save() async {
    final saved = await showHistorySaveSheet(
      context,
      date: '${widget.entry.day}, ${widget.entry.date} 2026',
    );
    if (saved == true && mounted) {
      final persisted = await _persistChanges();
      if (!persisted || !mounted) return;
      setState(() => _hasChanges = false);
      showAppFeedback(
        context,
        title: 'Catatan tersimpan',
        message: 'Perubahan catatan harian berhasil diperbarui.',
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
      final persisted = await _persistChanges();
      if (!persisted || !mounted) return;
      setState(() => _hasChanges = false);
      _openSummary();
    } else if (result == 'discard') {
      _openSummary();
    }
  }

  void _openSummary() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DailyHistorySummaryPage(
          entry: widget.entry,
          repository: widget.repository,
        ),
      ),
    );
  }

  DailyLogDraft _toDraft() {
    final draft = DailyLogDraft(logDate: DateTime.parse(widget.entry.dateIso!));
    draft.symptoms
      ..clear()
      ..addAll(_symptoms.map(_symptomFromApi).whereType<DailySymptom>());
    draft.noSymptoms = draft.symptoms.isEmpty;
    draft.symptomDescription = _noteController.text.trim();
    draft.triggers
      ..clear()
      ..addEntries(
        DailyTrigger.values.map(
          (trigger) => MapEntry(trigger, _triggers.contains(trigger.apiValue)),
        ),
      );
    draft.mealFrequency = _mealCount;
    draft.mealTimes
      ..clear()
      ..addAll(_mealTimes);
    draft.stressLevel = _stress.round();
    draft.sleepTime = _formatTime(_sleepTime);
    draft.wakeTime = _formatTime(_wakeTime);
    draft.tookMedication = _tookMedicine;
    return draft;
  }

  DailySymptom? _symptomFromApi(String value) {
    for (final symptom in DailySymptom.values) {
      if (symptom.apiValue == value) return symptom;
    }
    return null;
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
