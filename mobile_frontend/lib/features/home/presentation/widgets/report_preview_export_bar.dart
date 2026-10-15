import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ReportPreviewExportBar extends StatelessWidget {
  const ReportPreviewExportBar({
    required this.onPressed,
    this.exporting = false,
    super.key,
  });
  final VoidCallback? onPressed;
  final bool exporting;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xF2EDFDF9),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F101E1C),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: exporting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.picture_as_pdf_outlined, size: 18),
          label: Text(exporting ? 'Membuat PDF...' : 'Ekspor PDF'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
          ),
        ),
      ),
    ),
  );
}
