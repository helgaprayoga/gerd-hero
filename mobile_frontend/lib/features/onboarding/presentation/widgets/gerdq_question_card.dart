import 'package:flutter/material.dart';

import 'gerdq_answer_option.dart';

class GerdQQuestionCard extends StatelessWidget {
  const GerdQQuestionCard({
    required this.answers,
    required this.selectedAnswer,
    required this.onAnswerSelected,
    super.key,
  });

  final List<String> answers;
  final String? selectedAnswer;
  final ValueChanged<String> onAnswerSelected;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final answer in answers) ...[
        GerdQAnswerOption(
          label: answer,
          selected: answer == selectedAnswer,
          onTap: () => onAnswerSelected(answer),
        ),
        if (answer != answers.last) const SizedBox(height: 10),
      ],
    ],
  );
}
