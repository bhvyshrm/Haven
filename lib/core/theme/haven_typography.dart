import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HavenTypography {
  HavenTypography._();

  /// Platform-aware typography:
  /// Uses native Apple San Francisco font on iOS / macOS, and Inter fallback on Android / Web.
  static String? get fontFamily {
    if (kIsWeb) return 'Inter';
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return null; // System font (San Francisco)
    }
    return 'Inter';
  }

  static TextStyle display(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 34.0,
    fontWeight: FontWeight.w600,
    height: 42.0 / 34.0,
    letterSpacing: -0.8,
    color: color,
  );

  static TextStyle displayMobile(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 30.0,
    fontWeight: FontWeight.w600,
    height: 38.0 / 30.0,
    letterSpacing: -0.6,
    color: color,
  );

  static TextStyle headlineLg(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 28.0,
    fontWeight: FontWeight.w600,
    height: 34.0 / 28.0,
    letterSpacing: -0.5,
    color: color,
  );

  static TextStyle headlineMd(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 22.0,
    fontWeight: FontWeight.w600,
    height: 28.0 / 22.0,
    letterSpacing: -0.3,
    color: color,
  );

  static TextStyle headlineSm(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    height: 24.0 / 18.0,
    letterSpacing: -0.2,
    color: color,
  );

  static TextStyle bodyLg(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 17.0,
    fontWeight: FontWeight.w400,
    height: 26.0 / 17.0,
    letterSpacing: -0.1,
    color: color,
  );

  static TextStyle bodyMd(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 15.0,
    fontWeight: FontWeight.w400,
    height: 22.0 / 15.0,
    letterSpacing: -0.05,
    color: color,
  );

  static TextStyle bodySm(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    height: 19.0 / 13.5,
    color: color,
  );

  static TextStyle labelLg(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 22.0 / 16.0,
    letterSpacing: -0.1,
    color: color,
  );

  static TextStyle labelMd(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: 18.0 / 14.0,
    color: color,
  );

  static TextStyle labelSm(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.0,
    fontWeight: FontWeight.w500,
    height: 16.0 / 13.0,
    color: color,
  );

  static TextStyle caption(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    height: 15.0 / 11.5,
    letterSpacing: 0.2,
    color: color,
  );
}
