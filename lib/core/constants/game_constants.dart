import 'package:flutter/material.dart';

class GameConstants {
  // Game Board Dimensions (Normalized logical units)
  static const double worldWidth = 400.0;
  static const double worldHeight = 700.0;
  
  // Arena Split
  static const double arenaHeight = 270.0; // Top Combat Arena
  static const double separatorHeight = 24.0;
  static const double pachinkoTop = arenaHeight + separatorHeight; // 294.0
  static const double pachinkoHeight = worldHeight - pachinkoTop; // 406.0
  
  // Physics Configuration
  static const double gravity = 480.0; // px/s^2
  static const double maxBallVelocity = 650.0;
  static const double ballRadius = 6.5;
  static const double pegRadius = 7.0;
  static const double ballRestitution = 0.72; // Bounciness
  static const double pegRestitution = 0.85;
  
  // Cup Settings
  static const double cupWidth = 76.0;
  static const double cupHeight = 36.0;
  static const double cupYOffsetFromBottom = 22.0;
  
  // Combat Constants
  static const double heroX = 70.0;
  static const double heroY = 180.0;
  static const double enemySpawnX = 380.0;
  static const double enemyTargetX = 90.0;
  
  // Visual & Colors
  static const Color primaryPurple = Color(0xFF6C3CE9);
  static const Color darkBg = Color(0xFF131127);
  static const Color arenaBg = Color(0xFF1E1B38);
  static const Color pachinkoBg = Color(0xFF141226);
  static const Color goldColor = Color(0xFFFFD029);
  static const Color gemColor = Color(0xFF29D4FF);
  static const Color energyColor = Color(0xFF38EF7D);
  static const Color hpGreen = Color(0xFF2ED573);
  static const Color hpRed = Color(0xFFFF4757);
  static const Color manaBlue = Color(0xFF3742FA);
  
  // Multiplier Colors
  static const Color gateAddColor = Color(0xFF2ED573);
  static const Color gateMultiplyColor = Color(0xFFFFA502);
  static const Color gateSuperColor = Color(0xFFFF4757);
  
  // Rarity Colors
  static const Color rarityCommon = Color(0xFF9E9E9E);
  static const Color rarityUncommon = Color(0xFF2ED573);
  static const Color rarityRare = Color(0xFF1E90FF);
  static const Color rarityEpic = Color(0xFF9B59B6);
  static const Color rarityLegendary = Color(0xFFFFA502);
  static const Color rarityMythic = Color(0xFFFF4757);
}

enum EquipmentSlot {
  weapon,
  helmet,
  armor,
  boots,
  ring,
  amulet,
}

enum ItemRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
  mythic,
}

enum HeroClass {
  knight,
  archer,
  mage,
  rogue,
  paladin,
}

enum DamageType {
  physical,
  fire,
  ice,
  lightning,
  poison,
}

enum PerkCategory {
  balls,
  combat,
  defense,
  utility,
}
