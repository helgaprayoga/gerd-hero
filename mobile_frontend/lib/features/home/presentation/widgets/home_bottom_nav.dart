import 'package:flutter/material.dart';

import 'home_nav_item.dart';

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({super.key});

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
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        HomeNavItem(icon: Icons.home_outlined, label: 'Beranda', active: true),
        HomeNavItem(icon: Icons.insights_outlined, label: 'Analitik'),
        HomeNavItem(icon: Icons.description_outlined, label: 'Laporan'),
      ],
    ),
  );
}
