import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // =========================
  // HEADINGS
  // =========================

  static TextStyle displayLarge = GoogleFonts.playfairDisplay(
    fontSize: 48,
    height: 1.17,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
  );

  static TextStyle headlineLarge = GoogleFonts.playfairDisplay(
    fontSize: 32,
    height: 1.19,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
  );

  static TextStyle headlineMedium = GoogleFonts.playfairDisplay(
    fontSize: 24,
    height: 1.25,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
  );

  static TextStyle headlineSmall = GoogleFonts.playfairDisplay(
    fontSize: 18,
    height: 1.33,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
  );

  // =========================
  // BODY TEXT
  // =========================

  static TextStyle bodyLarge = GoogleFonts.sourceSans3(
    fontSize: 16,
    height: 1.5,
    color: AppColors.onSurface,
  );

  static TextStyle bodyMedium = GoogleFonts.sourceSans3(
    fontSize: 14,
    height: 1.57,
    color: AppColors.onSurface,
  );

  static TextStyle bodySmall = GoogleFonts.sourceSans3(
    fontSize: 12,
    height: 1.5,
    color: AppColors.onSurfaceVariant,
  );

  // =========================
  // LABELS
  // =========================

  static TextStyle labelLarge = GoogleFonts.sourceSans3(
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    color: AppColors.onSurface,
  );

  static TextStyle labelMedium = GoogleFonts.sourceSans3(
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    color: AppColors.onSurface,
  );

  static TextStyle labelSmall = GoogleFonts.sourceSans3(
    fontSize: 10,
    height: 1.4,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    color: AppColors.onSurfaceVariant,
  );
}