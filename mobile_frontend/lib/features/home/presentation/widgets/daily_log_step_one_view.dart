import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../domain/entities/daily_log_draft.dart';
import 'daily_log_step_two_view.dart';

part 'daily_log_step_one_step_progress.dart';
part 'daily_log_step_one_no_symptom_card.dart';
part 'daily_log_step_one_symptom_card.dart';
part 'daily_log_step_one_icon_tile.dart';

class DailyLogStepOneView extends StatefulWidget {
  const DailyLogStepOneView({
    this.dateLabel = 'hari ini',
    this.draft,
    this.onNext,
    super.key,
  });

  final String dateLabel;
  final DailyLogDraft? draft;
  final VoidCallback? onNext;

  @override
  State<DailyLogStepOneView> createState() => _DailyLogStepOneViewState();
}

class _DailyLogStepOneViewState extends State<DailyLogStepOneView> {
  late final DailyLogDraft _draft;
  final _noteController = TextEditingController();
  late final Set<DailySymptom> _selectedSymptoms;
  late bool _noSymptoms;

  static const _symptoms = [
    (
      symptom: DailySymptom.heartburn,
      title: 'Heartburn (rasa terbakar di dada)',
      subtitle: 'Sensasi panas menjalar ke kerongkongan',
      icon: Icons.local_fire_department_outlined,
    ),
    (
      symptom: DailySymptom.regurgitasi,
      title: 'Regurgitasi (asam naik ke mulut)',
      subtitle: 'Rasa masam atau pahit di pangkal lidah',
      icon: Icons.north_outlined,
    ),
    (
      symptom: DailySymptom.nyeriDada,
      title: 'Nyeri dada',
      subtitle: 'Rasa tertekan di tengah tulang dada',
      icon: Icons.favorite_border,
    ),
    (
      symptom: DailySymptom.kesulitanMenelan,
      title: 'Kesulitan menelan',
      subtitle: 'Sensasi makanan menyangkut di leher',
      icon: Icons.restaurant_outlined,
    ),
    (
      symptom: DailySymptom.kembungGas,
      title: 'Kembung dan gas di perut',
      subtitle: 'Perut terasa begah, padat, dan sering bersendawa',
      icon: Icons.air,
    ),
    (
      symptom: DailySymptom.suaraSerak,
      title: 'Suara serak',
      subtitle: 'Pita suara teriritasi terutama di pagi hari',
      icon: Icons.record_voice_over_outlined,
    ),
    (
      symptom: DailySymptom.keringatDingin,
      title: 'Keringat dingin',
      subtitle: 'Keringat dingin yang muncul bersama keluhan',
      icon: Icons.ac_unit_outlined,
    ),
    (
      symptom: DailySymptom.kramPerut,
      title: 'Kram perut',
      subtitle: 'Rasa kram atau mulas pada perut',
      icon: Icons.healing_outlined,
    ),
    (
      symptom: DailySymptom.ketidaknyamananTenggorokan,
      title: 'Ketidaknyamanan tenggorokan',
      subtitle: 'Rasa mengganjal atau tidak nyaman di tenggorokan',
      icon: Icons.record_voice_over_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _draft = widget.draft ?? DailyLogDraft(logDate: DateTime.now());
    _selectedSymptoms = _draft.symptoms;
    _noSymptoms = _draft.noSymptoms;
    _noteController.text = _draft.symptomDescription;
    _noteController.addListener(_syncDescription);
  }

  @override
  void dispose() {
    _noteController.removeListener(_syncDescription);
    _noteController.dispose();
    super.dispose();
  }

  void _syncDescription() => _draft.symptomDescription = _noteController.text;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surface,
    appBar: AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: const Text(
        'LANGKAH 1 DARI 3',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(16),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: _StepProgress(),
        ),
      ),
    ),
    body: SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Gejala apa yang kamu rasakan\n${widget.dateLabel}?',
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 22,
                      height: 1.35,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _NoSymptomCard(
                    selected: _noSymptoms,
                    onTap: () => setState(() {
                      _noSymptoms = !_noSymptoms;
                      _draft.noSymptoms = _noSymptoms;
                      if (_noSymptoms) _selectedSymptoms.clear();
                    }),
                  ),
                  if (!_noSymptoms) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Daftar Gejala Terkait',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${_selectedSymptoms.length} Dipilih',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (final symptom in _symptoms) ...[
                      _SymptomCard(
                        title: symptom.title,
                        subtitle: symptom.subtitle,
                        icon: symptom.icon,
                        selected: _selectedSymptoms.contains(symptom.symptom),
                        onTap: () {
                          setState(() {
                            _draft.noSymptoms = false;
                            _noSymptoms = false;
                            if (_selectedSymptoms.contains(symptom.symptom)) {
                              _selectedSymptoms.remove(symptom.symptom);
                            } else {
                              _selectedSymptoms.add(symptom.symptom);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                  if (!_noSymptoms) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Deskripsi (opsional)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Maks. 250 karakter',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _noteController,
                      maxLength: 250,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                            'Ceritakan catatan tambahan atau deskripsi gejala lainnya di sini...',
                        filled: true,
                        fillColor: Colors.white,
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: () {
                        if (!_noSymptoms && _selectedSymptoms.isEmpty) {
                          showTopAppSnackbar(
                            context,
                            title: 'Data belum lengkap',
                            message:
                                'Pilih “Tidak ada gejala” atau pilih minimal satu gejala terlebih dahulu.',
                            icon: Icons.warning_amber_rounded,
                          );
                          return;
                        }
                        _draft.noSymptoms = _noSymptoms;
                        _draft.symptomDescription = _noteController.text.trim();
                        if (widget.onNext != null) {
                          widget.onNext!();
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  DailyLogStepTwoView(draft: _draft),
                            ),
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Lanjut'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
