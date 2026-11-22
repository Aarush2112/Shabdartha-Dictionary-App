import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Literary & Museum Gallery Typography System.
/// Inspired by art catalogues, illuminated folios, and classical publishing.
class AppTypography {
  static TextStyle editorialHeadline({
    double fontSize = 28,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.deepInk,
    double letterSpacing = -0.5,
    double height = 1.2,
  }) {
    try {
      return GoogleFonts.playfairDisplay(
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

  static TextStyle serifHeading({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.deepInk,
    double letterSpacing = -0.4,
    double height = 1.25,
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
        letterSpacing: -0.6,
        height: 1.1,
      );
    } catch (_) {
      return TextStyle(
        fontFamily: 'Georgia',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: -0.6,
        height: 1.1,
      );
    }
  }

  static TextStyle sansBody({
    double fontSize = 14.5,
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
    double fontSize = 11.5,
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
    double fontSize = 15,
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
