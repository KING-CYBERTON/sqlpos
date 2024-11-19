import 'package:flutter/material.dart';

class AppColorsnStylesConstants {
  // Color Palette - Light Mode
  static const Color primaryColorLight = Color(0xFF265A2A); // Deep Green
  static const Color secondaryColorLight = Color(0xFFFF6F59); // Coral Red
  static const Color tertiaryColorLight =
      Color(0xFFE0E8B7); // Soft Yellow-Green
  static const Color backgroundColorLight = Color(0xFFFFFFFF); // White
  static const Color textColorPrimaryLight =
      Color(0xFFFFFFFF); // White (For dark background)
  static const Color textColorSecondaryLight =
      Color(0xFF265A2A); // Deep Green (For light background)
  static const Color linkColorLight =
      Color(0xFFD4A5A5); // Soft Blush (For links in footer)
  static const Color searchBarBackgroundColorLight =
      Color(0xFFF2F2F2); // Light Grey

  // Color Palette - Dark Mode
  static const Color primaryColorDark = Color(0xFF1E1E1E); // Dark Grey/Black
  static const Color secondaryColorDark =
      Color(0xFFFF6F59); // Coral Red (Accent color remains the same)
  static const Color tertiaryColorDark =
      Color(0xFF8E9A6D); // Muted Sage (Adds depth)
  static const Color backgroundColorDark = Color(0xFF121212); // Dark Background
  static const Color textColorPrimaryDark =
      Color(0xFFFFFFFF); // White (For dark background)
  static const Color textColorSecondaryDark =
      Color(0xFFE0E0E0); // Light Grey (For text on dark backgrounds)
  static const Color linkColorDark =
      Color(0xFFFF6F59); // Coral Red (For links in footer)
  static const Color searchBarBackgroundColorDark =
      Color(0xFF333333); // Dark Grey

  // Font
  static const String primaryFont = 'Poppins'; // Chosen font

  // Text Styles - Light Mode
  static const TextStyle headerTextStyleLight = TextStyle(
    fontFamily: primaryFont,
    fontSize: 20.0,
    color: textColorPrimaryLight,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle footerLinkTextStyleLight = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16.0,
    color: linkColorLight,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodyTextStyleLight = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16.0,
    color: textColorSecondaryLight,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle buttonTextStyleLight = TextStyle(
    fontFamily: primaryFont,
    fontSize: 18.0,
    color: backgroundColorLight,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle searchBarTextStyleLight = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16.0,
    color: textColorSecondaryLight,
    fontWeight: FontWeight.normal,
  );

  // Text Styles - Dark Mode
  static const TextStyle headerTextStyleDark = TextStyle(
    fontFamily: primaryFont,
    fontSize: 20.0,
    color: textColorPrimaryDark,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle footerLinkTextStyleDark = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16.0,
    color: linkColorDark,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodyTextStyleDark = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16.0,
    color: textColorSecondaryDark,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle buttonTextStyleDark = TextStyle(
    fontFamily: primaryFont,
    fontSize: 18.0,
    color: backgroundColorDark,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle searchBarTextStyleDark = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16.0,
    color: textColorSecondaryDark,
    fontWeight: FontWeight.normal,
  );
}
