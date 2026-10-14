import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'history_detail_card_shell.dart';

class AnalyticsTrendCard extends StatefulWidget {
  const AnalyticsTrendCard({required this.monthly, super.key});
  final bool monthly;

  @override
  State<AnalyticsTrendCard> createState() => _AnalyticsTrendCardState();
}

class _AnalyticsTrendCardState extends State<AnalyticsTrendCard> {
  int _selectedIndex = 4;

  void _selectPoint(Offset localPosition, double width) {
    final chartWidth = width - 44;
    final rawIndex = ((localPosition.dx - 32) / chartWidth * 6).round();
    setState(() => _selectedIndex = rawIndex.clamp(0, 6).toInt());
  }

  @override
  Widget build(BuildContext context) => HistoryDetailCardShell(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tren Indeks Gejala',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2),
                Text(
                  'Skala fluktuasi keparahan asam',
                  style: TextStyle(color: AppColors.secondary, fontSize: 12),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                '● Rata-rata 28%\n   Stabil',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) => GestureDetector(
            onTapDown: (details) =>
                _selectPoint(details.localPosition, constraints.maxWidth),
            onHorizontalDragUpdate: (details) =>
                _selectPoint(details.localPosition, constraints.maxWidth),
            child: SizedBox(
              height: 220,
              child: CustomPaint(
                painter: _TrendPainter(
                  monthly: widget.monthly,
                  selectedIndex: _selectedIndex,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({required this.monthly, required this.selectedIndex});
  final bool monthly;
  final int selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final chart = Rect.fromLTWH(32, 36, size.width - 44, size.height - 72);
    final grid = Paint()
      ..color = AppColors.secondaryContainer
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = chart.top + chart.height * i / 3;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), grid);
    }
    final values = monthly
        ? [0.35, 0.42, 0.28, 0.56, 0.44, 0.38, 0.52]
        : [0.24, 0.31, 0.22, 0.35, 0.52, 0.29, 0.18];
    final labels = monthly
        ? ['M1', 'M2', 'M3', 'M4', 'M5', 'M6', 'M7']
        : ['Sen 6', 'Sel 7', 'Rab 8', 'Kam 9', 'Jum 10', 'Sab 11', 'Min 12'];
    final points = [
      for (var i = 0; i < values.length; i++)
        Offset(
          chart.left + chart.width * i / 6,
          chart.bottom - chart.height * values[i],
        ),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    final area = Path.from(path)
      ..lineTo(points.last.dx, chart.bottom)
      ..lineTo(points.first.dx, chart.bottom)
      ..close();
    canvas.drawPath(
      area,
      Paint()..color = AppColors.primary.withValues(alpha: 0.10),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(
        points[i],
        i == selectedIndex ? 7 : 4,
        Paint()..color = i == selectedIndex ? AppColors.tertiary : Colors.white,
      );
      canvas.drawCircle(
        points[i],
        i == selectedIndex ? 4 : 3,
        Paint()..color = AppColors.primary,
      );
    }
    _drawAxisLabels(canvas, labels, points, chart);
    _drawTooltip(
      canvas,
      points[selectedIndex],
      values[selectedIndex],
      labels[selectedIndex],
      chart,
    );
  }

  void _drawAxisLabels(
    Canvas canvas,
    List<String> labels,
    List<Offset> points,
    Rect chart,
  ) {
    for (var i = 0; i < labels.length; i++) {
      final painter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(color: AppColors.secondary, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(points[i].dx - painter.width / 2, chart.bottom + 12),
      );
    }
    for (final item in [(0.0, '75%'), (0.5, '50%'), (1.0, '25%')]) {
      final painter = TextPainter(
        text: TextSpan(
          text: item.$2,
          style: const TextStyle(color: AppColors.outline, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(0, chart.top + chart.height * item.$1 - painter.height / 2),
      );
    }
  }

  void _drawTooltip(
    Canvas canvas,
    Offset point,
    double value,
    String label,
    Rect chart,
  ) {
    final text =
        '${(value * 100).round()}% · ${value > 0.45 ? 'Puncak Refluks' : 'Stabil'}';
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: AppColors.onSurface,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final width = painter.width + 20;
    final left = (point.dx - width / 2).clamp(0.0, chart.right - width);
    final top = (point.dy - 34).clamp(0.0, chart.top);
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, width, 24),
      const Radius.circular(999),
    );
    canvas.drawRRect(rect, Paint()..color = const Color(0xFFCDDDDA));
    painter.paint(canvas, Offset(left + 10, top + 6));
    canvas.drawRect(
      Rect.fromLTWH(point.dx - 1, top + 24, 2, point.dy - top - 24),
      Paint()..color = AppColors.tertiary,
    );
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.monthly != monthly ||
      oldDelegate.selectedIndex != selectedIndex;
}
