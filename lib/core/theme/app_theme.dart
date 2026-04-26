import 'package:flutter/material.dart';

class AppTheme {
  static const Color _lightBackground = Color(0xFFFAFAF7);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightSurfaceAlt = Color(0xFFF2F1EB);
  static const Color _darkBackground = Color(0xFF151515);
  static const Color _darkSurface = Color(0xFF151515);
  static const Color _darkSurfaceAlt = Color(0xFF1D1D1D);
  static const Color _lightPrimary = Color(0xFF151515);
  static const Color _darkPrimary = Color(0xFFF4F4F4);

  static ThemeData lightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _lightPrimary,
      brightness: Brightness.light,
      primary: _lightPrimary,
      secondary: _lightPrimary,
      surface: _lightSurface,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      scaffoldBackground: _lightBackground,
      cardColor: _lightSurface,
      dividerColor: const Color(0xFFE2E1DA),
      shadowColor: const Color(0x14101010),
      inputFillColor: _lightSurfaceAlt,
      tintColor: _lightSurfaceAlt,
    );
  }

  static ThemeData darkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _darkPrimary,
      brightness: Brightness.dark,
      primary: _darkPrimary,
      secondary: _darkPrimary,
      surface: _darkSurface,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      scaffoldBackground: _darkBackground,
      cardColor: _darkSurface,
      dividerColor: const Color(0xFF2A2A2A),
      shadowColor: const Color(0x66000000),
      inputFillColor: _darkSurfaceAlt,
      tintColor: _darkSurfaceAlt,
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Color scaffoldBackground,
    required Color cardColor,
    required Color dividerColor,
    required Color shadowColor,
    required Color inputFillColor,
    required Color tintColor,
  }) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      cardColor: cardColor,
      shadowColor: shadowColor,
      dividerColor: dividerColor,
      fontFamily: 'catfont',
    );

    final textTheme = ThemeData(brightness: colorScheme.brightness).textTheme.copyWith(
          displayLarge: TextStyle(
            fontFamily: 'myfont',
            fontSize: 42,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
            height: 1.05,
          ),
          displayMedium: TextStyle(
            fontFamily: 'myfont',
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
            height: 1.1,
          ),
          headlineLarge: TextStyle(
            fontFamily: 'myfont',
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
          headlineSmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
          titleMedium: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
          bodyLarge: TextStyle(
            fontSize: 15,
            color: colorScheme.onSurface.withValues(alpha: 0.92),
            height: 1.55,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.72),
            height: 1.5,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurface.withValues(alpha: 0.62),
            height: 1.35,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: colorScheme.onPrimary,
          ),
        );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFillColor,
        hintStyle: textTheme.bodyMedium,
        labelStyle: textTheme.bodyMedium,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: colorScheme.error),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: dividerColor.withValues(alpha: 0.72)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          textStyle: textTheme.titleMedium,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: dividerColor),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: tintColor,
        selectedColor: isDark ? const Color(0xFF262626) : const Color(0xFFF1F1EC),
        side: BorderSide(color: dividerColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        labelStyle: textTheme.bodyMedium,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        modalBackgroundColor: cardColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
      splashColor: colorScheme.primary.withValues(alpha: isDark ? 0.14 : 0.08),
      highlightColor: colorScheme.primary.withValues(alpha: isDark ? 0.08 : 0.05),
    );
  }
}
