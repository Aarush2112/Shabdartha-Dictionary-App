import 'package:flutter/material.dart';

/// Editorial & Museum Gallery Color System for Garuda Lexicon.
/// Inspired by classical fine-art catalogues, warm parchment,
/// deep obsidian accents, and muted terracotta.
abstract class AppColors {
  // Primary Backgrounds & Canvas
  static const Color parchment = Color(0xFFFBF9F4);
  static const Color alabaster = Color(0xFFF5F1E8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSand = Color(0xFFEFE8DC);
  static const Color surfaceElevated = Color(0xFFFFFDF9);

  // Gallery Obsidian (for floating navigation capsule & circular category nodes)
  static const Color obsidian = Color(0xFF161513);
  static const Color obsidianLight = Color(0xFF262421);
  static const Color obsidianCard = Color(0xFF1F1D1A);

  // Typography
  static const Color deepInk = Color(0xFF181614);
  static const Color inkLight = Color(0xFF38352F);
  static const Color warmGray = Color(0xFF6E685E);
  static const Color subtleGray = Color(0xFF9E978C);

  // Accent: Muted Terracotta
  static const Color terracotta = Color(0xFFB84A29);
  static const Color terracottaDark = Color(0xFF8E351A);
  static const Color terracottaLight = Color(0xFFD96543);
  static const Color terracottaSurface = Color(0xFFFBF2EE);
  static const Color terracottaBorder = Color(0xFFF0CEBE);

  // Accent: Antique Gold (Classical Museum Trim)
  static const Color antiqueGold = Color(0xFF9C7A28);
  static const Color antiqueGoldLight = Color(0xFFC4A252);
  static const Color antiqueGoldSurface = Color(0xFFFDF8EB);
  static const Color antiqueGoldBorder = Color(0xFFEBDCB6);

  // Accent: Sage Green (for verified Indic roots)
  static const Color sageGreen = Color(0xFF2E6347);
  static const Color sageGreenLight = Color(0xFF4C8A67);
  static const Color sageGreenSurface = Color(0xFFEDF5EF);
  static const Color sageGreenBorder = Color(0xFFC7E2CF);

  // Borders and Architectural Dividers
  static const Color border = Color(0xFFE5DDD0);
  static const Color borderSubtle = Color(0xFFEFE8DC);
  static const Color divider = Color(0xFFECE4D6);

  // Gradients for Curated Collection Folios
  static const LinearGradient folioTerracotta = LinearGradient(
    colors: [Color(0xFF2C1E18), Color(0xFF4A2B20)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient folioIndigo = LinearGradient(
    colors: [Color(0xFF1A222C), Color(0xFF2C394A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient folioEmerald = LinearGradient(
    colors: [Color(0xFF18261E), Color(0xFF253D30)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient folioBronze = LinearGradient(
    colors: [Color(0xFF2A2218), Color(0xFF423522)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
