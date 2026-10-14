part of 'daily_log_step_two_view.dart';

class _MedicineCard extends StatelessWidget {
  const _MedicineCard({
    required this.tookMedicine,
    required this.medicines,
    required this.showForm,
    required this.medicineController,
    required this.timing,
    required this.onTookMedicineChanged,
    required this.onTimingChanged,
    required this.onAddPressed,
    required this.onAddMedicine,
    required this.onRemoveMedicine,
  });
  final bool tookMedicine;
  final List<String> medicines;
  final bool showForm;
  final TextEditingController medicineController;
  final String timing;
  final ValueChanged<bool> onTookMedicineChanged;
  final ValueChanged<String> onTimingChanged;
  final VoidCallback onAddPressed;
  final VoidCallback onAddMedicine;
  final ValueChanged<int> onRemoveMedicine;

  @override
  Widget build(BuildContext context) => _CardShell(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          icon: Icons.medication_outlined,
          title: 'Konsumsi obat',
          subtitle: 'Catatan obat lambung rutin atau pereda gejala',
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Apakah hari ini kamu minum obat lambung?',
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _YesNoToggle(
              selected: tookMedicine,
              onChanged: onTookMedicineChanged,
            ),
          ],
        ),
        if (tookMedicine) ...[
          const SizedBox(height: 14),
          const Text(
            'Daftar Obat Dikonsumsi',
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < medicines.length; i++)
            _MedicineEntry(
              value: medicines[i],
              onRemove: () => onRemoveMedicine(i),
            ),
          if (showForm) ...[
            const SizedBox(height: 10),
            TextField(
              controller: medicineController,
              decoration: const InputDecoration(
                labelText: 'Nama obat',
                prefixIcon: Icon(Icons.medication_outlined),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final value in [
                  'Sebelum Makan',
                  'Sesudah Makan',
                  'Saat Gejala Kambuh',
                  'Sebelum Tidur',
                ])
                  ChoiceChip(
                    label: Text(value),
                    selected: timing == value,
                    onSelected: (_) => onTimingChanged(value),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: onAddMedicine,
              icon: const Icon(Icons.check, size: 17),
              label: const Text('Simpan Obat'),
            ),
          ],
        ],
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onAddPressed,
          icon: const Icon(Icons.add, size: 18),
          label: Text(showForm ? 'Tutup Form Obat' : 'Tambah Obat Lainnya'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 42),
          ),
        ),
      ],
    ),
  );
}
