import 'package:flutter/material.dart';
import 'sizes_constants.dart';

class TextStyles {
  static const String _fontFamily =
      'Public Sans'; // Define the font family once

  // Title text style based on screen size
  static TextStyle getTitleStyle(BuildContext context) {
    return TextStyle(
        fontFamily: _fontFamily, // Use the defined font family
        fontSize:
           14, // Title larger by 4px
        fontWeight: FontWeight.bold,
        color: Colors.black,
        letterSpacing: 0);
  }

  // Subtitle text style based on screen size
  static TextStyle getSubtitleStyle(BuildContext context) {
    return TextStyle(
        fontFamily: _fontFamily, // Use the defined font family
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.black87,
        letterSpacing: 0);
  }

  // Body text style based on screen size
  static TextStyle getBodyTextStyle(BuildContext context) {
    return TextStyle(
        fontFamily: _fontFamily, // Use the defined font family
        fontSize:
          14, // Body smaller by 2px
        fontWeight: FontWeight.normal,
        color: Colors.black54,
        letterSpacing: 0);
  }

  // Custom text style for more actions or labels
  static TextStyle getMoreTextStyle(BuildContext context) {
    return TextStyle(
        fontFamily: _fontFamily, // Use the defined font family
        fontSize:
            14, // Smaller text for "more"
        fontWeight: FontWeight.w400,
        color: Colors.blueAccent,
        decoration: TextDecoration.underline,
        letterSpacing: 0);
  }
}
