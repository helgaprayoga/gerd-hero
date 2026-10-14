import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/new_password_page.dart';
import '../features/auth/presentation/pages/profile_gate_page.dart';
import '../features/landing/presentation/pages/landing_page.dart';
import '../features/onboarding/presentation/pages/disclaimer_page.dart';

class GerdHeroApp extends StatefulWidget {
  const GerdHeroApp({super.key});

  @override
  State<GerdHeroApp> createState() => _GerdHeroAppState();
}

class _GerdHeroAppState extends State<GerdHeroApp> {
  StreamSubscription<AuthState>? _authSubscription;
  bool _isRoutingAfterAuth = false;

  @override
  void initState() {
    super.initState();

    // Dengarkan perubahan status autentikasi Supabase.
    // Dipanggil setelah Google OAuth callback diterima oleh deep link.
    try {
      _authSubscription = Supabase.instance.client.auth.onAuthStateChange
          .listen((data) {
            final session = data.session;
            final event = data.event;

            if (event == AuthChangeEvent.passwordRecovery) {
              _routeToPasswordReset();
            } else if (event == AuthChangeEvent.signedIn &&
                session != null &&
                !_isRoutingAfterAuth) {
              _routeAfterAuth();
            } else if (event == AuthChangeEvent.signedOut) {
              _isRoutingAfterAuth = false;
              _routeAfterSignOut();
            }
          });
    } on AssertionError {
      // Widget tests may render the shell without initializing Supabase.
    }
  }

  void _routeAfterAuth() {
    if (!mounted || _isRoutingAfterAuth) return;
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _routeAfterAuth());
      return;
    }

    _isRoutingAfterAuth = true;
    navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const ProfileGatePage()),
      (route) => false,
    );
  }

  void _routeAfterSignOut() {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _routeToPasswordReset() {
    if (!mounted) return;
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _routeToPasswordReset());
      return;
    }

    navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const NewPasswordPage()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
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
      home: const _AuthBootstrapPage(),
    );
  }
}

/// GlobalKey untuk navigator — dipakai oleh auth listener agar bisa
/// navigate tanpa BuildContext dari luar widget tree.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class _AuthBootstrapPage extends StatefulWidget {
  const _AuthBootstrapPage();

  @override
  State<_AuthBootstrapPage> createState() => _AuthBootstrapPageState();
}

class _AuthBootstrapPageState extends State<_AuthBootstrapPage> {
  Widget? _destination;

  @override
  void initState() {
    super.initState();
    _resolveInitialRoute();
  }

  Future<void> _resolveInitialRoute() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (!mounted) return;
      setState(() {
        _destination = session == null
            ? _landingPage()
            : const ProfileGatePage();
      });
    } on AssertionError {
      if (mounted) setState(() => _destination = _landingPage());
    }
  }

  Widget _landingPage() => LandingPage(
        onStart: (context) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DisclaimerPage(
                onContinue: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const LoginPage(),
                    ),
                  );
                },
              ),
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) =>
      _destination ?? const Scaffold(body: Center(child: CircularProgressIndicator()));
}
