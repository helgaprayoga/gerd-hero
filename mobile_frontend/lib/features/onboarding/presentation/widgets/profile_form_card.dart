import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ProfileFormCard extends StatelessWidget {
  const ProfileFormCard({
    required this.nameController,
    required this.heightController,
    required this.weightController,
    required this.birthDate,
    required this.gender,
    required this.onBirthDateTap,
    required this.onGenderChanged,
    super.key,
  });

  final TextEditingController nameController;
  final TextEditingController heightController;
  final TextEditingController weightController;
  final DateTime? birthDate;
  final String gender;
  final VoidCallback onBirthDateTap;
  final ValueChanged<String> onGenderChanged;

  InputDecoration _decoration({String? suffix, String? hint}) =>
      InputDecoration(
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        suffixText: suffix,
        hintText: hint,
        hintStyle: WidgetStateTextStyle.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.focused)
                ? Colors.transparent
                : AppColors.outline,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        suffixStyle: const TextStyle(
          color: AppColors.secondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      );

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0C000000),
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _label('Nama panggilan'),
        TextFormField(
          controller: nameController,
          decoration: _decoration(hint: 'Masukkan nama panggilan').copyWith(
            suffixIcon: const Icon(
              Icons.person_outline,
              color: AppColors.secondary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Nama yang akan digunakan Gery untuk menyapamu.',
          style: TextStyle(
            fontSize: 12,
            height: 1.5,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 20),
        _label('Tanggal lahir'),
        TextFormField(
          key: ValueKey(birthDate),
          readOnly: true,
          onTap: onBirthDateTap,
          initialValue: birthDate == null
              ? ''
              : '${birthDate!.day.toString().padLeft(2, '0')}/${birthDate!.month.toString().padLeft(2, '0')}/${birthDate!.year}',
          decoration: _decoration().copyWith(
            hintText: 'Pilih tanggal lahir',
            suffixIcon: const Icon(
              Icons.calendar_month,
              color: AppColors.secondary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        if (birthDate != null)
          Text(
            'Usia: ${_age(birthDate!)} tahun',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        const SizedBox(height: 20),
        _label('Jenis kelamin'),
        Row(
          children: [
            Expanded(child: _genderButton('Laki-laki', Icons.male)),
            const SizedBox(width: 12),
            Expanded(child: _genderButton('Perempuan', Icons.female)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _measurement(
                'Tinggi badan',
                heightController,
                '170',
                'cm',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _measurement(
                'Berat badan',
                weightController,
                '67.5',
                'kg',
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
    ),
  );

  Widget _genderButton(String value, IconData icon) => SizedBox(
    height: 52,
    child: FilledButton(
      onPressed: () => onGenderChanged(value),
      style: FilledButton.styleFrom(
        backgroundColor: gender == value
            ? AppColors.primary
            : AppColors.surfaceContainerLow,
        foregroundColor: gender == value
            ? Colors.white
            : AppColors.onSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon, size: 19), const SizedBox(width: 6), Text(value)],
      ),
    ),
  );

  Widget _measurement(
    String label,
    TextEditingController controller,
    String hint,
    String unit,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label(label),
      TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: _decoration(hint: hint).copyWith(
          suffix: Text(
            unit,
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ],
  );

  int _age(DateTime date) {
    final now = DateTime.now();
    var age = now.year - date.year;
    if (now.month < date.month ||
        (now.month == date.month && now.day < date.day)) {
      age--;
    }
    return age;
  }
}
