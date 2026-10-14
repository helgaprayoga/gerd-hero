import 'package:flutter/material.dart';

import 'daily_log_summary_page.dart';
import '../models/daily_log_draft.dart';
import '../widgets/daily_log_step_two_view.dart';

class DailyLogStepTwoPage extends StatelessWidget {
  const DailyLogStepTwoPage({
    this.draft,
    this.dateLabel = 'hari ini',
    this.initialSameAsYesterday = true,
    super.key,
  });

  final String dateLabel;
  final DailyLogDraft? draft;
  final bool initialSameAsYesterday;

  void _openSummary(BuildContext context, DailyLogDraft draft) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DailyLogSummaryPage(draft: draft),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => DailyLogStepTwoView(
    dateLabel: dateLabel,
    draft: draft,
    initialSameAsYesterday: initialSameAsYesterday,
    onContinue: (draft) => _openSummary(context, draft),
  );
}
