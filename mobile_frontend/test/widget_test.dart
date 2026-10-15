import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_frontend/app/app.dart';
import 'package:mobile_frontend/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:mobile_frontend/features/auth/presentation/pages/check_email_page.dart';
import 'package:mobile_frontend/features/auth/presentation/pages/new_password_page.dart';
import 'package:mobile_frontend/features/auth/presentation/pages/login_page.dart';
import 'package:mobile_frontend/features/auth/presentation/pages/register_page.dart';
import 'package:mobile_frontend/features/onboarding/presentation/pages/disclaimer_page.dart';
import 'package:mobile_frontend/features/onboarding/presentation/pages/profile_page.dart';
import 'package:mobile_frontend/features/onboarding/presentation/pages/gerdq_intro_page.dart';
import 'package:mobile_frontend/features/onboarding/presentation/pages/gerdq_question_page.dart';
import 'package:mobile_frontend/features/onboarding/presentation/pages/gerdq_result_page.dart';
import 'package:mobile_frontend/features/home/presentation/models/home_scenario.dart';
import 'package:mobile_frontend/features/home/data/models/daily_log_models.dart';
import 'package:mobile_frontend/features/home/presentation/pages/home_page.dart';
import 'package:mobile_frontend/features/home/presentation/widgets/home_loading_skeleton.dart';
import 'package:mobile_frontend/features/home/presentation/pages/daily_log_step_one_page.dart';
import 'package:mobile_frontend/features/home/presentation/pages/daily_log_step_two_page.dart';
import 'package:mobile_frontend/features/home/presentation/pages/daily_log_summary_page.dart';
import 'package:mobile_frontend/features/home/presentation/pages/daily_history_page.dart';

