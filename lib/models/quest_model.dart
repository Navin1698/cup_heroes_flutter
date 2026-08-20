import 'package:flutter/material.dart';

enum QuestType {
  killEnemies,
  catchBalls,
  completeWaves,
  upgradeGear,
  openChests,
  triggerSuper,
}

class QuestModel {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final int targetValue;
  final int goldReward;
  final int gemReward;
  final int passPoints;
  final IconData icon;

  const QuestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    required this.goldReward,
    required this.gemReward,
    required this.passPoints,
    required this.icon,
  });

  static List<QuestModel> getDailyQuests() {
    return const [
      QuestModel(
        id: 'quest_kill_30',
        title: 'Monster Slayer',
        description: 'Defeat 30 enemies in battles',
        type: QuestType.killEnemies,
        targetValue: 30,
        goldReward: 150,
        gemReward: 10,
        passPoints: 20,
        icon: Icons.colorize,
      ),
      QuestModel(
        id: 'quest_catch_100',
        title: 'Orb Master',
        description: 'Catch 100 energy balls in the Cup',
        type: QuestType.catchBalls,
        targetValue: 100,
        goldReward: 200,
        gemReward: 15,
        passPoints: 30,
        icon: Icons.sports_volleyball,
      ),
      QuestModel(
        id: 'quest_waves_5',
        title: 'Wave Survivor',
        description: 'Survive 5 battle waves',
        type: QuestType.completeWaves,
        targetValue: 5,
        goldReward: 250,
        gemReward: 20,
        passPoints: 40,
        icon: Icons.waves,
      ),
      QuestModel(
        id: 'quest_super_3',
        title: 'Super Charge',
        description: 'Unleash Hero Super Skill 3 times',
        type: QuestType.triggerSuper,
        targetValue: 3,
        goldReward: 180,
        gemReward: 15,
        passPoints: 25,
        icon: Icons.bolt,
      ),
    ];
  }
}

class CupPassTier {
  final int tierNumber;
  final int requiredPoints;
  final int goldReward;
  final int gemReward;
  final String? itemRewardName;

  const CupPassTier({
    required this.tierNumber,
    required this.requiredPoints,
    required this.goldReward,
    required this.gemReward,
    this.itemRewardName,
  });

  static List<CupPassTier> getTiers() {
    return const [
      CupPassTier(tierNumber: 1, requiredPoints: 20, goldReward: 200, gemReward: 10),
      CupPassTier(tierNumber: 2, requiredPoints: 50, goldReward: 400, gemReward: 20),
      CupPassTier(tierNumber: 3, requiredPoints: 90, goldReward: 600, gemReward: 30, itemRewardName: 'Rare Chest Key'),
      CupPassTier(tierNumber: 4, requiredPoints: 140, goldReward: 800, gemReward: 40),
      CupPassTier(tierNumber: 5, requiredPoints: 200, goldReward: 1500, gemReward: 100, itemRewardName: 'Epic Gear Voucher'),
    ];
  }
}
