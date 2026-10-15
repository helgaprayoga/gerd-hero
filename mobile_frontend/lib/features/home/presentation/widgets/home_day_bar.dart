import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HomeDayBar extends StatelessWidget {
  const HomeDayBar({
    required this.day,
    required this.date,
    required this.gerdLevel,
    required this.hasLog,
    super.key,
  });

  final String day;
  final String date;
  final double? gerdLevel;
  final bool hasLog;

  static const _minBarHeight = 10.0;
  static const _maxBarHeight = 64.0;

  double get _level => (gerdLevel ?? 0).clamp(0.0, 1.0);

  int get _percent => (_level * 100).round();

  Color get _barColor {
    if (!hasLog) return AppColors.secondaryContainer;
    if (_level < 0.33) return AppColors.primary;
    if (_level < 0.66) return AppColors.tertiary;
    return AppColors.error;
  }

  String get _levelLabel {
    if (_level < 0.33) return 'Rendah';
    if (_level < 0.66) return 'Sedang';
    return 'Tinggi';
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final cardHeight = (150 + (textScale - 1).clamp(0, 2) * 24).toDouble();
    final barHeight = hasLog
        ? _minBarHeight + _level * _maxBarHeight
        : _minBarHeight;
    final bar = Container(
      width: 18,
      height: barHeight,
      decoration: BoxDecoration(
        color: _barColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: hasLog
          ? null
          : const Center(
              child: Text('-', style: TextStyle(color: AppColors.secondary)),
            ),
    );

    return Container(
      width: double.infinity,
      height: cardHeight,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: hasLog ? AppColors.surfaceContainerLow : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasLog ? AppColors.primary : AppColors.secondaryContainer,
          width: hasLog ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              day,
              style: const TextStyle(fontSize: 10, color: AppColors.secondary),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              date,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ),
          if (hasLog)
            Tooltip(
              richMessage: TextSpan(
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: _barColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  TextSpan(
                    text: '$_percent% · $_levelLabel',
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              triggerMode: TooltipTriggerMode.tap,
              preferBelow: false,
              showDuration: const Duration(seconds: 2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.secondaryContainer),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14101E1C),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: bar,
            )
          else
            bar,
        ],
      ),
    );
  }
}
