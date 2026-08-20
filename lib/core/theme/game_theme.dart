import 'package:flutter/material.dart';
import '../constants/game_constants.dart';

class GameTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF16152B),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF5B36D6),
        secondary: Color(0xFFFFB300),
        surface: Color(0xFF221F40),
      ),
      fontFamily: 'Roboto',
    );
  }

  // 3D Embossed Container / Card
  static BoxDecoration card3D({
    Color color = const Color(0xFF24204A),
    Color borderColor = const Color(0xFF453F7A),
    Color shadowColor = const Color(0xFF120F2B),
    double borderRadius = 18.0,
    double borderWidth = 2.0,
    double elevation = 4.0,
    bool glow = false,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.9),
          offset: Offset(0, elevation),
          blurRadius: 0,
        ),
        if (glow)
          BoxShadow(
            color: borderColor.withValues(alpha: 0.5),
            blurRadius: 14,
            spreadRadius: 2,
          ),
      ],
    );
  }

  static BoxDecoration cardDecoration({
    Color? color,
    Color? borderColor,
    double borderWidth = 2.0,
    double borderRadius = 18.0,
    bool glow = false,
  }) {
    return card3D(
      color: color ?? const Color(0xFF24204A),
      borderColor: borderColor ?? const Color(0xFF453F7A),
      borderWidth: borderWidth,
      borderRadius: borderRadius,
      glow: glow,
    );
  }

  // 3D Action Button
  static BoxDecoration button3D({
    Color color = const Color(0xFF2ECC71),
    Color shadowColor = const Color(0xFF1E8449),
    Color borderColor = const Color(0xFF58D68D),
    double borderRadius = 18.0,
    double elevation = 5.0,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          borderColor,
          color,
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          offset: Offset(0, elevation),
          blurRadius: 0,
        ),
      ],
    );
  }

  // Currency Pill Decoration
  static BoxDecoration currencyPill() {
    return BoxDecoration(
      color: const Color(0xFF120F2B),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFF3B366B), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          offset: const Offset(0, 2),
          blurRadius: 0,
        ),
      ],
    );
  }

  // Rarity Colors
  static Color getRarityColor(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.common:
        return const Color(0xFF9E9E9E);
      case ItemRarity.uncommon:
        return const Color(0xFF2ECC71);
      case ItemRarity.rare:
        return const Color(0xFF3498DB);
      case ItemRarity.epic:
        return const Color(0xFF9B59B6);
      case ItemRarity.legendary:
        return const Color(0xFFF39C12);
      case ItemRarity.mythic:
        return const Color(0xFFE74C3C);
    }
  }

  static String getRarityName(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.common:
        return 'Common';
      case ItemRarity.uncommon:
        return 'Uncommon';
      case ItemRarity.rare:
        return 'Rare';
      case ItemRarity.epic:
        return 'Epic';
      case ItemRarity.legendary:
        return 'Legendary';
      case ItemRarity.mythic:
        return 'Mythic';
    }
  }
}
