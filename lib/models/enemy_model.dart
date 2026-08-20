import 'package:flutter/material.dart';

enum EnemyType {
  goblin,
  skeletonArcher,
  orcBrute,
  darkMage,
  speedDemon,
  dragonBoss,
  golemBoss,
  demonKingBoss,
}

class EnemyModel {
  final String id;
  final String name;
  final EnemyType type;
  final int maxHp;
  final int attackDamage;
  final double moveSpeed;
  final double attackRange;
  final double attackCooldown;
  final int ballDropCount; // Balls dropped upon defeat
  final int goldReward;
  final int expReward;
  final bool isBoss;
  final Color primaryColor;
  final Color secondaryColor;
  final double size;

  const EnemyModel({
    required this.id,
    required this.name,
    required this.type,
    required this.maxHp,
    required this.attackDamage,
    required this.moveSpeed,
    required this.attackRange,
    required this.attackCooldown,
    required this.ballDropCount,
    required this.goldReward,
    required this.expReward,
    required this.isBoss,
    required this.primaryColor,
    required this.secondaryColor,
    this.size = 28.0,
  });

  static EnemyModel createEnemy(EnemyType type, int waveNumber) {
    // Scaling multiplier per wave
    final scale = 1.0 + (waveNumber - 1) * 0.15;
    
    switch (type) {
      case EnemyType.goblin:
        return EnemyModel(
          id: 'goblin',
          name: 'Forest Goblin',
          type: type,
          maxHp: (60 * scale).round(),
          attackDamage: (12 * scale).round(),
          moveSpeed: 38.0,
          attackRange: 28.0,
          attackCooldown: 1.2,
          ballDropCount: 2,
          goldReward: 5 + waveNumber,
          expReward: 10 + waveNumber * 2,
          isBoss: false,
          primaryColor: const Color(0xFF27AE60),
          secondaryColor: const Color(0xFF1E8449),
          size: 26.0,
        );

      case EnemyType.skeletonArcher:
        return EnemyModel(
          id: 'skeleton_archer',
          name: 'Bone Marksman',
          type: type,
          maxHp: (45 * scale).round(),
          attackDamage: (16 * scale).round(),
          moveSpeed: 25.0,
          attackRange: 160.0,
          attackCooldown: 1.6,
          ballDropCount: 3,
          goldReward: 8 + waveNumber,
          expReward: 14 + waveNumber * 2,
          isBoss: false,
          primaryColor: const Color(0xFFBDC3C7),
          secondaryColor: const Color(0xFF7F8C8D),
          size: 24.0,
        );

      case EnemyType.orcBrute:
        return EnemyModel(
          id: 'orc_brute',
          name: 'Orc Warrior',
          type: type,
          maxHp: (140 * scale).round(),
          attackDamage: (24 * scale).round(),
          moveSpeed: 24.0,
          attackRange: 32.0,
          attackCooldown: 1.8,
          ballDropCount: 4,
          goldReward: 12 + waveNumber * 2,
          expReward: 20 + waveNumber * 3,
          isBoss: false,
          primaryColor: const Color(0xFFD35400),
          secondaryColor: const Color(0xFFA04000),
          size: 34.0,
        );

      case EnemyType.speedDemon:
        return EnemyModel(
          id: 'speed_demon',
          name: 'Shadow Imp',
          type: type,
          maxHp: (40 * scale).round(),
          attackDamage: (10 * scale).round(),
          moveSpeed: 60.0,
          attackRange: 24.0,
          attackCooldown: 0.8,
          ballDropCount: 2,
          goldReward: 10 + waveNumber,
          expReward: 16 + waveNumber * 2,
          isBoss: false,
          primaryColor: const Color(0xFF9B59B6),
          secondaryColor: const Color(0xFF6C3483),
          size: 22.0,
        );

      case EnemyType.darkMage:
        return EnemyModel(
          id: 'dark_mage',
          name: 'Void Sorcerer',
          type: type,
          maxHp: (80 * scale).round(),
          attackDamage: (28 * scale).round(),
          moveSpeed: 20.0,
          attackRange: 180.0,
          attackCooldown: 2.0,
          ballDropCount: 5,
          goldReward: 18 + waveNumber * 2,
          expReward: 30 + waveNumber * 3,
          isBoss: false,
          primaryColor: const Color(0xFF8E44AD),
          secondaryColor: const Color(0xFF2C3E50),
          size: 28.0,
        );

      case EnemyType.dragonBoss:
        return EnemyModel(
          id: 'dragon_boss',
          name: 'Infernal Wyrm (Boss)',
          type: type,
          maxHp: (700 * scale).round(),
          attackDamage: (50 * scale).round(),
          moveSpeed: 18.0,
          attackRange: 140.0,
          attackCooldown: 2.2,
          ballDropCount: 15,
          goldReward: 100 + waveNumber * 10,
          expReward: 200 + waveNumber * 20,
          isBoss: true,
          primaryColor: const Color(0xFFE74C3C),
          secondaryColor: const Color(0xFF922B21),
          size: 54.0,
        );

      case EnemyType.golemBoss:
        return EnemyModel(
          id: 'golem_boss',
          name: 'Titan Golem (Boss)',
          type: type,
          maxHp: (1100 * scale).round(),
          attackDamage: (60 * scale).round(),
          moveSpeed: 14.0,
          attackRange: 45.0,
          attackCooldown: 2.5,
          ballDropCount: 20,
          goldReward: 150 + waveNumber * 15,
          expReward: 300 + waveNumber * 25,
          isBoss: true,
          primaryColor: const Color(0xFF7F8C8D),
          secondaryColor: const Color(0xFF34495E),
          size: 58.0,
        );

      case EnemyType.demonKingBoss:
        return EnemyModel(
          id: 'demon_king_boss',
          name: 'Demon Overlord (Boss)',
          type: type,
          maxHp: (1600 * scale).round(),
          attackDamage: (80 * scale).round(),
          moveSpeed: 20.0,
          attackRange: 160.0,
          attackCooldown: 1.8,
          ballDropCount: 30,
          goldReward: 250 + waveNumber * 20,
          expReward: 500 + waveNumber * 35,
          isBoss: true,
          primaryColor: const Color(0xFFC0392B),
          secondaryColor: const Color(0xFF5B2C6F),
          size: 64.0,
        );
    }
  }
}
