import 'package:flutter/material.dart';

import 'home_bottom_nav.dart';

class AnalyticsBottomNav extends StatelessWidget {
  const AnalyticsBottomNav({
    required this.onHome,
    required this.onReports,
    super.key,
  });
  final VoidCallback onHome;
  final VoidCallback onReports;
  @override
  Widget build(BuildContext context) => HomeBottomNav(
    active: 'Analitik',
    onHome: onHome,
    onAnalytics: () {},
    onReports: onReports,
  );
}
