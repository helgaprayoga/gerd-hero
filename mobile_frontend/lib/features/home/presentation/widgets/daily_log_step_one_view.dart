import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'daily_log_step_two_view.dart';

part 'daily_log_step_one_step_progress.dart';
part 'daily_log_step_one_no_symptom_card.dart';
part 'daily_log_step_one_symptom_card.dart';
part 'daily_log_step_one_icon_tile.dart';

class DailyLogStepOneView extends StatefulWidget {
  const DailyLogStepOneView({this.onNext, super.key});

  final VoidCallback? onNext;

  @override
  State<DailyLogStepOneView> createState() => _DailyLogStepOneViewState();
}

class _DailyLogStepOneViewState extends State<DailyLogStepOneView> {
  final _noteController = TextEditingController();
  final _selectedSymptoms = <String>{'heartburn', 'regurgitasi'};
  bool _noSymptoms = false;

  static const _symptoms = [
    (
      id: 'heartburn',
      title: 'Heartburn (rasa terbakar di dada)',
      subtitle: 'Sensasi panas menjalar ke kerongkongan',
      icon: Icons.local_fire_department_outlined,
    ),
    (
      id: 'regurgitasi',
      title: 'Regurgitasi (asam naik ke mulut)',
      subtitle: 'Rasa masam atau pahit di pangkal lidah',
      icon: Icons.north_outlined,
    ),
    (
      id: 'nyeri',
      title: 'Nyeri dada',
      subtitle: 'Rasa tertekan di tengah tulang dada',
      icon: Icons.favorite_border,
    ),
    (
      id: 'menelan',
      title: 'Kesulitan menelan',
      subtitle: 'Sensasi makanan menyangkut di leher',
      icon: Icons.restaurant_outlined,
    ),
    (
      id: 'kembung',
      title: 'Kembung dan gas di perut',
      subtitle: 'Perut terasa begah, padat, dan sering bersendawa',
      icon: Icons.air,
    ),
    (
      id: 'serak',
      title: 'Suara serak',
      subtitle: 'Pita suara teriritasi terutama di pagi hari',
      icon: Icons.record_voice_over_outlined,
    ),
    (
      id: 'lainnya',
      title: 'Gejala lainnya',
      subtitle: 'Deskripsikan gejala pada catatan di bawah',
      icon: Icons.more_horiz,
    ),
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surface,
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('Kembali'),
                      ),
                      const Text(
                        'LANGKAH 1 DARI 3',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const _StepProgress(),
                  const SizedBox(height: 24),
                  const Text(
                    'Gejala apa yang kamu rasakan\nhari ini?',
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
                    onTap: () => setState(() => _noSymptoms = !_noSymptoms),
                  ),
                  if (!_noSymptoms) ...[
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Daftar Gejala Terkait',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
                        selected: _selectedSymptoms.contains(symptom.id),
                        onTap: () {
                          setState(() {
                            if (_selectedSymptoms.contains(symptom.id)) {
                              _selectedSymptoms.remove(symptom.id);
                            } else {
                              _selectedSymptoms.add(symptom.id);
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Deskripsi (opsional)',
                          style: TextStyle(
                            color: AppColors.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Maks. 250 karakter',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 12,
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
                        if (widget.onNext != null) {
                          widget.onNext!();
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const DailyLogStepTwoView(),
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
