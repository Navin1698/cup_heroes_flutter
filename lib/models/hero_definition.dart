import 'package:flutter/material.dart';
import '../core/constants/color_constants.dart';

class HeroDefinition {
  final String id;
  final String name;
  final String title;
  final String description;
  final int baseHp;
  final int baseAttack;
  final int baseDefense;
  final double baseSpeed;
  final double baseCritChance;
  final double baseCritDamage;
  final String specialAbilityName;
  final String specialAbilityDesc;
  final String ultimateAbilityName;
  final String ultimateAbilityDesc;
  final String passiveAbilityName;
  final String passiveAbilityDesc;
  final int shardUnlockCost;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;

  const HeroDefinition({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.baseHp,
    required this.baseAttack,
    required this.baseDefense,
    required this.baseSpeed,
    required this.baseCritChance,
    required this.baseCritDamage,
    required this.specialAbilityName,
    required this.specialAbilityDesc,
    required this.ultimateAbilityName,
    required this.ultimateAbilityDesc,
    required this.passiveAbilityName,
    required this.passiveAbilityDesc,
    required this.shardUnlockCost,
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
  });

  static List<HeroDefinition> getAllHeroes() {
    return const [
      HeroDefinition(
        id: 'arin',
        name: 'ARIN',
        title: 'Crystal Guardian',
        description: 'A young guardian wielding a crystal blade with balanced melee combat and nova bursts.',
        baseHp: 600,
        baseAttack: 55,
        baseDefense: 25,
        baseSpeed: 220.0,
        baseCritChance: 0.08,
        baseCritDamage: 1.5,
        specialAbilityName: 'Crystal Nova',
        specialAbilityDesc: 'Expands a radial crystal energy burst that damages and pushes back surrounding enemies.',
        ultimateAbilityName: 'Celestial Burst',
        ultimateAbilityDesc: 'Summons a colossal beam of pure crystal light, devastating all enemies in front.',
        passiveAbilityName: 'Crystal Resonance',
        passiveAbilityDesc: 'Hitting enemies with basic attacks charges next skill damage by +15%.',
        shardUnlockCost: 0,
        primaryColor: EmberColors.secondary,
        secondaryColor: EmberColors.primary,
        icon: Icons.shield,
      ),
      HeroDefinition(
        id: 'luma',
        name: 'LUMA',
        title: 'Light Mage',
        description: 'Channels radiant magic from afar to heal allies and obliterate enemies with solar flares.',
        baseHp: 450,
        baseAttack: 70,
        baseDefense: 15,
        baseSpeed: 200.0,
        baseCritChance: 0.12,
        baseCritDamage: 1.6,
        specialAbilityName: 'Prismatic Orb',
        specialAbilityDesc: 'Launches a bouncing orb of pure light that damages enemies and restores 5% HP.',
        ultimateAbilityName: 'Solar Flare',
        ultimateAbilityDesc: 'Calls down a column of burning light from the heavens.',
        passiveAbilityName: 'Luminous Aura',
        passiveAbilityDesc: 'Defeating enemies restores 10 HP.',
        shardUnlockCost: 30,
        primaryColor: EmberColors.accent,
        secondaryColor: EmberColors.cream,
        icon: Icons.auto_awesome,
      ),
      HeroDefinition(
        id: 'kai',
        name: 'KAI',
        title: 'Storm Ranger',
        description: 'A swift scout armed with wind-infused arrows and lightning traps.',
        baseHp: 480,
        baseAttack: 65,
        baseDefense: 18,
        baseSpeed: 250.0,
        baseCritChance: 0.15,
        baseCritDamage: 1.75,
        specialAbilityName: 'Tempest Volley',
        specialAbilityDesc: 'Fires a fan of 5 piercing wind arrows.',
        ultimateAbilityName: 'Thunderstorm Arrow',
        ultimateAbilityDesc: 'Shoots a lightning bolt that electrifies the battlefield.',
        passiveAbilityName: 'Gale Velocity',
        passiveAbilityDesc: 'Movement speed increases by 10% after dashing.',
        shardUnlockCost: 50,
        primaryColor: EmberColors.success,
        secondaryColor: EmberColors.secondary,
        icon: Icons.adjust,
      ),
      HeroDefinition(
        id: 'brax',
        name: 'BRAX',
        title: 'Stone Warrior',
        description: 'A colossal frontline titan wielding a heavy granite maul.',
        baseHp: 850,
        baseAttack: 50,
        baseDefense: 45,
        baseSpeed: 180.0,
        baseCritChance: 0.05,
        baseCritDamage: 1.4,
        specialAbilityName: 'Earth Tremor',
        specialAbilityDesc: 'Slams the earth to stun all nearby enemies for 1.5 seconds.',
        ultimateAbilityName: 'Granite Colossus',
        ultimateAbilityDesc: 'Gains 50% damage reduction and creates shockwaves on every swing.',
        passiveAbilityName: 'Stone Fortress',
        passiveAbilityDesc: 'Reduces all incoming damage by 15%.',
        shardUnlockCost: 80,
        primaryColor: Color(0xFFE67E22),
        secondaryColor: Color(0xFFD35400),
        icon: Icons.hardware,
      ),
      HeroDefinition(
        id: 'nyx',
        name: 'NYX',
        title: 'Shadow Rogue',
        description: 'Strikes from the shadows with lethal dual daggers and phantom clones.',
        baseHp: 420,
        baseAttack: 80,
        baseDefense: 12,
        baseSpeed: 260.0,
        baseCritChance: 0.25,
        baseCritDamage: 2.0,
        specialAbilityName: 'Shadowstep',
        specialAbilityDesc: 'Teleports behind the nearest enemy and executes a critical backstab.',
        ultimateAbilityName: 'Blade Dance',
        ultimateAbilityDesc: 'Dashes through multiple enemies dealing massive shadow damage.',
        passiveAbilityName: 'Assassinate',
        passiveAbilityDesc: 'Attacks against enemies below 30% HP deal +50% critical damage.',
        shardUnlockCost: 120,
        primaryColor: EmberColors.epic,
        secondaryColor: EmberColors.danger,
        icon: Icons.flash_on,
      ),
    ];
  }
}
