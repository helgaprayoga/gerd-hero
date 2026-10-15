import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/analytics_models.dart';
import 'history_detail_card_shell.dart';

class AnalyticsTrendCard extends StatefulWidget {
  const AnalyticsTrendCard({required this.data, super.key});

  final AnalyticsData data;

  @override
  State<AnalyticsTrendCard> createState() => _AnalyticsTrendCardState();
}

class _AnalyticsTrendCardState extends State<AnalyticsTrendCard> {
  int _selectedIndex = 0;

  void _selectPoint(Offset position, double width) {
    final count = widget.data.trend.length;
    if (count < 2) return;
    final chartWidth = width - 44;
    final rawIndex = ((position.dx - 32) / chartWidth * (count - 1)).round();
    setState(() => _selectedIndex = rawIndex.clamp(0, count - 1).toInt());
  }

  @override
  Widget build(BuildContext context) {
    final trend = widget.data.trend;
    final average = widget.data.averageLevel;
    return HistoryDetailCardShell(
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
              if (trend.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '● Rata-rata ${(average * 100).round()}%',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (trend.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'Belum ada log pada periode ini.',
                  style: TextStyle(color: AppColors.secondary),
                ),
              ),
            )
          else
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
                      points: trend,
                      selectedIndex: _selectedIndex.clamp(0, trend.length - 1),
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
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({required this.points, required this.selectedIndex});

  final List<AnalyticsTrendPoint> points;
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
    final chartPoints = [
      for (var i = 0; i < points.length; i++)
        Offset(
          chart.left +
              chart.width *
                  (points.length == 1 ? 0.5 : i / (points.length - 1)),
          chart.bottom - chart.height * points[i].level.clamp(0.0, 1.0),
        ),
    ];
    final path = Path()..moveTo(chartPoints.first.dx, chartPoints.first.dy);
    for (final point in chartPoints.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    final area = Path.from(path)
      ..lineTo(chartPoints.last.dx, chart.bottom)
      ..lineTo(chartPoints.first.dx, chart.bottom)
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
    for (var i = 0; i < chartPoints.length; i++) {
      canvas.drawCircle(
        chartPoints[i],
        i == selectedIndex ? 7 : 4,
        Paint()..color = i == selectedIndex ? AppColors.tertiary : Colors.white,
      );
      canvas.drawCircle(
        chartPoints[i],
        i == selectedIndex ? 4 : 3,
        Paint()..color = AppColors.primary,
      );
    }
    _drawAxisLabels(canvas, points, chartPoints, chart);
    _drawTooltip(
      canvas,
      chartPoints[selectedIndex],
      points[selectedIndex],
      chart,
    );
  }

  void _drawAxisLabels(
    Canvas canvas,
    List<AnalyticsTrendPoint> values,
    List<Offset> points,
    Rect chart,
  ) {
    final step = values.length > 10 ? (values.length / 7).ceil() : 1;
    for (var i = 0; i < values.length; i += step) {
      final label = '${values[i].date.day}/${values[i].date.month}';
      final painter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(color: AppColors.secondary, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(points[i].dx - painter.width / 2, chart.bottom + 12),
      );
    }
    for (final item in [(0.0, '100%'), (0.5, '50%'), (1.0, '0%')]) {
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
    AnalyticsTrendPoint value,
    Rect chart,
  ) {
    final text =
        '${value.percent}% · ${value.percent > 45 ? 'Puncak Refluks' : 'Stabil'}';
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
    if (point.dy > top + 24) {
      canvas.drawRect(
        Rect.fromLTWH(point.dx - 1, top + 24, 2, point.dy - top - 24),
        Paint()..color = AppColors.tertiary,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.selectedIndex != selectedIndex ||
      oldDelegate.points != points;
}
