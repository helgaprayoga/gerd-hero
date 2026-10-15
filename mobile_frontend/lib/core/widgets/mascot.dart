import 'package:flutter/material.dart';

import 'mascot_expression.dart';
import 'mascot_painter.dart';

class Mascot extends StatelessWidget {
  const Mascot({
    required this.animation,
    this.expression = MascotExpression.calm,
    super.key,
  });

  final Animation<double> animation;
  final MascotExpression expression;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    builder: (context, child) => Transform.rotate(
      angle: animation.value,
      child: Transform.scale(
        scale: animation.value == 0 ? 1 : 1.06,
        child: child,
      ),
    ),
    child: CustomPaint(
      size: const Size.square(176),
      painter: MascotPainter(expression: expression),
    ),
  );
}
