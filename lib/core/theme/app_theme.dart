import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      dividerColor: AppColors.border,
      filledButtonTheme: FilledButtonThemeData(style: _filledButtonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(style: _outlinedButtonStyle),
      inputDecorationTheme: _inputDecoration,
    );
  }

  static final _filledButtonStyle = ButtonStyle(
    backgroundColor: const WidgetStatePropertyAll(AppColors.primary),
    foregroundColor: const WidgetStatePropertyAll(AppColors.surface),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    ),
    textStyle: WidgetStatePropertyAll(AppTypography.button),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
    ),
  );

  static final _outlinedButtonStyle = ButtonStyle(
    foregroundColor: const WidgetStatePropertyAll(AppColors.textPrimary),
    backgroundColor: const WidgetStatePropertyAll(AppColors.surface),
    side: const WidgetStatePropertyAll(BorderSide(color: AppColors.border)),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    ),
    textStyle: WidgetStatePropertyAll(AppTypography.button),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
    ),
  );

  static final _inputDecoration = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
  );
}
