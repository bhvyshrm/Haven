import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'haven_colors.dart';
import 'haven_typography.dart';

class HavenTheme {
  HavenTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: HavenColors.lightCanvas,
      canvasColor: HavenColors.lightCanvas,
      colorScheme: const ColorScheme.light(
        surface: HavenColors.lightSurface,
        onSurface: HavenColors.lightTextPrimary,
        primary: HavenColors.lightTextPrimary,
        onPrimary: HavenColors.lightCanvas,
        outline: HavenColors.lightBorder,
        outlineVariant: HavenColors.lightBorder,
        surfaceContainer: HavenColors.lightActiveSurface,
        error: HavenColors.error,
        onError: HavenColors.lightCanvas,
      ),
      dividerColor: HavenColors.lightBorder,
      dividerTheme: const DividerThemeData(
        color: HavenColors.lightBorder,
        thickness: 1.0,
        space: 1.0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: HavenColors.lightCanvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: HavenColors.lightTextPrimary),
        titleTextStyle: TextStyle(
          fontFamily: HavenTypography.fontFamily,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.56,
          color: HavenColors.lightTextPrimary,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: HavenTypography.display(HavenColors.lightTextPrimary),
        displayMedium: HavenTypography.displayMobile(
          HavenColors.lightTextPrimary,
        ),
        headlineLarge: HavenTypography.headlineLg(HavenColors.lightTextPrimary),
        headlineMedium: HavenTypography.headlineMd(
          HavenColors.lightTextPrimary,
        ),
        headlineSmall: HavenTypography.headlineSm(HavenColors.lightTextPrimary),
        bodyLarge: HavenTypography.bodyLg(HavenColors.lightTextPrimary),
        bodyMedium: HavenTypography.bodyMd(HavenColors.lightTextPrimary),
        bodySmall: HavenTypography.bodySm(HavenColors.lightTextSecondary),
        labelLarge: HavenTypography.labelMd(HavenColors.lightTextPrimary),
        labelMedium: HavenTypography.labelSm(HavenColors.lightTextSecondary),
        labelSmall: HavenTypography.caption(HavenColors.lightTextSecondary),
      ),
      cardTheme: CardThemeData(
        color: HavenColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(color: HavenColors.lightBorder, width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HavenColors.lightSurface,
        hintStyle: HavenTypography.bodyMd(HavenColors.lightTextSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(
            color: HavenColors.lightTextPrimary,
            width: 1.0,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 14.0,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: HavenColors.darkCanvas,
      canvasColor: HavenColors.darkCanvas,
      colorScheme: const ColorScheme.dark(
        surface: HavenColors.darkSurface,
        onSurface: HavenColors.darkTextPrimary,
        primary: HavenColors.darkTextPrimary,
        onPrimary: HavenColors.darkCanvas,
        outline: HavenColors.darkBorder,
        outlineVariant: HavenColors.darkBorder,
        surfaceContainer: HavenColors.darkActiveSurface,
        error: HavenColors.error,
        onError: HavenColors.darkCanvas,
      ),
      dividerColor: HavenColors.darkBorder,
      dividerTheme: const DividerThemeData(
        color: HavenColors.darkBorder,
        thickness: 1.0,
        space: 1.0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: HavenColors.darkCanvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: HavenColors.darkTextPrimary),
        titleTextStyle: TextStyle(
          fontFamily: HavenTypography.fontFamily,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.56,
          color: HavenColors.darkTextPrimary,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: HavenTypography.display(HavenColors.darkTextPrimary),
        displayMedium: HavenTypography.displayMobile(
          HavenColors.darkTextPrimary,
        ),
        headlineLarge: HavenTypography.headlineLg(HavenColors.darkTextPrimary),
        headlineMedium: HavenTypography.headlineMd(HavenColors.darkTextPrimary),
        headlineSmall: HavenTypography.headlineSm(HavenColors.darkTextPrimary),
        bodyLarge: HavenTypography.bodyLg(HavenColors.darkTextPrimary),
        bodyMedium: HavenTypography.bodyMd(HavenColors.darkTextPrimary),
        bodySmall: HavenTypography.bodySm(HavenColors.darkTextSecondary),
        labelLarge: HavenTypography.labelMd(HavenColors.darkTextPrimary),
        labelMedium: HavenTypography.labelSm(HavenColors.darkTextSecondary),
        labelSmall: HavenTypography.caption(HavenColors.darkTextSecondary),
      ),
      cardTheme: CardThemeData(
        color: HavenColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(color: HavenColors.darkBorder, width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HavenColors.darkSurface,
        hintStyle: HavenTypography.bodyMd(HavenColors.darkTextSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(
            color: HavenColors.darkTextPrimary,
            width: 1.0,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 14.0,
        ),
      ),
    );
  }
}
