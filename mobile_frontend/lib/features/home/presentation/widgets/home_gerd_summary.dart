import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/home_dashboard_data.dart';
import 'home_day_bar.dart';

class HomeGerdSummary extends StatelessWidget {
  const HomeGerdSummary({
    required this.logs,
    required this.periodStart,
    required this.periodEnd,
    this.onHistoryTap,
    super.key,
  });

  final List<HomeDailyLog> logs;
  final DateTime periodStart;
  final DateTime periodEnd;
  final VoidCallback? onHistoryTap;

  static const _days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  static const _months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A1F2D2B),
          blurRadius: 20,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GERD Level 7 Hari',
          style: TextStyle(
            color: AppColors.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${periodStart.day} ${_months[periodStart.month]} – '
          '${periodEnd.day} ${_months[periodEnd.month]}',
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [for (var index = 0; index < 7; index++) _buildDay(index)],
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton.icon(
            onPressed: onHistoryTap,
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('Lihat riwayat lengkap'),
          ),
        ),
      ],
    ),
  );

  Widget _buildDay(int index) {
    final date = periodStart.add(Duration(days: index));
    HomeDailyLog? log;
    for (final item in logs) {
      if (_sameDate(item.date, date)) {
        log = item;
        break;
      }
    }
    return HomeDayBar(
      day: _days[index],
      date: date.day.toString(),
      gerdLevel: log?.gerdLevel,
      hasLog: log != null,
    );
  }

  bool _sameDate(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
