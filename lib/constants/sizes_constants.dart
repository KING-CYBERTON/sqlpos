import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class ResponsiveSizes {
  static double getPadding(BuildContext context) {
    if (ResponsiveBreakpoints.of(context).smallerThan(TABLET)) {
      return 4.0;
    } else if (ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)) {
      return 6.0;
    } else {
      return 8.0;
    }
  }

  static double getSizedBoxHeight(BuildContext context) {
    if (ResponsiveBreakpoints.of(context).smallerThan(TABLET)) {
      return 5.0;
    } else if (ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)) {
      return 8.0;
    } else {
      return 13.0;
    }
  }

  static double getFontSize(BuildContext context) {
    if (ResponsiveBreakpoints.of(context).smallerThan(TABLET)) {
      return 12.0;
    } else if (ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)) {
      return 13.0;
    } else {
      return 16.0;
    }
  }
}
