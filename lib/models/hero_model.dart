import 'package:flutter/material.dart';
import '../core/constants/game_constants.dart';

class HeroModel {
  final String id;
  final String name;
  final HeroClass heroClass;
  final String title;
  final String description;
  final int baseHp;
  final int baseAttack;
  final double attackSpeed; // Attacks per second
  final double attackRange; // Attack range in logical pixels
  final String primarySkillName;
  final String primarySkillDesc;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;
  final int unlockCostGems;
  final bool isDefaultUnlocked;

  const HeroModel({
    required this.id,
    required this.name,
    required this.heroClass,
    required this.title,
    required this.description,
    required this.baseHp,
    required this.baseAttack,
    required this.attackSpeed,
    required this.attackRange,
    required this.primarySkillName,
    required this.primarySkillDesc,
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
    this.unlockCostGems = 0,
    this.isDefaultUnlocked = false,
  });

  static List<HeroModel> getAllHeroes() {
    return const [
      HeroModel(
        id: 'hero_knight',
        name: 'Galahad',
        heroClass: HeroClass.knight,
        title: 'Brave Knight',
        description: 'Well-rounded melee warrior with high survivability and sweeping sword attacks.',
        baseHp: 500,
        baseAttack: 50,
        attackSpeed: 1.2,
        attackRange: 160.0,
        primarySkillName: 'Whirlwind Blade',
        primarySkillDesc: 'Strikes all surrounding enemies for 250% damage.',
        primaryColor: Color(0xFF3498DB),
        secondaryColor: Color(0xFF2980B9),
        icon: Icons.shield,
        isDefaultUnlocked: true,
      ),
      HeroModel(
        id: 'hero_archer',
        name: 'Sylvia',
        heroClass: HeroClass.archer,
        title: 'Wind Ranger',
        description: 'Rapid-firing sniper who pierces enemy lines from extreme distance.',
        baseHp: 380,
        baseAttack: 42,
        attackSpeed: 2.0,
        attackRange: 280.0,
        primarySkillName: 'Arrow Storm',
        primarySkillDesc: 'Fires a volley of 8 rapid piercing arrows at enemy lines.',
        primaryColor: Color(0xFF2ECC71),
        secondaryColor: Color(0xFF27AE60),
        icon: Icons.track_changes,
        unlockCostGems: 250,
      ),
      HeroModel(
        id: 'hero_mage',
        name: 'Ignis',
        heroClass: HeroClass.mage,
        title: 'Archmage',
        description: 'Master of explosive elemental spells and area-of-effect destruction.',
        baseHp: 320,
        baseAttack: 65,
        attackSpeed: 0.9,
        attackRange: 240.0,
        primarySkillName: 'Meteor Cataclysm',
        primarySkillDesc: 'Calls down fiery meteors that incinerate multiple foes.',
        primaryColor: Color(0xFFE74C3C),
        secondaryColor: Color(0xFFC0392B),
        icon: Icons.auto_awesome,
        unlockCostGems: 500,
      ),
      HeroModel(
        id: 'hero_rogue',
        name: 'Kage',
        heroClass: HeroClass.rogue,
        title: 'Shadow Assassin',
        description: 'Deadly ninja with high critical chance and rapid double daggers.',
        baseHp: 350,
        baseAttack: 58,
        attackSpeed: 2.4,
        attackRange: 140.0,
        primarySkillName: 'Shadow Flurry',
        primarySkillDesc: 'Dashes through enemy ranks dealing 100% crit damage.',
        primaryColor: Color(0xFF9B59B6),
        secondaryColor: Color(0xFF8E44AD),
        icon: Icons.flash_on,
        unlockCostGems: 800,
      ),
      HeroModel(
        id: 'hero_paladin',
        name: 'Aurelia',
        heroClass: HeroClass.paladin,
        title: 'Holy Crusader',
        description: 'Impenetrable shield bearer who smites evil with holy light.',
        baseHp: 650,
        baseAttack: 45,
        attackSpeed: 1.0,
        attackRange: 150.0,
        primarySkillName: 'Divine Radiance',
        primarySkillDesc: 'Heals the hero for 30% HP and smites all active enemies.',
        primaryColor: Color(0xFFF1C40F),
        secondaryColor: Color(0xFFD4AC0D),
        icon: Icons.brightness_7,
        unlockCostGems: 1200,
      ),
    ];
  }
}
