import 'package:flutter/material.dart';

import '../../../../core/utils/local_date.dart';
import '../../domain/entities/daily_log_draft.dart';
import 'daily_log_step_two_page.dart';
import '../widgets/daily_log_step_one_view.dart';

class DailyLogStepOnePage extends StatefulWidget {
  const DailyLogStepOnePage({
    this.dateLabel = 'hari ini',
    this.logDate,
    this.draft,
    this.finishLabel = 'Kembali ke Beranda',
    this.onFinish,
    super.key,
  });

  final String dateLabel;
  final DateTime? logDate;
  final DailyLogDraft? draft;
  final String finishLabel;
  final VoidCallback? onFinish;

  @override
  State<DailyLogStepOnePage> createState() => _DailyLogStepOnePageState();
}

class _DailyLogStepOnePageState extends State<DailyLogStepOnePage> {
  late final DailyLogDraft _draft;

  @override
  void initState() {
    super.initState();
    _draft =
        widget.draft ?? DailyLogDraft(logDate: localDateOnly(widget.logDate));
  }

  @override
  Widget build(BuildContext context) => DailyLogStepOneView(
    dateLabel: widget.dateLabel,
    draft: _draft,
    onNext: () => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DailyLogStepTwoPage(
          dateLabel: widget.dateLabel,
          draft: _draft,
          finishLabel: widget.finishLabel,
          onFinish: widget.onFinish,
        ),
      ),
    ),
  );
}
