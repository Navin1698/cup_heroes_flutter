import 'package:flutter/material.dart';
import '../core/constants/color_constants.dart';

enum EnemyType {
  melee,
  ranged,
  bomber,
  elite,
}

class EnemyDefinition {
  final String id;
  final String name;
  final EnemyType type;
  final int maxHp;
  final int attackDamage;
  final double moveSpeed;
  final double attackRange;
  final double attackCooldown;
  final int xpReward;
  final int coinReward;
  final Color primaryColor;
  final Color secondaryColor;
  final double radius;

  const EnemyDefinition({
    required this.id,
    required this.name,
    required this.type,
    required this.maxHp,
    required this.attackDamage,
    required this.moveSpeed,
    required this.attackRange,
    required this.attackCooldown,
    required this.xpReward,
    required this.coinReward,
    required this.primaryColor,
    required this.secondaryColor,
    this.radius = 18.0,
  });

  static List<EnemyDefinition> getWhisperingMeadowEnemies() {
    return const [
      EnemyDefinition(
        id: 'mossling',
        name: 'Mossling',
        type: EnemyType.melee,
        maxHp: 80,
        attackDamage: 12,
        moveSpeed: 95.0,
        attackRange: 32.0,
        attackCooldown: 1.2,
        xpReward: 10,
        coinReward: 5,
        primaryColor: EmberColors.success,
        secondaryColor: Color(0xFF2E7D32),
        radius: 16.0,
      ),
      EnemyDefinition(
        id: 'crystal_bat',
        name: 'Crystal Bat',
        type: EnemyType.melee,
        maxHp: 60,
        attackDamage: 15,
        moveSpeed: 140.0,
        attackRange: 28.0,
        attackCooldown: 0.9,
        xpReward: 12,
        coinReward: 6,
        primaryColor: EmberColors.secondary,
        secondaryColor: EmberColors.primary,
        radius: 14.0,
      ),
      EnemyDefinition(
        id: 'crystal_archer',
        name: 'Crystal Archer',
        type: EnemyType.ranged,
        maxHp: 90,
        attackDamage: 18,
        moveSpeed: 75.0,
        attackRange: 220.0,
        attackCooldown: 2.0,
        xpReward: 18,
        coinReward: 8,
        primaryColor: EmberColors.secondary,
        secondaryColor: EmberColors.accent,
        radius: 18.0,
      ),
      EnemyDefinition(
        id: 'bomb_beetle',
        name: 'Bomb Beetle',
        type: EnemyType.bomber,
        maxHp: 110,
        attackDamage: 45,
        moveSpeed: 110.0,
        attackRange: 45.0,
        attackCooldown: 1.5,
        xpReward: 20,
        coinReward: 10,
        primaryColor: EmberColors.danger,
        secondaryColor: Color(0xFFB71C1C),
        radius: 20.0,
      ),
      EnemyDefinition(
        id: 'root_beast',
        name: 'Root Beast',
        type: EnemyType.elite,
        maxHp: 320,
        attackDamage: 28,
        moveSpeed: 80.0,
        attackRange: 48.0,
        attackCooldown: 1.6,
        xpReward: 50,
        coinReward: 30,
        primaryColor: Color(0xFF8D6E63),
        secondaryColor: EmberColors.success,
        radius: 26.0,
      ),
    ];
  }
}
