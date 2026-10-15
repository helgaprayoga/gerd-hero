import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/report_file_saver.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../data/report_service.dart';

class ReportPreviewPage extends StatefulWidget {
  const ReportPreviewPage({required this.start, required this.end, super.key});

  final DateTime start;
  final DateTime end;

  @override
  State<ReportPreviewPage> createState() => _ReportPreviewPageState();
}

class _ReportPreviewPageState extends State<ReportPreviewPage> {
  PdfControllerPinch? _controller;
  Uint8List? _pdfBytes;
  bool _loading = true;
  bool _exporting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadPdf() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bytes = await ReportService.instance.previewPdf(
        start: widget.start,
        end: widget.end,
      );
      final document = PdfDocument.openData(Uint8List.fromList(bytes));
      final controller = PdfControllerPinch(document: document);
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() {
        _pdfBytes = Uint8List.fromList(bytes);
        _controller?.dispose();
        _controller = controller;
      });
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Tidak dapat memuat pratinjau PDF.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _zoom(double factor) {
    final controller = _controller;
    if (controller == null) return;
    final next = (controller.zoomRatio * factor).clamp(1.0, 4.0);
    controller.value = controller.value.clone()
      ..scaleByDouble(
        next / controller.zoomRatio,
        next / controller.zoomRatio,
        next / controller.zoomRatio,
        1.0,
      );
    setState(() {});
  }

  void _fit() {
    final controller = _controller;
    if (controller == null) return;
    final matrix = controller.calculatePageFitMatrix(pageNumber: 1);
    if (matrix != null) {
      controller.value = matrix;
      setState(() {});
    }
  }

  Future<void> _export() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final result = await ReportService.instance.generate(
        start: widget.start,
        end: widget.end,
      );
      final reportId = result['report_id'] as String?;
      final reportNumber =
          result['report_number'] as String? ?? 'GERDHero_Laporan';
      if (reportId == null) {
        throw const FormatException('Nomor laporan tidak tersedia.');
      }
      final bytes = await ReportService.instance.download(reportId);
      final saved = await ReportFileSaver.save(
        Uint8List.fromList(bytes),
        '$reportNumber.pdf',
      );
      if (!mounted) return;
      await showAppFeedback(
        context,
        title: saved ? 'Laporan tersimpan' : 'Penyimpanan dibatalkan',
        message: saved
            ? 'PDF berhasil disimpan di lokasi yang kamu pilih.'
            : 'PDF sudah dibuat, tetapi belum disimpan ke perangkat.',
        icon: saved ? Icons.check_circle_outline : Icons.info_outline,
      );
    } on ApiException catch (error) {
      if (mounted) _showError(error.message);
    } catch (_) {
      if (mounted) _showError('Tidak dapat membuat atau menyimpan PDF.');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  void _showError(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFE8F8F4),
    appBar: AppBar(
      backgroundColor: const Color(0xFFE8F8F4),
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back),
      ),
      title: const Text(
        'Pratinjau Laporan',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      centerTitle: true,
    ),
    bottomNavigationBar: _pdfBytes == null
        ? null
        : SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: FilledButton.icon(
                onPressed: _exporting ? null : _export,
                icon: _exporting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.download_outlined),
                label: Text(
                  _exporting ? 'Membuat PDF...' : 'Ekspor PDF (2 Halaman)',
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: const StadiumBorder(),
                ),
              ),
            ),
          ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _loadPdf,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          )
        : _controller == null
        ? const Center(child: Text('PDF tidak tersedia.'))
        : Column(
            children: [
              _ZoomToolbar(
                controller: _controller!,
                onZoom: _zoom,
                onFit: _fit,
              ),
              Expanded(
                child: PdfViewPinch(
                  controller: _controller!,
                  padding: 18,
                  backgroundDecoration: const BoxDecoration(
                    color: Color(0xFFE8F8F4),
                  ),
                ),
              ),
            ],
          ),
  );
}

class _ZoomToolbar extends StatelessWidget {
  const _ZoomToolbar({
    required this.controller,
    required this.onZoom,
    required this.onFit,
  });
  final PdfControllerPinch controller;
  final ValueChanged<double> onZoom;
  final VoidCallback onFit;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
    child: Row(
      children: [
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () => onZoom(0.85),
                  icon: const Icon(Icons.remove, size: 18),
                ),
                ValueListenableBuilder<Matrix4>(
                  valueListenable: controller,
                  builder: (_, value, child) => Text(
                    '${(controller.zoomRatio * 100).round()}%',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  onPressed: () => onZoom(1.18),
                  icon: const Icon(Icons.add, size: 18),
                ),
                TextButton(onPressed: onFit, child: const Text('Fit')),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
