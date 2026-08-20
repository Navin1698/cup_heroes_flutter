import 'package:flutter/material.dart';
import '../core/constants/game_constants.dart';

enum PerkId {
  // Ball Perks
  extraBallSpawner,
  movingGates,
  gateBoostPlus,
  gateBoostMultiply,
  bouncyBalls,
  giantBalls,
  
  // Offensive Combat Perks
  multiShot,
  attackSpeedUp,
  damageBoost,
  critChanceUp,
  critDamageUp,
  piercingShots,
  ricochetShots,
  fireBurn,
  frostNova,
  chainLightning,
  meteorRain,
  
  // Defensive / Utility Perks
  energyShield,
  lifeSteal,
  hpRegen,
  maxHpUp,
  thornsDamage,
  cupWidthUp,
  superMeterFast,
  goldRush,
}

class SkillPerkModel {
  final PerkId id;
  final String title;
  final String description;
  final PerkCategory category;
  final ItemRarity tier;
  final IconData icon;
  final Color accentColor;
  final int maxStacks;

  const SkillPerkModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.tier,
    required this.icon,
    required this.accentColor,
    this.maxStacks = 3,
  });

  static List<SkillPerkModel> getAllPerks() {
    return const [
      // Ball & Gate Perks
      SkillPerkModel(
        id: PerkId.extraBallSpawner,
        title: '+3 Drops / Kill',
        description: 'Defeated enemies drop +3 additional energy balls into the board.',
        category: PerkCategory.balls,
        tier: ItemRarity.rare,
        icon: Icons.sports_volleyball,
        accentColor: Color(0xFF2ECC71),
      ),
      SkillPerkModel(
        id: PerkId.gateBoostMultiply,
        title: 'Golden Multipliers',
        description: 'Upgrades all multiplier gates by +1x (e.g. 2x becomes 3x).',
        category: PerkCategory.balls,
        tier: ItemRarity.epic,
        icon: Icons.close,
        accentColor: Color(0xFFFFA502),
      ),
      SkillPerkModel(
        id: PerkId.gateBoostPlus,
        title: 'Super Boost Gates',
        description: 'Increases all addition gates by +10 balls.',
        category: PerkCategory.balls,
        tier: ItemRarity.uncommon,
        icon: Icons.add,
        accentColor: Color(0xFF2ED573),
      ),
      SkillPerkModel(
        id: PerkId.cupWidthUp,
        title: 'Wide Cup Magnet',
        description: 'Expands your cup catch area by +30% width.',
        category: PerkCategory.balls,
        tier: ItemRarity.uncommon,
        icon: Icons.shopping_basket,
        accentColor: Color(0xFF1E90FF),
      ),
      SkillPerkModel(
        id: PerkId.bouncyBalls,
        title: 'Rubber Bouncers',
        description: 'Balls bounce with 40% more force off pegs, hitting more gates.',
        category: PerkCategory.balls,
        tier: ItemRarity.common,
        icon: Icons.blur_circular,
        accentColor: Color(0xFF9B59B6),
      ),

      // Combat Perks
      SkillPerkModel(
        id: PerkId.multiShot,
        title: 'Multi-Shot +1',
        description: 'Hero fires 1 additional projectile per attack.',
        category: PerkCategory.combat,
        tier: ItemRarity.epic,
        icon: Icons.call_split,
        accentColor: Color(0xFFFFA502),
      ),
      SkillPerkModel(
        id: PerkId.damageBoost,
        title: 'Attack Power +25%',
        description: 'Increases hero base attack damage by 25%.',
        category: PerkCategory.combat,
        tier: ItemRarity.common,
        icon: Icons.colorize,
        accentColor: Color(0xFFFF4757),
      ),
      SkillPerkModel(
        id: PerkId.attackSpeedUp,
        title: 'Frenzy Haste +30%',
        description: 'Increases hero attack speed by 30%.',
        category: PerkCategory.combat,
        tier: ItemRarity.uncommon,
        icon: Icons.speed,
        accentColor: Color(0xFF29D4FF),
      ),
      SkillPerkModel(
        id: PerkId.critChanceUp,
        title: 'Deadly Precision',
        description: '+20% Critical Hit Chance with +50% Crit Damage.',
        category: PerkCategory.combat,
        tier: ItemRarity.rare,
        icon: Icons.center_focus_strong,
        accentColor: Color(0xFFFF4757),
      ),
      SkillPerkModel(
        id: PerkId.chainLightning,
        title: 'Chain Lightning',
        description: 'Attacks have a 40% chance to shock up to 3 nearby enemies.',
        category: PerkCategory.combat,
        tier: ItemRarity.legendary,
        icon: Icons.bolt,
        accentColor: Color(0xFFF1C40F),
      ),
      SkillPerkModel(
        id: PerkId.fireBurn,
        title: 'Ignite Fire',
        description: 'Hero attacks ignite enemies for 30% burning damage over 3s.',
        category: PerkCategory.combat,
        tier: ItemRarity.rare,
        icon: Icons.local_fire_department,
        accentColor: Color(0xFFE67E22),
      ),
      SkillPerkModel(
        id: PerkId.frostNova,
        title: 'Frost Chill',
        description: 'Attacks slow enemy movement by 40% and chill them.',
        category: PerkCategory.combat,
        tier: ItemRarity.rare,
        icon: Icons.ac_unit,
        accentColor: Color(0xFF00CEC9),
      ),
      SkillPerkModel(
        id: PerkId.piercingShots,
        title: 'Piercing Projectiles',
        description: 'Projectiles pass through the first enemy to hit the one behind.',
        category: PerkCategory.combat,
        tier: ItemRarity.rare,
        icon: Icons.double_arrow,
        accentColor: Color(0xFF9B59B6),
      ),

      // Defensive / Utility
      SkillPerkModel(
        id: PerkId.energyShield,
        title: 'Aegis Shield',
        description: 'Generates a barrier absorbing up to 20% of max HP in damage.',
        category: PerkCategory.defense,
        tier: ItemRarity.rare,
        icon: Icons.security,
        accentColor: Color(0xFF3498DB),
      ),
      SkillPerkModel(
        id: PerkId.lifeSteal,
        title: 'Vampiric Drain',
        description: 'Restores HP equal to 15% of all damage dealt.',
        category: PerkCategory.defense,
        tier: ItemRarity.epic,
        icon: Icons.favorite,
        accentColor: Color(0xFFFF4757),
      ),
      SkillPerkModel(
        id: PerkId.maxHpUp,
        title: 'Vitality Boost',
        description: 'Increases Max HP by +35% and immediately restores HP.',
        category: PerkCategory.defense,
        tier: ItemRarity.common,
        icon: Icons.add_circle,
        accentColor: Color(0xFF2ECC71),
      ),
      SkillPerkModel(
        id: PerkId.superMeterFast,
        title: 'Overcharge Battery',
        description: 'Balls caught in the cup fill the Super Meter 50% faster.',
        category: PerkCategory.utility,
        tier: ItemRarity.rare,
        icon: Icons.battery_charging_full,
        accentColor: Color(0xFFF1C40F),
      ),
      SkillPerkModel(
        id: PerkId.goldRush,
        title: 'Greed King',
        description: 'Enemies drop +50% more Gold coins upon death.',
        category: PerkCategory.utility,
        tier: ItemRarity.uncommon,
        icon: Icons.monetization_on,
        accentColor: Color(0xFFFFD029),
      ),
    ];
  }
}
