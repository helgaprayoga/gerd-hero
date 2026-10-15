import 'package:flutter/material.dart';

import 'home_nav_item.dart';

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({
    this.active = 'Beranda',
    this.onHome,
    this.onAnalytics,
    this.onReports,
    super.key,
  });

  final String active;
  final VoidCallback? onHome;
  final VoidCallback? onAnalytics;
  final VoidCallback? onReports;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
    decoration: const BoxDecoration(
      color: Color(0xE6EDFDF9),
      boxShadow: [
        BoxShadow(
          color: Color(0x0A1F2D2B),
          blurRadius: 16,
          offset: Offset(0, -4),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: HomeNavItem(
            icon: Icons.home_outlined,
            label: 'Beranda',
            active: active == 'Beranda',
            onTap: onHome,
          ),
        ),
        Expanded(
          child: HomeNavItem(
            icon: Icons.insights_outlined,
            label: 'Analitik',
            active: active == 'Analitik',
            onTap: onAnalytics,
          ),
        ),
        Expanded(
          child: HomeNavItem(
            icon: Icons.description_outlined,
            label: 'Laporan',
            active: active == 'Laporan',
            onTap: onReports,
          ),
        ),
      ],
    ),
  );
}
