import 'package:flutter/material.dart';

/// Cohesive editorial color system for Garuda Lexicon.
/// Rooted in warm parchment, deep ink typography, and muted terracotta accents.
abstract class AppColors {
  // Primary Backgrounds & Surfaces
  static const Color parchment = Color(0xFFFAF7F2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSand = Color(0xFFF3ECE2);
  static const Color surfaceElevated = Color(0xFFFFFDF9);

  // Typography
  static const Color deepInk = Color(0xFF1A1815);
  static const Color inkLight = Color(0xFF38352F);
  static const Color warmGray = Color(0xFF6B665D);
  static const Color subtleGray = Color(0xFF9E988E);

  // Accent: Muted Terracotta
  static const Color terracotta = Color(0xFFB84A29);
  static const Color terracottaDark = Color(0xFF8E351A);
  static const Color terracottaLight = Color(0xFFD96543);
  static const Color terracottaSurface = Color(0xFFFDF3EF);
  static const Color terracottaBorder = Color(0xFFF0CEBE);

  // Accent: Sage Green (for positive/verified states)
  static const Color sageGreen = Color(0xFF2E6347);
  static const Color sageGreenLight = Color(0xFF4C8A67);
  static const Color sageGreenSurface = Color(0xFFEDF5EF);
  static const Color sageGreenBorder = Color(0xFFC7E2CF);

  // Subtle Borders and Dividers
  static const Color border = Color(0xFFE8E1D5);
  static const Color borderSubtle = Color(0xFFF0EBE0);
  static const Color divider = Color(0xFFECE5D9);

  // Status & Tags
  static const Color amberHighlight = Color(0xFF8A6517);
  static const Color amberSurface = Color(0xFFFDF8E8);

  // Dark Scholar Mode Palette
  static const Color darkParchment = Color(0xFF131210);
  static const Color darkSurface = Color(0xFF1C1A17);
  static const Color darkSurfaceSand = Color(0xFF26231E);
  static const Color darkDeepInk = Color(0xFFF4EFE6);
  static const Color darkWarmGray = Color(0xFFA6A094);
  static const Color darkBorder = Color(0xFF2F2A23);
  static const Color darkTerracotta = Color(0xFFDC6F4F);
}
