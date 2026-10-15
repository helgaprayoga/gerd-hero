import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_frontend/features/auth/presentation/widgets/password_strength_meter.dart';
import 'package:mobile_frontend/features/home/presentation/widgets/home_header.dart';
import 'package:mobile_frontend/features/home/presentation/widgets/home_gerd_summary.dart';
import 'package:mobile_frontend/features/landing/presentation/widgets/landing_top_bar.dart';
import 'package:mobile_frontend/features/onboarding/presentation/widgets/bmi_card.dart';
import 'package:mobile_frontend/features/onboarding/presentation/widgets/gerdq_score_card.dart';

void main() {
  testWidgets('priority widgets fit a compact 320px viewport', (tester) async {
    final widgets = <Widget>[
      const HomeHeader(
        nickname: 'Nama pengguna yang sangat panjang',
        avatarLabel: 'N',
      ),
      HomeGerdSummary(
        logs: [],
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 7),
      ),
      const GerdQScoreCard(score: 18),
      const PasswordStrengthMeter(password: 'Password123!'),
      BmiCard(height: 170, weight: 70),
      LandingTopBar(),
    ];

    for (final widget in widgets) {
      await _pumpAtWidth(tester, widget, textScale: 2);
      expect(tester.takeException(), isNull, reason: 'Overflow in $widget');
    }
  });

  testWidgets('long result text remains safe at large text scale', (
    tester,
  ) async {
    await _pumpAtWidth(tester, const GerdQScoreCard(score: 6), textScale: 2);

    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpAtWidth(
  WidgetTester tester,
  Widget child, {
  required double textScale,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: SingleChildScrollView(
            child: SizedBox(width: 320, child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}
