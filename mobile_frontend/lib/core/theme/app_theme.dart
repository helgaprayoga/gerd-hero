import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          primaryContainer: AppColors.primaryContainer,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          secondary: AppColors.secondary,
          outline: AppColors.outline,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: TextTheme(
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 28,
          height: 36 / 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.28,
        ),
        bodyLarge: GoogleFonts.inter(fontSize: 16, height: 26 / 16),
        bodyMedium: GoogleFonts.inter(fontSize: 14, height: 22 / 14),
        bodySmall: GoogleFonts.inter(fontSize: 12, height: 18 / 12),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
