import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../widgets/report_preview_document.dart';
import '../widgets/report_preview_export_bar.dart';

class ReportPreviewPage extends StatelessWidget {
  const ReportPreviewPage({this.periodDays = 7, super.key});
  final int periodDays;

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
        'Pratinjau Laporan',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
    ),
    bottomNavigationBar: ReportPreviewExportBar(
      onPressed: () => _export(context),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: ReportPreviewDocument(periodDays: periodDays),
    ),
  );

  void _export(BuildContext context) => showAppFeedback(
    context,
    title: 'Laporan siap diekspor',
    message: 'Pratinjau PDF dua halaman sudah disiapkan.',
    icon: Icons.picture_as_pdf_outlined,
  );
}
