import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/landing/presentation/pages/landing_page.dart';
import '../features/onboarding/presentation/pages/disclaimer_page.dart';
import '../features/onboarding/presentation/pages/profile_page.dart';

class GerdHeroApp extends StatefulWidget {
  const GerdHeroApp({super.key});

  @override
  State<GerdHeroApp> createState() => _GerdHeroAppState();
}

class _GerdHeroAppState extends State<GerdHeroApp> {
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();

    // Dengarkan perubahan status autentikasi Supabase.
    // Dipanggil setelah Google OAuth callback diterima oleh deep link.
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      final event = data.event;

      if (event == AuthChangeEvent.signedIn && session != null) {
        // Navigasi ke ProfilePage setelah login berhasil (Google OAuth maupun email).
        // Gunakan navigatorKey agar bisa navigate dari luar BuildContext widget tree.
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
          (route) => false, // Hapus semua route sebelumnya
        );
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GERDHero',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      navigatorKey: navigatorKey,
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

/// GlobalKey untuk navigator — dipakai oleh auth listener agar bisa
/// navigate tanpa BuildContext dari luar widget tree.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
