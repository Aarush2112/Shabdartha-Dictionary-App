import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Literary & Editorial Typography system for Garuda Lexicon.
/// Uses a classic literary serif for hero words and editorial titles,
/// with an elegant sans-serif for functional reading, navigation, and controls.
class AppTypography {
  // Serif family for words, titles, and literary excerpts
  static TextStyle serifHeading({
    double fontSize = 28,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.deepInk,
    double letterSpacing = -0.5,
    double height = 1.2,
  }) {
    try {
      return GoogleFonts.cormorantGaramond(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
    } catch (_) {
      return TextStyle(
        fontFamily: 'Georgia',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
    }
  }

  static TextStyle heroWord({
    double fontSize = 38,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.deepInk,
  }) {
    try {
      return GoogleFonts.cormorantGaramond(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: -0.5,
        height: 1.1,
      );
    } catch (_) {
      return TextStyle(
        fontFamily: 'Georgia',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: -0.5,
        height: 1.1,
      );
    }
  }

  // Sans-serif family for body text, metadata, labels, and buttons
  static TextStyle sansBody({
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.deepInk,
    double height = 1.5,
    double letterSpacing = 0.1,
  }) {
    try {
      return GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
    } catch (_) {
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
    }
  }

  static TextStyle sansLabel({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.warmGray,
    double letterSpacing = 0.5,
  }) {
    try {
      return GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );
    } catch (_) {
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );
    }
  }

  static TextStyle phonetic({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.warmGray,
  }) {
    try {
      return GoogleFonts.firaCode(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
    } catch (_) {
      return TextStyle(
        fontFamily: 'monospace',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
    }
  }
}
