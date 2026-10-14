import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

Future<bool?> showHistorySaveSheet(
  BuildContext context, {
  required String date,
}) => showModalBottomSheet<bool>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => _SheetFrame(
    icon: Icons.save_outlined,
    iconBackground: AppColors.surfaceContainerLow,
    title: 'Simpan Perubahan Catatan?',
    description: Text.rich(
      TextSpan(
        text:
            'Data terbaru yang Anda masukkan akan disimpan dan memperbarui log harian untuk ',
        children: [
          TextSpan(
            text: date,
            style: const TextStyle(color: AppColors.onSurface),
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    ),
    primaryLabel: 'Ya, Simpan Perubahan',
    secondaryLabel: 'Periksa Kembali',
    onPrimary: () => Navigator.pop(context, true),
    onSecondary: () => Navigator.pop(context),
  ),
);

Future<String?> showHistoryChangedSheet(
  BuildContext context,
) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => _SheetFrame(
    icon: Icons.warning_amber_rounded,
    iconBackground: AppColors.tertiaryFixed,
    title: 'Ada Perubahan Data Terdeteksi',
    description: const Text(
      'Kamu menekan Lanjut Ringkasan, namun terdeteksi ada data log yang sempat tersentuh atau bergeser.',
      textAlign: TextAlign.center,
    ),
    primaryLabel: 'Ya, Simpan & Lanjut',
    secondaryLabel: 'Abaikan & Lanjut Tanpa Menyimpan',
    tertiaryLabel: 'Periksa Kembali Formulir',
    onPrimary: () => Navigator.pop(context, 'save'),
    onSecondary: () => Navigator.pop(context, 'discard'),
    onTertiary: () => Navigator.pop(context),
  ),
);

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.description,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
    this.tertiaryLabel,
    this.onTertiary,
  });
  final IconData icon;
  final Color iconBackground;
  final String title;
  final Widget description;
  final String primaryLabel;
  final String secondaryLabel;
  final String? tertiaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;
  final VoidCallback? onTertiary;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      boxShadow: [
        BoxShadow(
          color: Color(0x3F000000),
          blurRadius: 50,
          offset: Offset(0, 25),
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 6,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Container(
            width: 64,
            height: 64,
            margin: const EdgeInsets.only(bottom: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 25),
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1.36,
            ),
          ),
          const SizedBox(height: 6),
          DefaultTextStyle(
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
              height: 1.63,
            ),
            child: description,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: onPrimary,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: const StadiumBorder(),
              ),
              child: Text(
                primaryLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: onSecondary,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondaryContainer.withValues(
                  alpha: 0.65,
                ),
                foregroundColor: AppColors.secondary,
                shape: const StadiumBorder(),
              ),
              child: Text(
                secondaryLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (tertiaryLabel != null) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: TextButton(
                onPressed: onTertiary,
                child: Text(
                  tertiaryLabel!,
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
