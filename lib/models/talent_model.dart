import 'package:flutter/material.dart';

enum TalentType {
  heroHp,
  heroAttack,
  critChance,
  cupSize,
  ballDropBonus,
  startingGold,
  superChargeRate,
  potionDrop,
}

class TalentNode {
  final TalentType type;
  final String title;
  final String description;
  final IconData icon;
  final int maxLevel;
  final int baseCost;
  final double costMultiplier;
  final double valuePerLevel;
  final bool isPercentage;

  const TalentNode({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    this.maxLevel = 20,
    required this.baseCost,
    this.costMultiplier = 1.3,
    required this.valuePerLevel,
    this.isPercentage = false,
  });

  int getCostForLevel(int currentLevel) {
    return (baseCost * (1.0 + currentLevel * costMultiplier * 0.8)).round();
  }

  static List<TalentNode> getAllTalents() {
    return const [
      TalentNode(
        type: TalentType.heroHp,
        title: 'Endurance Mastery',
        description: '+25 Maximum HP per level for all heroes.',
        icon: Icons.favorite,
        baseCost: 80,
        valuePerLevel: 25.0,
      ),
      TalentNode(
        type: TalentType.heroAttack,
        title: 'Warrior Might',
        description: '+5 Base Attack Damage per level.',
        icon: Icons.colorize,
        baseCost: 100,
        valuePerLevel: 5.0,
      ),
      TalentNode(
        type: TalentType.critChance,
        title: 'Precision Focus',
        description: '+1.5% Critical Hit Chance per level.',
        icon: Icons.center_focus_strong,
        baseCost: 150,
        valuePerLevel: 0.015,
        isPercentage: true,
      ),
      TalentNode(
        type: TalentType.cupSize,
        title: 'Expanded Goblet',
        description: '+2% Wider Cup catcher width per level.',
        icon: Icons.shopping_basket,
        baseCost: 120,
        valuePerLevel: 0.02,
        isPercentage: true,
      ),
      TalentNode(
        type: TalentType.ballDropBonus,
        title: 'Orb Harvest',
        description: '+3% Chance for double ball drops on kill.',
        icon: Icons.blur_circular,
        baseCost: 200,
        valuePerLevel: 0.03,
        isPercentage: true,
      ),
      TalentNode(
        type: TalentType.superChargeRate,
        title: 'Energy Resonance',
        description: '+4% Faster Super Meter energy gain.',
        icon: Icons.bolt,
        baseCost: 180,
        valuePerLevel: 0.04,
        isPercentage: true,
      ),
      TalentNode(
        type: TalentType.startingGold,
        title: 'Royal Treasury',
        description: '+100 Starting Gold at stage launch.',
        icon: Icons.monetization_on,
        baseCost: 140,
        valuePerLevel: 100.0,
      ),
    ];
  }
}
