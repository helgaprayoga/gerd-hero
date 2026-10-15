import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'mascot_expression.dart';

class MascotPainter extends CustomPainter {
  const MascotPainter({this.expression = MascotExpression.calm});

  final MascotExpression expression;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 200;
    canvas.save();
    canvas.scale(scale);

    final bodyColors = expression == MascotExpression.high
        ? const [Color(0xFFFFE7B2), Color(0xFFF4B942), Color(0xFFD08800)]
        : const [
            AppColors.primaryFixed,
            AppColors.primaryContainer,
            AppColors.primary,
          ];

    final body = Path()
      ..moveTo(100, 24)
      ..cubicTo(100, 24, 156, 82, 156, 122)
      ..cubicTo(156, 153, 131, 178, 100, 178)
      ..cubicTo(69, 178, 44, 153, 44, 122)
      ..cubicTo(44, 82, 100, 24, 100, 24);
    canvas.drawPath(
      body,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.topLeft,
          radius: 1.4,
          colors: bodyColors,
          stops: [0, 0.6, 1],
        ).createShader(const Rect.fromLTWH(44, 24, 112, 154)),
    );

    final highlight = Path()
      ..moveTo(100, 36)
      ..cubicTo(100, 36, 70, 78, 64, 108)
      ..cubicTo(62, 100, 66, 84, 76, 68)
      ..cubicTo(86, 52, 100, 36, 100, 36);
    canvas.drawPath(
      highlight,
      Paint()..color = Colors.white.withValues(alpha: 0.38),
    );

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(100, 132), width: 68, height: 56),
      Paint()
        ..shader = const LinearGradient(
          colors: [Colors.white, Color(0x99E1F1EE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(const Rect.fromLTWH(66, 104, 68, 56)),
    );

    final cheek = Paint()
      ..color = AppColors.tertiaryFixedDim.withValues(alpha: 0.55);
    canvas.drawCircle(const Offset(72, 116), 8, cheek);
    canvas.drawCircle(const Offset(128, 116), 8, cheek);

    final dark = Paint()..color = AppColors.onSurface;
    final eyeCenterY = expression == MascotExpression.welcome ? 101.0 : 104.0;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(78, eyeCenterY), width: 15, height: 18),
      dark,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(122, eyeCenterY), width: 15, height: 18),
      dark,
    );
    final white = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(80.5, eyeCenterY - 3.5), 3.2, white);
    canvas.drawCircle(Offset(76, eyeCenterY + 2.5), 1.4, white);
    canvas.drawCircle(Offset(124.5, eyeCenterY - 3.5), 3.2, white);
    canvas.drawCircle(Offset(120, eyeCenterY + 2.5), 1.4, white);

    final smile = Path();
    if (expression == MascotExpression.high) {
      smile
        ..moveTo(92, 120)
        ..cubicTo(94.5, 115, 105.5, 115, 108, 120);
    } else if (expression == MascotExpression.moderate) {
      smile
        ..moveTo(92, 117)
        ..lineTo(108, 117);
    } else {
      smile
        ..moveTo(92, 114)
        ..cubicTo(94.5, 119, 105.5, 119, 108, 114);
    }
    canvas.drawPath(
      smile,
      Paint()
        ..color = AppColors.onSurface
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    final star = Path()
      ..moveTo(100, 120)
      ..lineTo(102.5, 127)
      ..lineTo(109, 129.5)
      ..lineTo(102.5, 132)
      ..lineTo(100, 139)
      ..lineTo(97.5, 132)
      ..lineTo(91, 129.5)
      ..lineTo(97.5, 127)
      ..close();
    canvas.drawPath(
      star,
      Paint()
        ..color =
            (expression == MascotExpression.high
                    ? AppColors.tertiary
                    : AppColors.primaryContainer)
                .withValues(alpha: 0.9),
    );
    _drawSparkle(canvas, const Offset(152, 54), 8, AppColors.tertiaryFixedDim);
    _drawSparkle(canvas, const Offset(42, 83.5), 6, AppColors.primaryFixed);
    canvas.restore();
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, Color color) {
    final sparkle = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx + 2, center.dy - 2)
      ..lineTo(center.dx + radius, center.dy)
      ..lineTo(center.dx + 2, center.dy + 2)
      ..lineTo(center.dx, center.dy + radius)
      ..lineTo(center.dx - 2, center.dy + 2)
      ..lineTo(center.dx - radius, center.dy)
      ..lineTo(center.dx - 2, center.dy - 2)
      ..close();
    canvas.drawPath(sparkle, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant MascotPainter oldDelegate) =>
      oldDelegate.expression != expression;
}
