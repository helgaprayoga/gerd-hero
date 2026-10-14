import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/landing/presentation/pages/landing_page.dart';
import '../features/onboarding/presentation/pages/disclaimer_page.dart';

class GerdHeroApp extends StatelessWidget {
  const GerdHeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GERDHero',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: child,
      ),
      home: LandingPage(
        onStart: (context) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DisclaimerPage(
                onContinue: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const LoginPage()),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
