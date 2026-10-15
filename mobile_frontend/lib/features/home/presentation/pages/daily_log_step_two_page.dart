import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../data/models/daily_log_models.dart';
import '../../data/repositories/daily_log_repository.dart';
import '../../domain/entities/daily_log_draft.dart';
import 'daily_log_summary_page.dart';
import '../widgets/daily_log_step_two_view.dart';

class DailyLogStepTwoPage extends StatefulWidget {
  const DailyLogStepTwoPage({
    this.draft,
    this.dateLabel = 'hari ini',
    this.initialSameAsYesterday = true,
    this.repository,
    this.submitter,
    this.finishLabel = 'Kembali ke Beranda',
    this.onFinish,
    super.key,
  });

  final String dateLabel;
  final DailyLogDraft? draft;
  final bool initialSameAsYesterday;
  final DailyLogRepository? repository;
  final Future<DailyLogResponse> Function(DailyLogDraft)? submitter;
  final String finishLabel;
  final VoidCallback? onFinish;

  @override
  State<DailyLogStepTwoPage> createState() => _DailyLogStepTwoPageState();
}

class _DailyLogStepTwoPageState extends State<DailyLogStepTwoPage> {
  late final DailyLogDraft _draft;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _draft = widget.draft ?? DailyLogDraft(logDate: DateTime.now());
  }

  Future<void> _submit(BuildContext context) async {
    if (_isSubmitting) return;
    final navigator = Navigator.of(context);
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final response = widget.submitter != null
          ? await widget.submitter!(_draft)
          : await (widget.repository ?? DailyLogRepository()).createOrUpdate(
              _draft,
            );
      if (!mounted) return;
      await navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => DailyLogSummaryPage(
            response: response,
            draft: _draft,
            finishLabel: widget.finishLabel,
            onFinish: widget.onFinish,
          ),
        ),
      );
    } on ApiException catch (error) {
      if (mounted) setState(() => _errorMessage = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'Log belum dapat disimpan. Coba lagi.');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      DailyLogStepTwoView(
        dateLabel: widget.dateLabel,
        initialSameAsYesterday: widget.initialSameAsYesterday,
        repository: widget.repository,
        draft: _draft,
        onContinue: () => _submit(context),
      ),
      if (_isSubmitting)
        const Positioned.fill(
          child: ColoredBox(
            color: Color(0x66000000),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      if (_errorMessage != null)
        Positioned(
          left: 16,
          right: 16,
          bottom: 92,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_errorMessage!)),
                  IconButton(
                    onPressed: () => setState(() => _errorMessage = null),
                    icon: const Icon(Icons.close),
                    tooltip: 'Tutup pesan',
                  ),
                ],
              ),
            ),
          ),
        ),
    ],
  );
}
