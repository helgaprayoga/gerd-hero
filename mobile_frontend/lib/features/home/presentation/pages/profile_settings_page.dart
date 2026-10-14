import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_feedback.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  String smoking = 'Tidak';
  String alcohol = 'Tidak';
  String activity = 'Reguler (09.00 - 17.00)';
  String gender = 'Laki-laki';
  String name = 'Dion Pratama';
  String nickname = 'Dion';
  String email = 'dion.pratama@email.com';
  String birthDate = '14 Agustus 1996';
  String height = '170';
  String weight = '67.5';
  int coffeeCups = 1;
  bool isAddingCondition = false;
  bool isAddingMedicine = false;
  final conditionController = TextEditingController();
  final medicineNameController = TextEditingController();
  final medicineScheduleController = TextEditingController();
  final selectedConditions = <String>{'Riwayat GERD', 'Gastritis / Maag'};
  final customConditions = <String>[];
  final medicines = <_MedicineData>[
    _MedicineData('Omeprazole 20mg', '1x sehari (Pagi sebelum makan)'),
    _MedicineData('Antasida Doen', 'Saat gejala kambuh (PRN)'),
  ];

  @override
  void dispose() {
    conditionController.dispose();
    medicineNameController.dispose();
    medicineScheduleController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {
      if (mounted) {
        showAppFeedback(
          context,
          title: 'Gagal keluar',
          message: 'Sesi belum dapat diakhiri. Silakan coba lagi.',
          icon: Icons.info_outline,
        );
      }
    }
  }

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
      title: const Text(
        'Profil & Peraturan',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
    ),
    bottomNavigationBar: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: FilledButton.icon(
          onPressed: () => showAppFeedback(
            context,
            title: 'Profil tersimpan',
            message: 'Perubahan profil kamu sudah diperbarui.',
          ),
          icon: const Icon(Icons.check, size: 18),
          label: const Text('Simpan Perubahan'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: const StadiumBorder(),
          ),
        ),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        const _ProfileSummaryCard(),
        const SizedBox(height: 20),
        _ProfileSection(
          icon: Icons.person_outline,
          title: 'Data Dasar',
          children: [
            _ProfileField(
              label: 'Nama Lengkap',
              value: name,
              onChanged: (value) => setState(() => name = value),
            ),
            _ProfileField(
              label: 'Nama Panggilan',
              value: nickname,
              onChanged: (value) => setState(() => nickname = value),
              helper:
                  'Nama panggilan yang ditampilkan Gerdie saat menyapamu di Beranda.',
            ),
            _ProfileField(
              label: 'Email',
              value: email,
              onChanged: (value) => setState(() => email = value),
              trailing: _VerifiedBadge(),
            ),
            _ProfileField(
              label: 'Tanggal Lahir',
              value: birthDate,
              onChanged: (value) => setState(() => birthDate = value),
              trailing: Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppColors.secondary,
              ),
            ),
            const Text('Jenis Kelamin', style: _labelStyle),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ChoiceButton(
                    label: 'Laki-laki',
                    selected: gender == 'Laki-laki',
                    onTap: () => setState(() => gender = 'Laki-laki'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ChoiceButton(
                    label: 'Perempuan',
                    selected: gender == 'Perempuan',
                    onTap: () => setState(() => gender = 'Perempuan'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ProfileField(
                    label: 'Tinggi Badan',
                    value: height,
                    onChanged: (value) => setState(() => height = value),
                    suffix: 'cm',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ProfileField(
                    label: 'Berat Badan',
                    value: weight,
                    onChanged: (value) => setState(() => weight = value),
                    suffix: 'kg',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _BmiCard(height: height, weight: weight),
          ],
        ),
        const SizedBox(height: 16),
        _ProfileSection(
          icon: Icons.self_improvement_outlined,
          title: 'Kebiasaan Hidup',
          children: [
            _SegmentField(
              label: 'Kebiasaan Merokok',
              value: smoking,
              options: const ['Tidak', 'Kadang', 'Rutin'],
              onChanged: (value) => setState(() => smoking = value),
            ),
            _SegmentField(
              label: 'Konsumsi Alkohol',
              value: alcohol,
              options: const ['Tidak', 'Kadang', 'Rutin'],
              onChanged: (value) => setState(() => alcohol = value),
            ),
            _SegmentField(
              label: 'Pola Aktivitas Harian',
              value: activity,
              options: const ['Reguler (09.00 - 17.00)', 'Shift / Malam'],
              onChanged: (value) => setState(() => activity = value),
            ),
            _CoffeeCard(
              cups: coffeeCups,
              onMinus: () => setState(
                () => coffeeCups = coffeeCups > 0 ? coffeeCups - 1 : 0,
              ),
              onPlus: () => setState(() => coffeeCups++),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _ProfileSection(
          icon: Icons.medical_information_outlined,
          title: 'Riwayat Kesehatan',
          children: [
            const Text(
              'Pilih kondisi kesehatan atau riwayat medis lambung & metabolik:',
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final condition in [
                  'Riwayat GERD',
                  'Gastritis / Maag',
                  'Hipertensi',
                  'Diabetes',
                  'Asma',
                  ...customConditions,
                ])
                  _ConditionChip(
                    label: condition,
                    selected: selectedConditions.contains(condition),
                    onTap: () => setState(() {
                      if (selectedConditions.contains(condition)) {
                        selectedConditions.remove(condition);
                      } else {
                        selectedConditions.add(condition);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            OutlinedButton.icon(
              onPressed: () =>
                  setState(() => isAddingCondition = !isAddingCondition),
              icon: Icon(isAddingCondition ? Icons.close : Icons.add, size: 18),
              label: Text(
                isAddingCondition ? 'Batal Tambah Kondisi' : 'Tambah Kondisi',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primaryContainer),
                shape: const StadiumBorder(),
              ),
            ),
            if (isAddingCondition) ...[
              const SizedBox(height: 12),
              _InlineAddCard(
                label: 'Nama kondisi',
                controller: conditionController,
                actionLabel: 'Tambah',
                onCancel: () => setState(() => isAddingCondition = false),
                onAdd: () {
                  final value = conditionController.text.trim();
                  if (value.isEmpty) return;
                  setState(() {
                    customConditions.add(value);
                    selectedConditions.add(value);
                    conditionController.clear();
                    isAddingCondition = false;
                  });
                },
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        _ProfileSection(
          icon: Icons.medication_outlined,
          title: 'Obat Rutin',
          children: [
            for (var index = 0; index < medicines.length; index++) ...[
              _MedicineCard(
                medicine: medicines[index],
                onChanged: () => setState(() {}),
                onDelete: () => setState(() => medicines.removeAt(index)),
              ),
              if (index < medicines.length - 1) const SizedBox(height: 8),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () =>
                  setState(() => isAddingMedicine = !isAddingMedicine),
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                isAddingMedicine
                    ? 'Batal Tambah Obat'
                    : 'Tambah Obat Rutin Baru',
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primaryContainer),
                shape: const StadiumBorder(),
              ),
            ),
            if (isAddingMedicine) ...[
              const SizedBox(height: 12),
              _InlineAddMedicineCard(
                nameController: medicineNameController,
                scheduleController: medicineScheduleController,
                onCancel: () => setState(() => isAddingMedicine = false),
                onAdd: () {
                  final name = medicineNameController.text.trim();
                  final schedule = medicineScheduleController.text.trim();
                  if (name.isEmpty || schedule.isEmpty) return;
                  setState(() {
                    medicines.add(_MedicineData(name, schedule));
                    medicineNameController.clear();
                    medicineScheduleController.clear();
                    isAddingMedicine = false;
                  });
                },
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        Center(
          child: TextButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout, color: AppColors.error, size: 18),
            label: const Text(
              'Keluar dari Akun',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

const _labelStyle = TextStyle(
  color: AppColors.onSurfaceVariant,
  fontSize: 12,
  fontWeight: FontWeight.w600,
);

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: _cardDecoration,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Stack(
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.surfaceContainerLow,
                  child: Text(
                    'D',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dion',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'dion.pratama@email.com',
                    style: TextStyle(color: AppColors.secondary, fontSize: 12),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _SummaryPill(label: '28 tahun'),
                      _SummaryPill(label: 'BMI 23.4 (Ideal)'),
                      _SummaryPill(label: 'Pria'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kelengkapan Profil',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '85%',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: const SizedBox(
                  height: 8,
                  child: LinearProgressIndicator(
                    value: .85,
                    backgroundColor: AppColors.secondaryContainer,
                    valueColor: AlwaysStoppedAnimation(
                      AppColors.primaryContainer,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.icon,
    required this.title,
    required this.children,
  });
  final IconData icon;
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: _cardDecoration,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.surfaceContainerLow,
              child: Icon(icon, color: AppColors.primary, size: 21),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...children.map(
          (child) =>
              Padding(padding: const EdgeInsets.only(bottom: 16), child: child),
        ),
      ],
    ),
  );
}

const _cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(16)),
  boxShadow: [
    BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1)),
  ],
);

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.value,
    this.helper,
    this.trailing,
    this.suffix,
    this.onChanged,
  });
  final String label;
  final String value;
  final String? helper;
  final Widget? trailing;
  final String? suffix;
  final ValueChanged<String>? onChanged;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: _labelStyle),
      const SizedBox(height: 6),
      Container(
        constraints: const BoxConstraints(minHeight: 50),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: value,
                onChanged: onChanged,
                keyboardType: suffix == null
                    ? TextInputType.text
                    : TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            if (suffix != null)
              Text(
                suffix!,
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ?trailing,
          ],
        ),
      ),
      if (helper != null)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            helper!,
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ),
    ],
  );
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: AppColors.onSurfaceVariant,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(left: 8),
    child: _SummaryPill(label: 'Terverifikasi'),
  );
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.onTap,
    this.selected = false,
  });
  final String label;
  final VoidCallback onTap;
  final bool selected;
  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: onTap,
    style: FilledButton.styleFrom(
      backgroundColor: selected
          ? AppColors.primaryContainer
          : AppColors.surfaceContainer,
      foregroundColor: selected ? Colors.white : AppColors.onSurfaceVariant,
      minimumSize: const Size.fromHeight(44),
      shape: const StadiumBorder(),
    ),
    child: Text(label),
  );
}

class _BmiCard extends StatelessWidget {
  const _BmiCard({required this.height, required this.weight});
  final String height;
  final String weight;
  @override
  Widget build(BuildContext context) {
    final heightValue = double.tryParse(height.replaceAll(',', '.')) ?? 170;
    final weightValue = double.tryParse(weight.replaceAll(',', '.')) ?? 67.5;
    final bmi = weightValue / ((heightValue / 100) * (heightValue / 100));
    final category = bmi < 18.5
        ? 'Kurang'
        : bmi < 25
        ? 'Normal (Ideal)'
        : 'Lebih';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BMI: ${bmi.toStringAsFixed(1)}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              _SummaryPill(label: 'Kategori $category'),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: const Row(
              children: [
                Expanded(
                  flex: 30,
                  child: SizedBox(
                    height: 12,
                    child: ColoredBox(color: AppColors.secondaryContainer),
                  ),
                ),
                Expanded(
                  flex: 45,
                  child: SizedBox(
                    height: 12,
                    child: ColoredBox(color: AppColors.primaryContainer),
                  ),
                ),
                Expanded(
                  flex: 25,
                  child: SizedBox(
                    height: 12,
                    child: ColoredBox(color: AppColors.tertiaryFixedDim),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '< 18.5 Kurang',
                style: TextStyle(color: AppColors.secondary, fontSize: 10),
              ),
              Text(
                '18.5 - 24.9 Ideal',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '> 25.0 Lebih',
                style: TextStyle(color: AppColors.secondary, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SegmentField extends StatelessWidget {
  const _SegmentField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: _labelStyle),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          children: [
            for (final option in options)
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                      vertical: 9,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      color: value == option
                          ? AppColors.primaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      option,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: value == option
                            ? Colors.white
                            : AppColors.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

class _ConditionChip extends StatelessWidget {
  const _ConditionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => FilterChip(
    label: Text(label),
    selected: selected,
    onSelected: (_) => onTap(),
    selectedColor: AppColors.primaryContainer,
    checkmarkColor: Colors.white,
    labelStyle: TextStyle(
      color: selected ? Colors.white : AppColors.onSurfaceVariant,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    backgroundColor: AppColors.surfaceContainer,
    side: BorderSide.none,
  );
}

class _MedicineData {
  _MedicineData(this.name, this.schedule);
  String name;
  String schedule;
}

class _MedicineCard extends StatelessWidget {
  const _MedicineCard({
    required this.medicine,
    required this.onChanged,
    required this.onDelete,
  });
  final _MedicineData medicine;
  final VoidCallback onChanged;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.medication_outlined,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: medicine.name,
                onChanged: (value) {
                  medicine.name = value;
                  onChanged();
                },
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextFormField(
                initialValue: medicine.schedule,
                onChanged: (value) {
                  medicine.schedule = value;
                  onChanged();
                },
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(
            Icons.delete_outline,
            size: 18,
            color: AppColors.error,
          ),
        ),
      ],
    ),
  );
}

class _InlineAddCard extends StatelessWidget {
  const _InlineAddCard({
    required this.label,
    required this.controller,
    required this.actionLabel,
    required this.onCancel,
    required this.onAdd,
  });
  final String label;
  final TextEditingController controller;
  final String actionLabel;
  final VoidCallback onCancel;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => _AddCardShell(
    children: [
      Text(label, style: _labelStyle),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Contoh: Dispepsia',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      const SizedBox(height: 10),
      _AddActions(onCancel: onCancel, onAdd: onAdd, label: actionLabel),
    ],
  );
}

class _InlineAddMedicineCard extends StatelessWidget {
  const _InlineAddMedicineCard({
    required this.nameController,
    required this.scheduleController,
    required this.onCancel,
    required this.onAdd,
  });
  final TextEditingController nameController;
  final TextEditingController scheduleController;
  final VoidCallback onCancel;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => _AddCardShell(
    children: [
      const Text('Nama Obat & Dosis', style: _labelStyle),
      const SizedBox(height: 6),
      TextField(
        controller: nameController,
        autofocus: true,
        decoration: _inputDecoration('Contoh: Sucralfate Sirup 500mg'),
      ),
      const SizedBox(height: 10),
      const Text('Aturan / Waktu Minum', style: _labelStyle),
      const SizedBox(height: 6),
      TextField(
        controller: scheduleController,
        decoration: _inputDecoration('Contoh: 3x sehari sebelum makan'),
      ),
      const SizedBox(height: 10),
      _AddActions(onCancel: onCancel, onAdd: onAdd, label: 'Simpan Obat'),
    ],
  );
}

InputDecoration _inputDecoration(String hint) => InputDecoration(
  hintText: hint,
  filled: true,
  fillColor: Colors.white,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
  ),
);

class _AddCardShell extends StatelessWidget {
  const _AddCardShell({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow,
      border: Border.all(
        color: AppColors.primaryContainer.withValues(alpha: .35),
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

class _AddActions extends StatelessWidget {
  const _AddActions({
    required this.onCancel,
    required this.onAdd,
    required this.label,
  });
  final VoidCallback onCancel;
  final VoidCallback onAdd;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      TextButton(onPressed: onCancel, child: const Text('Batal')),
      const SizedBox(width: 8),
      FilledButton(
        onPressed: onAdd,
        style: FilledButton.styleFrom(shape: const StadiumBorder()),
        child: Text(label),
      ),
    ],
  );
}

class _CoffeeCard extends StatelessWidget {
  const _CoffeeCard({
    required this.cups,
    required this.onMinus,
    required this.onPlus,
  });
  final int cups;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.local_cafe_outlined,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Konsumsi Kopi',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: onMinus,
                icon: const Icon(Icons.remove, size: 16),
                constraints: const BoxConstraints.tightFor(
                  width: 28,
                  height: 28,
                ),
                padding: EdgeInsets.zero,
                color: AppColors.secondary,
              ),
              Text(
                '$cups cangkir / hari',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: onPlus,
                icon: const Icon(Icons.add, size: 16),
                constraints: const BoxConstraints.tightFor(
                  width: 28,
                  height: 28,
                ),
                padding: EdgeInsets.zero,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
