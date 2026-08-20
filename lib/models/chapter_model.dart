import 'package:flutter/material.dart';
import 'enemy_model.dart';

class ChapterModel {
  final int id;
  final String title;
  final String subtitle;
  final String description;
  final int totalWaves;
  final Color themeColor;
  final IconData icon;
  final List<EnemyType> enemyPool;
  final EnemyType bossType;
  final int recommendedPower;
  final int goldCompletionReward;
  final int gemCompletionReward;

  const ChapterModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.totalWaves,
    required this.themeColor,
    required this.icon,
    required this.enemyPool,
    required this.bossType,
    required this.recommendedPower,
    required this.goldCompletionReward,
    required this.gemCompletionReward,
  });

  static List<ChapterModel> getAllChapters() {
    return const [
      ChapterModel(
        id: 1,
        title: 'Chapter 1: Whispering Woods',
        subtitle: 'The Goblin Incursion',
        description: 'Venture through the enchanted forest infested with mischievous goblins and bone marksmen.',
        totalWaves: 10,
        themeColor: Color(0xFF27AE60),
        icon: Icons.forest,
        enemyPool: [EnemyType.goblin, EnemyType.skeletonArcher],
        bossType: EnemyType.dragonBoss,
        recommendedPower: 100,
        goldCompletionReward: 500,
        gemCompletionReward: 50,
      ),
      ChapterModel(
        id: 2,
        title: 'Chapter 2: Molten Highlands',
        subtitle: 'Rise of the Orc Horde',
        description: 'Battle through volcanic valleys filled with heavily armored orcs and swift shadow imps.',
        totalWaves: 15,
        themeColor: Color(0xFFE67E22),
        icon: Icons.terrain,
        enemyPool: [EnemyType.goblin, EnemyType.orcBrute, EnemyType.speedDemon],
        bossType: EnemyType.golemBoss,
        recommendedPower: 300,
        goldCompletionReward: 1200,
        gemCompletionReward: 100,
      ),
      ChapterModel(
        id: 3,
        title: 'Chapter 3: Crypt of Despair',
        subtitle: 'The Necromancer\'s Domain',
        description: 'Face terrifying void sorcerers, skeleton snipers, and the mighty Demon Overlord.',
        totalWaves: 20,
        themeColor: Color(0xFF8E44AD),
        icon: Icons.castle,
        enemyPool: [EnemyType.skeletonArcher, EnemyType.orcBrute, EnemyType.darkMage, EnemyType.speedDemon],
        bossType: EnemyType.demonKingBoss,
        recommendedPower: 650,
        goldCompletionReward: 2500,
        gemCompletionReward: 200,
      ),
    ];
  }
}
