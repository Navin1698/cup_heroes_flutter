import 'package:flutter/material.dart';
import '../constants/color_constants.dart';

class EmberTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: EmberColors.background,
      colorScheme: const ColorScheme.dark(
        primary: EmberColors.primary,
        secondary: EmberColors.secondary,
        surface: EmberColors.surface,
      ),
      fontFamily: 'Roboto',
    );
  }

  // Crystal Glow Box Decoration
  static BoxDecoration crystalCard({
    Color color = EmberColors.surface,
    Color borderColor = EmberColors.surfaceBorder,
    double borderRadius = 18.0,
    double borderWidth = 1.5,
    double elevation = 4.0,
    bool glow = false,
    Color glowColor = EmberColors.secondary,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
          offset: Offset(0, elevation),
          blurRadius: 10,
        ),
        if (glow)
          BoxShadow(
            color: glowColor.withValues(alpha: 0.35),
            blurRadius: 16,
            spreadRadius: 2,
          ),
      ],
    );
  }

  // Primary Gradient Button (Purple -> Blue)
  static BoxDecoration primaryButton({
    double borderRadius = 18.0,
    bool enabled = true,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: enabled
            ? [EmberColors.primary, EmberColors.secondary]
            : [const Color(0xFF3F4255), const Color(0xFF2A2C39)],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: enabled ? Colors.white.withValues(alpha: 0.3) : Colors.transparent,
        width: 1.5,
      ),
      boxShadow: [
        if (enabled)
          BoxShadow(
            color: EmberColors.primary.withValues(alpha: 0.4),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
      ],
    );
  }
}
