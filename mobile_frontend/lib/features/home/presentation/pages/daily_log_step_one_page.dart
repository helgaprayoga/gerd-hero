import 'package:flutter/material.dart';

import 'daily_log_step_two_page.dart';
import '../widgets/daily_log_step_one_view.dart';

class DailyLogStepOnePage extends StatelessWidget {
  const DailyLogStepOnePage({super.key});

  @override
  Widget build(BuildContext context) => DailyLogStepOneView(
    onNext: () => Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const DailyLogStepTwoPage()),
    ),
  );
}
