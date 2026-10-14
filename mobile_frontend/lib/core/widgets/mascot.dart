import 'package:flutter/material.dart';

import 'mascot_painter.dart';

class Mascot extends StatelessWidget {
  const Mascot({required this.animation, super.key});

  final Animation<double> animation;

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
    child: CustomPaint(size: const Size.square(176), painter: MascotPainter()),
  );
}
