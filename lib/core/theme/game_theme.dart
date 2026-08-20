import 'package:flutter/material.dart';
import '../constants/game_constants.dart';

class GameTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: GameConstants.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: GameConstants.primaryPurple,
        secondary: GameConstants.goldColor,
        surface: GameConstants.arenaBg,
      ),
      fontFamily: 'Roboto',
    );
  }

  // Common UI Card Decoration
  static BoxDecoration cardDecoration({
    Color? color,
    Color? borderColor,
    double borderWidth = 2.0,
    double borderRadius = 14.0,
    bool glow = false,
  }) {
    final baseColor = color ?? const Color(0xFF221F40);
    final border = borderColor ?? const Color(0xFF3F3B6C);
    
    return BoxDecoration(
      color: baseColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: border, width: borderWidth),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          offset: const Offset(0, 4),
          blurRadius: 6,
        ),
        if (glow)
          BoxShadow(
            color: (borderColor ?? GameConstants.primaryPurple).withOpacity(0.5),
            blurRadius: 12,
            spreadRadius: 1,
          ),
      ],
    );
  }

  // Game Button Style
  static BoxDecoration buttonDecoration({
    Color color = const Color(0xFF6C3CE9),
    Color shadowColor = const Color(0xFF4823B5),
    double borderRadius = 14.0,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          offset: const Offset(0, 4),
          blurRadius: 0,
        ),
      ],
    );
  }

  // Rarity Color Helper
  static Color getRarityColor(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.common:
        return GameConstants.rarityCommon;
      case ItemRarity.uncommon:
        return GameConstants.rarityUncommon;
      case ItemRarity.rare:
        return GameConstants.rarityRare;
      case ItemRarity.epic:
        return GameConstants.rarityEpic;
      case ItemRarity.legendary:
        return GameConstants.rarityLegendary;
      case ItemRarity.mythic:
        return GameConstants.rarityMythic;
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
