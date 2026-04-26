import 'package:flutter/material.dart';

class AppSurfacePalette {
  const AppSurfacePalette({
    required this.isDark,
    required this.scaffoldBackground,
    required this.screenGradient,
    required this.card,
    required this.cardAlt,
    required this.border,
    required this.borderStrong,
    required this.primaryText,
    required this.secondaryText,
    required this.tertiaryText,
    required this.accent,
    required this.accentText,
    required this.shadow,
  });

  factory AppSurfacePalette.of(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    return AppSurfacePalette(
      isDark: isDark,
      scaffoldBackground: theme.scaffoldBackgroundColor,
      screenGradient: isDark
          ? const <Color>[
              Color(0xFF060606),
              Color(0xFF0B0B0B),
              Color(0xFF17110B),
            ]
          : <Color>[
              colors.surface,
              colors.surfaceContainerLowest,
              const Color(0xFFF6EFDE),
            ],
      card: isDark ? const Color(0xFF151515) : colors.surface,
      cardAlt: isDark ? const Color(0xFF1D1D1D) : colors.surfaceContainerLow,
      border: isDark
          ? const Color(0xFF31281F)
          : colors.outlineVariant.withValues(alpha: 0.92),
      borderStrong: isDark
          ? const Color(0xFF4A3A2C)
          : colors.outlineVariant.withValues(alpha: 1),
      primaryText: colors.onSurface,
      secondaryText: colors.onSurface.withValues(alpha: 0.72),
      tertiaryText: colors.onSurface.withValues(alpha: 0.56),
      accent: const Color(0xFFD6B878),
      accentText: const Color(0xFF16120D),
      shadow: isDark
          ? Colors.black.withValues(alpha: 0.24)
          : Colors.black.withValues(alpha: 0.08),
    );
  }

  final bool isDark;
  final Color scaffoldBackground;
  final List<Color> screenGradient;
  final Color card;
  final Color cardAlt;
  final Color border;
  final Color borderStrong;
  final Color primaryText;
  final Color secondaryText;
  final Color tertiaryText;
  final Color accent;
  final Color accentText;
  final Color shadow;
}
