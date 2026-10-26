import 'package:flutter/material.dart';

class HavenColors {
  HavenColors._();

  // Light Mode (Canvas & Surfaces)
  static const Color lightCanvas = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF6F6F6);
  static const Color lightSurfaceSubtle = Color(0xFFFBF9F9);
  static const Color lightActiveSurface = Color(0xFFEEEEEE);
  static const Color lightBorder = Color(0xFFE8E8E8);
  static const Color lightTextPrimary = Color(0xFF171717);
  static const Color lightTextSecondary = Color(0xFF707070);
  static const Color lightIcon = Color(0xFF242424);

  // Dark Mode (AMOLED Canvas & Surfaces)
  static const Color darkCanvas = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF111111);
  static const Color darkSurfaceSubtle = Color(0xFF141414);
  static const Color darkActiveSurface = Color(0xFF252525);
  static const Color darkBorder = Color(0xFF262626);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFA3A3A3);
  static const Color darkIcon = Color(0xFFF5F5F5);

  // Error / Alert
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);

  // Writing Background Palette
  static const List<WritingPaletteColor> writingPalette = [
    WritingPaletteColor(
      id: 'amoled_black',
      name: 'AMOLED Black',
      color: Color(0xFF000000),
      isDark: true,
      textColor: Color(0xFFFFFFFF),
      secondaryColor: Color(0xFFA3A3A3),
    ),
    WritingPaletteColor(
      id: 'pure_white',
      name: 'Pure White',
      color: Color(0xFFFFFFFF),
      isDark: false,
      textColor: Color(0xFF171717),
      secondaryColor: Color(0xFF707070),
    ),
    WritingPaletteColor(
      id: 'warm_cream',
      name: 'Warm Cream',
      color: Color(0xFFF7F4EB),
      isDark: false,
      textColor: Color(0xFF2C2825),
      secondaryColor: Color(0xFF756E65),
    ),
    WritingPaletteColor(
      id: 'soft_beige',
      name: 'Soft Beige',
      color: Color(0xFFF2ECE4),
      isDark: false,
      textColor: Color(0xFF2D2926),
      secondaryColor: Color(0xFF766F6A),
    ),
    WritingPaletteColor(
      id: 'muted_sage',
      name: 'Muted Sage',
      color: Color(0xFF232B25),
      isDark: true,
      textColor: Color(0xFFE6ECE7),
      secondaryColor: Color(0xFF8B978D),
    ),
    WritingPaletteColor(
      id: 'dusty_blue',
      name: 'Dusty Blue',
      color: Color(0xFF1C232B),
      isDark: true,
      textColor: Color(0xFFE3EAF2),
      secondaryColor: Color(0xFF8592A0),
    ),
    WritingPaletteColor(
      id: 'soft_blush',
      name: 'Soft Blush',
      color: Color(0xFF2A2123),
      isDark: true,
      textColor: Color(0xFFF2E6E8),
      secondaryColor: Color(0xFF998588),
    ),
    WritingPaletteColor(
      id: 'light_grey',
      name: 'Light Grey',
      color: Color(0xFFEFEFEF),
      isDark: false,
      textColor: Color(0xFF171717),
      secondaryColor: Color(0xFF666666),
    ),
  ];

  static WritingPaletteColor getColorById(
    String? id, {
    bool isAppDark = false,
  }) {
    if (id == null || id.isEmpty) {
      return isAppDark ? writingPalette[0] : writingPalette[1];
    }
    return writingPalette.firstWhere(
      (element) => element.id == id,
      orElse: () => isAppDark ? writingPalette[0] : writingPalette[1],
    );
  }
}

class WritingPaletteColor {
  final String id;
  final String name;
  final Color color;
  final bool isDark;
  final Color textColor;
  final Color secondaryColor;

  const WritingPaletteColor({
    required this.id,
    required this.name,
    required this.color,
    required this.isDark,
    required this.textColor,
    required this.secondaryColor,
  });
}
