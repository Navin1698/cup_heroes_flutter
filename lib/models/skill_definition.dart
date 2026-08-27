import 'package:flutter/material.dart';
import '../core/constants/color_constants.dart';

enum SkillTier {
  common,
  rare,
  epic,
  legendary,
}

class SkillDefinition {
  final String id;
  final String name;
  final String description;
  final SkillTier tier;
  final IconData icon;
  final Color accentColor;
  final int maxLevel;

  // Stat Modifiers per level
  final double attackBonusPct;
  final double attackSpeedPct;
  final double critChanceBonus;
  final double critDamageBonus;
  final double maxHpPct;
  final double moveSpeedPct;
  final double damageReductionPct;
  final bool hasLifeDrain;
  final bool hasChainStrike;
  final bool hasFireBurn;
  final bool hasFrostChill;
  final bool hasExplosiveHit;

  // Plinko / Board Modifiers per level
  final double gateWidthBonusPct;
  final int gateValueBonus;
  final double goldenBallChance;
  final bool hasPlinkoBarrage;

  const SkillDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.tier,
    required this.icon,
    required this.accentColor,
    this.maxLevel = 3,
    this.attackBonusPct = 0.0,
    this.attackSpeedPct = 0.0,
    this.critChanceBonus = 0.0,
    this.critDamageBonus = 0.0,
    this.maxHpPct = 0.0,
    this.moveSpeedPct = 0.0,
    this.damageReductionPct = 0.0,
    this.hasLifeDrain = false,
    this.hasChainStrike = false,
    this.hasFireBurn = false,
    this.hasFrostChill = false,
    this.hasExplosiveHit = false,
    this.gateWidthBonusPct = 0.0,
    this.gateValueBonus = 0,
    this.goldenBallChance = 0.0,
    this.hasPlinkoBarrage = false,
  });

  static List<SkillDefinition> getAllSkills() {
    return const [
      SkillDefinition(
        id: 'gate_expansion',
        name: 'Gate Expansion',
        description: 'Increases the width of all Multiplier Gates by +35%.',
        tier: SkillTier.rare,
        icon: Icons.open_in_full,
        accentColor: EmberColors.secondary,
        gateWidthBonusPct: 0.35,
      ),
      SkillDefinition(
        id: 'super_multiplier',
        name: 'Super Multiplier',
        description: 'All Multiplier gates give +1 extra value bonus.',
        tier: SkillTier.epic,
        icon: Icons.add_circle,
        accentColor: EmberColors.accent,
        gateValueBonus: 1,
      ),
      SkillDefinition(
        id: 'golden_comet',
        name: 'Golden Comet Balls',
        description: '30% chance for dropped balls to be Golden (2.5x Hero Damage).',
        tier: SkillTier.rare,
        icon: Icons.stars,
        accentColor: EmberColors.accent,
        goldenBallChance: 0.30,
      ),
      SkillDefinition(
        id: 'plinko_barrage',
        name: 'Plinko Barrage',
        description: 'Every 5 balls collected automatically drops a free bonus ball.',
        tier: SkillTier.epic,
        icon: Icons.bubble_chart,
        accentColor: EmberColors.success,
        hasPlinkoBarrage: true,
      ),
      SkillDefinition(
        id: 'crystal_power',
        name: 'Crystal Power',
        description: 'Increases all attack damage by +20%.',
        tier: SkillTier.common,
        icon: Icons.flash_on,
        accentColor: EmberColors.secondary,
        attackBonusPct: 0.20,
      ),
      SkillDefinition(
        id: 'rapid_strike',
        name: 'Rapid Strike',
        description: 'Increases attack speed by +15%.',
        tier: SkillTier.common,
        icon: Icons.speed,
        accentColor: EmberColors.success,
        attackSpeedPct: 0.15,
      ),
      SkillDefinition(
        id: 'sharp_edge',
        name: 'Sharp Edge',
        description: 'Increases Critical Strike chance by +8%.',
        tier: SkillTier.common,
        icon: Icons.content_cut,
        accentColor: EmberColors.accent,
        critChanceBonus: 0.08,
      ),
      SkillDefinition(
        id: 'energy_surge',
        name: 'Energy Surge',
        description: 'Increases Movement Speed by +12%.',
        tier: SkillTier.common,
        icon: Icons.directions_run,
        accentColor: EmberColors.secondary,
        moveSpeedPct: 0.12,
      ),
      SkillDefinition(
        id: 'frozen_blade',
        name: 'Frozen Blade',
        description: 'Attacks inflict Frost Chill, slowing enemies by 30%.',
        tier: SkillTier.rare,
        icon: Icons.ac_unit,
        accentColor: EmberColors.secondary,
        hasFrostChill: true,
      ),
      SkillDefinition(
        id: 'burning_crystal',
        name: 'Burning Crystal',
        description: 'Attacks ignite enemies for Fire Burn damage over time.',
        tier: SkillTier.rare,
        icon: Icons.local_fire_department,
        accentColor: EmberColors.danger,
        hasFireBurn: true,
      ),
      SkillDefinition(
        id: 'chain_strike',
        name: 'Chain Strike',
        description: 'Attacks bounce lightning arcs to 2 nearby enemies.',
        tier: SkillTier.epic,
        icon: Icons.electric_bolt,
        accentColor: EmberColors.accent,
        hasChainStrike: true,
      ),
      SkillDefinition(
        id: 'heavy_impact',
        name: 'Heavy Impact',
        description: 'Critical hits deal +50% extra critical damage.',
        tier: SkillTier.rare,
        icon: Icons.gavel,
        accentColor: EmberColors.primary,
        critDamageBonus: 0.50,
      ),
      SkillDefinition(
        id: 'vitality_crystal',
        name: 'Vitality Crystal',
        description: 'Increases maximum HP by +25% and restores current HP.',
        tier: SkillTier.common,
        icon: Icons.favorite,
        accentColor: EmberColors.success,
        maxHpPct: 0.25,
      ),
      SkillDefinition(
        id: 'life_drain',
        name: 'Life Drain',
        description: 'Heals 5% of maximum HP on defeating an enemy.',
        tier: SkillTier.epic,
        icon: Icons.water_drop,
        accentColor: EmberColors.danger,
        hasLifeDrain: true,
      ),
      SkillDefinition(
        id: 'explosive_hit',
        name: 'Explosive Hit',
        description: 'Attacks have a 25% chance to create a crystal explosion.',
        tier: SkillTier.epic,
        icon: Icons.bubble_chart,
        accentColor: EmberColors.accent,
        hasExplosiveHit: true,
      ),
      SkillDefinition(
        id: 'crystal_shield',
        name: 'Crystal Shield',
        description: 'Reduces all incoming damage by 15%.',
        tier: SkillTier.rare,
        icon: Icons.shield,
        accentColor: EmberColors.secondary,
        damageReductionPct: 0.15,
      ),
      SkillDefinition(
        id: 'boss_slayer',
        name: 'Boss Slayer',
        description: 'Deals +35% increased damage against Elite enemies and Bosses.',
        tier: SkillTier.legendary,
        icon: Icons.military_tech,
        accentColor: EmberColors.accent,
        attackBonusPct: 0.35,
      ),
    ];
  }
}