void main() {
  testWidgets('renders the GERDHero landing page', (tester) async {
    await tester.pumpWidget(const GerdHeroApp());

    expect(find.text('GERDHero'), findsOneWidget);
    expect(find.text('Mulai'), findsOneWidget);
    expect(find.text('Sudah punya akun? Masuk'), findsNothing);
  });

  testWidgets('enables disclaimer continuation after agreement', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DisclaimerPage()));

    expect(find.text('Medical Disclaimer'), findsOneWidget);
    expect(find.text('Saya memahami dan menyetujui.'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Saya memahami dan menyetujui.'),
      300,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.text('Saya memahami dan menyetujui.'));
    await tester.pumpAndSettle();

    expect(find.text('Lanjutkan'), findsOneWidget);
  });

  testWidgets('switches between login and registration in one page', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    expect(find.text('Selamat Datang Kembali'), findsOneWidget);
    expect(find.text('Lupa kata sandi?'), findsOneWidget);

    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();

    expect(find.text('Buat akun baru'), findsOneWidget);
    expect(find.text('Daftar'), findsNWidgets(2));
    expect(find.text('Konfirmasi kata sandi'), findsOneWidget);
  });

  testWidgets('does not bypass Supabase authentication during login', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'user@example.com');
    await tester.enterText(fields.at(1), 'Password123');
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfilePage), findsNothing);
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Periksa kembali'), findsOneWidget);
  });

  testWidgets('shows validation messages only after invalid input', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    expect(find.text('Format email tidak valid'), findsNothing);
    expect(find.text('Rendah'), findsNothing);
    expect(find.text('Kata sandi tidak cocok'), findsNothing);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'invalid-email');
    await tester.enterText(fields.at(1), 'abc');
    await tester.enterText(fields.at(2), 'xyz');
    await tester.pump();

    expect(find.text('Format email tidak valid'), findsOneWidget);
    expect(find.text('Rendah'), findsOneWidget);
    expect(find.text('Kata sandi tidak cocok'), findsOneWidget);
  });

  testWidgets('requires a name before saving the profile', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

    await tester.scrollUntilVisible(
      find.text('Lanjut'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();

    expect(find.text('Nama panggilan wajib diisi.'), findsOneWidget);
    expect(find.byType(GerdQIntroPage), findsNothing);
  });

  testWidgets('starts GERD-Q first question from preparation', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: GerdQIntroPage()));

    await tester.tap(find.text('Mulai'));
    await tester.pumpAndSettle();

    expect(find.byType(GerdQQuestionPage), findsOneWidget);
    expect(find.text('Soal 1 dari 6'), findsOneWidget);
    expect(
      find.textContaining(
        'Seberapa sering kamu merasakan nyeri terbakar di dada (heartburn)?',
      ),
      findsOneWidget,
    );
    expect(find.text('2–3 hari'), findsOneWidget);
  });

  testWidgets('returns to profile from GERD-Q preparation', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: GerdQIntroPage()));

    await tester.tap(find.byTooltip('Kembali ke profil'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfilePage), findsOneWidget);
    expect(find.text('Data Profil'), findsOneWidget);
  });

  testWidgets('continues from GERD-Q question to evaluation result', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: GerdQQuestionPage()));

    for (var question = 0; question < 6; question++) {
      await tester.tap(find.text('2–3 hari'));
      await tester.pump();
      final buttonLabel = question == 5 ? 'Lihat hasil' : 'Lanjut';
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, buttonLabel),
      );
      await tester.tap(find.widgetWithText(FilledButton, buttonLabel));
      await tester.pump();
    }
    await tester.pumpAndSettle();

    expect(find.byType(GerdQResultPage), findsOneWidget);
    expect(find.text('Hasil Evaluasi Anda'), findsOneWidget);
    expect(find.text('10 / 18'), findsOneWidget);
    expect(find.text('Kemungkinan menderita GERD'), findsNWidgets(2));
    expect(
      find.textContaining('Jangan khawatir, Gerdie siap membantumu'),
      findsOneWidget,
    );
    expect(find.text('Interpretasi Hasil'), findsOneWidget);
  });

  testWidgets('renders all four home scenarios', (tester) async {
    for (final scenario in HomeScenario.values) {
      await tester.pumpWidget(MaterialApp(home: HomePage(scenario: scenario)));
      await tester.pumpAndSettle();

      expect(find.text('Halo, Dion'), findsOneWidget);
      expect(find.text('GERD Level 7 Hari'), findsOneWidget);
    }
  });

  testWidgets('shows home skeleton while profile is loading', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    expect(find.byType(HomeLoadingSkeleton), findsOneWidget);
  });

  testWidgets('skips profile directly to dashboard', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

    await tester.tap(find.text('Lewati'));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Halo, Dion'), findsOneWidget);
  });

  testWidgets('opens daily log step one from floating action button', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    await tester.pumpAndSettle();
    await tester.tap(find.text('Isi Log Harian'));
    await tester.pumpAndSettle();

    expect(find.byType(DailyLogStepOnePage), findsOneWidget);
    expect(find.text('LANGKAH 1 DARI 3'), findsOneWidget);
    expect(
      find.text('Gejala apa yang kamu rasakan\nhari ini?'),
      findsOneWidget,
    );
    expect(find.text('0 Dipilih'), findsOneWidget);
  });

  testWidgets('blocks a second daily log from the floating action button', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomePage(scenario: HomeScenario.loggedToday)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Isi Log Harian'));
    await tester.pump();

    expect(find.byType(DailyLogStepOnePage), findsNothing);
    expect(find.text('Log harian sudah diisi'), findsOneWidget);
    expect(
      find.text('Kamu sudah mengisi log harian hari ini.'),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('opens complete history from the home summary link', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Lihat riwayat lengkap'));
    await tester.tap(find.text('Lihat riwayat lengkap'));
    await tester.pumpAndSettle();

    expect(find.byType(RiwayatLengkapPage), findsOneWidget);
    expect(find.text('Riwayat Lengkap'), findsOneWidget);
  });

  testWidgets('renders history entries and navigates between weeks', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RiwayatLengkapPage()));

    expect(find.text('6 – 12 Okt 2026'), findsOneWidget);
    expect(find.text('Minggu, 12 Okt'), findsOneWidget);
    expect(find.text('39%'), findsOneWidget);
    expect(find.text('Heartburn'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Belum ada catatan harian'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Belum ada catatan harian'), findsOneWidget);
    expect(find.text('+ Isi Susulan'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pump();
    expect(find.text('29 Sep – 5 Okt 2026'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pump();
    expect(find.text('6 – 12 Okt 2026'), findsOneWidget);
  });

  testWidgets('hides and restores symptom list from no-symptom toggle', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DailyLogStepOnePage()));

    expect(find.text('Heartburn (rasa terbakar di dada)'), findsOneWidget);
    await tester.tap(find.text('Tidak ada gejala'));
    await tester.pump();
    expect(find.text('Heartburn (rasa terbakar di dada)'), findsNothing);

    await tester.tap(find.text('Tidak ada gejala'));
    await tester.pump();
    expect(find.text('Heartburn (rasa terbakar di dada)'), findsOneWidget);
  });

  testWidgets('opens daily log step two with both meal time states', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DailyLogStepOnePage()));
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Lanjut'));
    await tester.tap(find.widgetWithText(FilledButton, 'Lanjut'));
    await tester.pumpAndSettle();

    expect(find.byType(DailyLogStepTwoPage), findsOneWidget);
    expect(find.text('Pemicu & Kebiasaan'), findsOneWidget);
    expect(find.text('3x'), findsOneWidget);

    await tester.ensureVisible(find.text('Ubah / Sesuaikan'));
    await tester.tap(find.text('Ubah / Sesuaikan'));
    await tester.pump();
    expect(find.text('Makan ke-1'), findsOneWidget);
    expect(find.text('07:30'), findsOneWidget);
  });

  testWidgets('continues from daily log step two to the summary', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DailyLogStepTwoPage(
          submitter: (_) async => DailyLogResponse.demo(),
        ),
      ),
    );

    await tester.ensureVisible(find.text('Simpan & Lanjutkan'));
    await tester.tap(find.text('Simpan & Lanjutkan'));
    await tester.pumpAndSettle();

    expect(find.byType(DailyLogSummaryPage), findsOneWidget);
    expect(find.text('Ringkasan Hari Ini'), findsOneWidget);
    expect(find.text('39%'), findsOneWidget);
    expect(find.text('Pemicu Berkaitan'), findsOneWidget);
    expect(find.text('Selesai • Kembali ke Beranda'), findsOneWidget);
  });

  testWidgets('finishes the daily summary at the home page', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DailyLogSummaryPage()));

    await tester.ensureVisible(find.text('Selesai • Kembali ke Beranda'));
    await tester.tap(find.text('Selesai • Kembali ke Beranda'));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Halo, Dion'), findsOneWidget);
  });

  testWidgets('opens forgot password page from login', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    await tester.tap(find.text('Lupa kata sandi?'));
    await tester.pumpAndSettle();

    expect(find.byType(ForgotPasswordPage), findsOneWidget);
    expect(find.text('Kirim Tautan'), findsOneWidget);
  });

  testWidgets('opens check email page after valid reset request', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordPage()));

    await tester.enterText(find.byType(TextFormField), 'user@example.com');
    await tester.tap(find.text('Kirim Tautan'));
    await tester.pumpAndSettle();

    expect(find.byType(CheckEmailPage), findsOneWidget);
    expect(find.text('Cek emailmu'), findsOneWidget);
    expect(find.textContaining('user@example.com'), findsOneWidget);

    await tester.tap(find.text('Buka Aplikasi Email'));
    await tester.pumpAndSettle();

    expect(find.byType(NewPasswordPage), findsOneWidget);
    expect(find.text('Buat kata sandi baru'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Simpan Kata Sandi'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Simpan Kata Sandi'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });
}
