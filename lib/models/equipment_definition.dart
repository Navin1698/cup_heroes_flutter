import 'package:flutter/material.dart';
import '../core/constants/color_constants.dart';

enum EquipmentSlot {
  weapon,
  helmet,
  armor,
  boots,
  ring,
  crystalCore,
}

enum EquipmentRarity {
  common,
  rare,
  epic,
  legendary,
  mythic,
}

class EquipmentDefinition {
  final String id;
  final String name;
  final EquipmentSlot slot;
  final EquipmentRarity rarity;
  int level;
  final int bonusAttack;
  final int bonusHp;
  final int bonusDefense;
  final double bonusCrit;
  final double bonusSpeed;
  final IconData icon;

  EquipmentDefinition({
    required this.id,
    required this.name,
    required this.slot,
    required this.rarity,
    this.level = 1,
    this.bonusAttack = 0,
    this.bonusHp = 0,
    this.bonusDefense = 0,
    this.bonusCrit = 0.0,
    this.bonusSpeed = 0.0,
    required this.icon,
  });

  int get currentAttack => bonusAttack + (level - 1) * 8;
  int get currentHp => bonusHp + (level - 1) * 45;
  int get currentDefense => bonusDefense + (level - 1) * 5;
  int get upgradeCostGold => level * 120;

  Color get rarityColor {
    switch (rarity) {
      case EquipmentRarity.common:
        return EmberColors.common;
      case EquipmentRarity.rare:
        return EmberColors.rare;
      case EquipmentRarity.epic:
        return EmberColors.epic;
      case EquipmentRarity.legendary:
        return EmberColors.legendary;
      case EquipmentRarity.mythic:
        return EmberColors.mythic;
    }
  }

  static List<EquipmentDefinition> getStarterEquipment() {
    return [
      EquipmentDefinition(
        id: 'crystal_blade_01',
        name: 'Crystal Blade',
        slot: EquipmentSlot.weapon,
        rarity: EquipmentRarity.rare,
        bonusAttack: 30,
        bonusCrit: 0.05,
        icon: Icons.colorize,
      ),
      EquipmentDefinition(
        id: 'guardian_helm_01',
        name: 'Guardian Helm',
        slot: EquipmentSlot.helmet,
        rarity: EquipmentRarity.common,
        bonusHp: 120,
        bonusDefense: 10,
        icon: Icons.smart_toy,
      ),
      EquipmentDefinition(
        id: 'crystal_plate_01',
        name: 'Crystal Plate',
        slot: EquipmentSlot.armor,
        rarity: EquipmentRarity.rare,
        bonusHp: 250,
        bonusDefense: 20,
        icon: Icons.shield,
      ),
      EquipmentDefinition(
        id: 'swift_boots_01',
        name: 'Swift Greaves',
        slot: EquipmentSlot.boots,
        rarity: EquipmentRarity.common,
        bonusSpeed: 25.0,
        bonusDefense: 8,
        icon: Icons.do_not_step,
      ),
      EquipmentDefinition(
        id: 'prismatic_ring_01',
        name: 'Prismatic Band',
        slot: EquipmentSlot.ring,
        rarity: EquipmentRarity.epic,
        bonusAttack: 25,
        bonusCrit: 0.08,
        icon: Icons.album,
      ),
      EquipmentDefinition(
        id: 'ember_core_01',
        name: 'Ember Heart Core',
        slot: EquipmentSlot.crystalCore,
        rarity: EquipmentRarity.rare,
        bonusHp: 180,
        bonusAttack: 20,
        icon: Icons.diamond,
      ),
    ];
  }
}
