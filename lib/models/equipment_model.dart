import 'package:flutter/material.dart';
import '../core/constants/game_constants.dart';

class EquipmentItem {
  final String id;
  final String name;
  final EquipmentSlot slot;
  final ItemRarity rarity;
  final int level;
  final int bonusHp;
  final int bonusAttack;
  final double bonusCritRate;
  final double bonusAttackSpeed;
  final IconData icon;
  final String specialEffect;

  const EquipmentItem({
    required this.id,
    required this.name,
    required this.slot,
    required this.rarity,
    this.level = 1,
    this.bonusHp = 0,
    this.bonusAttack = 0,
    this.bonusCritRate = 0.0,
    this.bonusAttackSpeed = 0.0,
    required this.icon,
    this.specialEffect = '',
  });

  // Calculate stats scaled by level and rarity
  int get effectiveHp => (bonusHp * (1.0 + (level - 1) * 0.12) * _rarityMultiplier).round();
  int get effectiveAttack => (bonusAttack * (1.0 + (level - 1) * 0.12) * _rarityMultiplier).round();

  double get _rarityMultiplier {
    switch (rarity) {
      case ItemRarity.common:
        return 1.0;
      case ItemRarity.uncommon:
        return 1.35;
      case ItemRarity.rare:
        return 1.8;
      case ItemRarity.epic:
        return 2.4;
      case ItemRarity.legendary:
        return 3.2;
      case ItemRarity.mythic:
        return 4.5;
    }
  }

  int get upgradeCostGold => level * 100 * (_rarityMultiplier).round();

  EquipmentItem copyWith({
    String? id,
    String? name,
    EquipmentSlot? slot,
    ItemRarity? rarity,
    int? level,
    int? bonusHp,
    int? bonusAttack,
    double? bonusCritRate,
    double? bonusAttackSpeed,
    IconData? icon,
    String? specialEffect,
  }) {
    return EquipmentItem(
      id: id ?? this.id,
      name: name ?? this.name,
      slot: slot ?? this.slot,
      rarity: rarity ?? this.rarity,
      level: level ?? this.level,
      bonusHp: bonusHp ?? this.bonusHp,
      bonusAttack: bonusAttack ?? this.bonusAttack,
      bonusCritRate: bonusCritRate ?? this.bonusCritRate,
      bonusAttackSpeed: bonusAttackSpeed ?? this.bonusAttackSpeed,
      icon: icon ?? this.icon,
      specialEffect: specialEffect ?? this.specialEffect,
    );
  }

  // Serialization for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slot': slot.index,
      'rarity': rarity.index,
      'level': level,
      'bonusHp': bonusHp,
      'bonusAttack': bonusAttack,
      'bonusCritRate': bonusCritRate,
      'bonusAttackSpeed': bonusAttackSpeed,
      'iconCodePoint': icon.codePoint,
      'specialEffect': specialEffect,
    };
  }

  factory EquipmentItem.fromJson(Map<String, dynamic> json) {
    return EquipmentItem(
      id: json['id'] as String,
      name: json['name'] as String,
      slot: EquipmentSlot.values[json['slot'] as int],
      rarity: ItemRarity.values[json['rarity'] as int],
      level: json['level'] as int? ?? 1,
      bonusHp: json['bonusHp'] as int? ?? 0,
      bonusAttack: json['bonusAttack'] as int? ?? 0,
      bonusCritRate: (json['bonusCritRate'] as num?)?.toDouble() ?? 0.0,
      bonusAttackSpeed: (json['bonusAttackSpeed'] as num?)?.toDouble() ?? 0.0,
      icon: IconData(json['iconCodePoint'] as int? ?? Icons.shield.codePoint, fontFamily: 'MaterialIcons'),
      specialEffect: json['specialEffect'] as String? ?? '',
    );
  }

  // Starter Starter Kit
  static List<EquipmentItem> getStarterGear() {
    return [
      const EquipmentItem(
        id: 'starter_sword',
        name: 'Iron Broadsword',
        slot: EquipmentSlot.weapon,
        rarity: ItemRarity.common,
        level: 1,
        bonusAttack: 25,
        icon: Icons.colorize,
        specialEffect: '+5% Slash Width',
      ),
      const EquipmentItem(
        id: 'starter_helmet',
        name: 'Soldier Cap',
        slot: EquipmentSlot.helmet,
        rarity: ItemRarity.common,
        level: 1,
        bonusHp: 60,
        icon: Icons.smart_toy,
        specialEffect: '+2% EXP Gain',
      ),
      const EquipmentItem(
        id: 'starter_armor',
        name: 'Leather Tunic',
        slot: EquipmentSlot.armor,
        rarity: ItemRarity.common,
        level: 1,
        bonusHp: 120,
        icon: Icons.shield,
        specialEffect: 'Damage Reduced by 3',
      ),
      const EquipmentItem(
        id: 'starter_boots',
        name: 'Runner Boots',
        slot: EquipmentSlot.boots,
        rarity: ItemRarity.common,
        level: 1,
        bonusHp: 40,
        bonusAttackSpeed: 0.08,
        icon: Icons.do_not_step,
        specialEffect: '+8% Cup Slide Speed',
      ),
      const EquipmentItem(
        id: 'starter_ring',
        name: 'Copper Ring',
        slot: EquipmentSlot.ring,
        rarity: ItemRarity.common,
        level: 1,
        bonusAttack: 12,
        bonusCritRate: 0.05,
        icon: Icons.album,
        specialEffect: '+5% Crit Chance',
      ),
      const EquipmentItem(
        id: 'starter_amulet',
        name: 'Lucky Charm',
        slot: EquipmentSlot.amulet,
        rarity: ItemRarity.common,
        level: 1,
        bonusHp: 50,
        bonusAttack: 10,
        icon: Icons.diamond,
        specialEffect: '+10% Ball Bounce',
      ),
    ];
  }
}
