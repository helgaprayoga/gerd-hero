import 'package:flutter/material.dart';

import 'daily_log_summary_page.dart';
import '../widgets/daily_log_step_two_view.dart';

class DailyLogStepTwoPage extends StatelessWidget {
  const DailyLogStepTwoPage({this.initialSameAsYesterday = true, super.key});

  final bool initialSameAsYesterday;

  void _openSummary(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const DailyLogSummaryPage()),
    );
  }

  @override
  Widget build(BuildContext context) => DailyLogStepTwoView(
    initialSameAsYesterday: initialSameAsYesterday,
    onContinue: () => _openSummary(context),
  );
}
