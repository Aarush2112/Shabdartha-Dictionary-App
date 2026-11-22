import 'package:flutter/material.dart';

/// Exact Museum & Exhibition Aesthetic Color System.
/// Matches high-art exhibition catalogues with crisp white canvases,
/// pure black circular category nodes, soft pill containers, and deep contrast.
abstract class AppColors {
  // Primary Surfaces
  static const Color parchment = Color(0xFFFFFFFF); // Clean exhibition white
  static const Color alabaster = Color(0xFFF9F9FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSand = Color(0xFFF2F2F5); // Exact search pill fill
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // Exhibition Black Elements (Capsule Dock & Circular Category Nodes)
  static const Color obsidian = Color(0xFF111111);
  static const Color pureBlack = Color(0xFF000000);
  static const Color obsidianLight = Color(0xFF222222);
  static const Color obsidianCard = Color(0xFF1A1A1A);

  // High-Contrast Editorial Typography
  static const Color deepInk = Color(0xFF111111);
  static const Color inkLight = Color(0xFF2C2C2E);
  static const Color warmGray = Color(0xFF8E8E93); // Exact subtitle grey from image
  static const Color subtleGray = Color(0xFFB0B0B6);

  // Subtle Borders and Architectural Dividers
  static const Color border = Color(0xFFEBEBF0);
  static const Color borderSubtle = Color(0xFFF2F2F5);
  static const Color divider = Color(0xFFEEEEF2);

  // Accent Colors
  static const Color terracotta = Color(0xFFB84A29);
  static const Color terracottaDark = Color(0xFF8E351A);
  static const Color terracottaLight = Color(0xFFD96543);
  static const Color terracottaSurface = Color(0xFFFDF4F0);
  static const Color terracottaBorder = Color(0xFFF3D2C4);

  // Antique Gold & Green (Museum Hallmarks & Verified Roots)
  static const Color antiqueGold = Color(0xFF9C7A28);
  static const Color antiqueGoldLight = Color(0xFFC4A252);
  static const Color sageGreen = Color(0xFF2E6347);
  static const Color sageGreenSurface = Color(0xFFEDF5EF);
  static const Color sageGreenBorder = Color(0xFFC7E2CF);

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
