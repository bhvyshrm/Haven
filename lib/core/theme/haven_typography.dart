import 'package:flutter/material.dart';

class HavenTypography {
  HavenTypography._();

  static const String fontFamily = 'Inter';

  static TextStyle display(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 40.0,
    fontWeight: FontWeight.w600,
    height: 48.0 / 40.0,
    letterSpacing: -1.2, // -0.03em
    color: color,
  );

  static TextStyle displayMobile(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 32.0,
    fontWeight: FontWeight.w600,
    height: 38.0 / 32.0,
    letterSpacing: -0.8, // -0.025em
    color: color,
  );

  static TextStyle headlineLg(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 28.0,
    fontWeight: FontWeight.w600,
    height: 36.0 / 28.0,
    letterSpacing: -0.56, // -0.02em
    color: color,
  );

  static TextStyle headlineMd(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 22.0,
    fontWeight: FontWeight.w500,
    height: 30.0 / 22.0,
    letterSpacing: -0.33, // -0.015em
    color: color,
  );

  static TextStyle headlineSm(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
    height: 26.0 / 18.0,
    letterSpacing: -0.18, // -0.01em
    color: color,
  );

  static TextStyle bodyLg(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 17.0,
    fontWeight: FontWeight.w400,
    height: 26.0 / 17.0,
    letterSpacing: -0.085, // -0.005em
    color: color,
  );

  static TextStyle bodyMd(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 15.0,
    fontWeight: FontWeight.w400,
    height: 23.0 / 15.0,
    letterSpacing: 0.0,
    color: color,
  );

  static TextStyle bodySm(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    height: 19.0 / 13.0,
    letterSpacing: 0.0,
    color: color,
  );

  static TextStyle labelMd(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: 18.0 / 14.0,
    letterSpacing: 0.14, // 0.01em
    color: color,
  );

  static TextStyle labelSm(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    height: 16.0 / 12.0,
    letterSpacing: 0.24, // 0.02em
    color: color,
  );

  static TextStyle caption(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w400,
    height: 14.0 / 11.0,
    letterSpacing: 0.33, // 0.03em
    color: color,
  );
}
