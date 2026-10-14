import 'package:flutter/material.dart';

import 'daily_log_step_two_page.dart';
import '../widgets/daily_log_step_one_view.dart';

class DailyLogStepOnePage extends StatelessWidget {
  const DailyLogStepOnePage({this.dateLabel = 'hari ini', super.key});
  final String dateLabel;

  @override
  Widget build(BuildContext context) => DailyLogStepOneView(
    dateLabel: dateLabel,
    onNext: () => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DailyLogStepTwoPage(dateLabel: dateLabel),
      ),
    ),
  );
}
