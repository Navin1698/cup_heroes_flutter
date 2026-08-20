import 'package:flutter/material.dart';
import '../core/constants/color_constants.dart';

enum StageType {
  normal,
  combat,
  puzzle,
  elite,
  treasure,
  boss,
}

class StageDefinition {
  final int stageNumber;
  final String name;
  final StageType type;
  final int totalWaves;
  final int targetKillCount;
  final int goldReward;
  final int gemReward;
  final int xpReward;
  final String description;
  final IconData icon;

  const StageDefinition({
    required this.stageNumber,
    required this.name,
    required this.type,
    required this.totalWaves,
    required this.targetKillCount,
    required this.goldReward,
    required this.gemReward,
    required this.xpReward,
    required this.description,
    required this.icon,
  });
}

class WorldDefinition {
  final int worldNumber;
  final String name;
  final String subtitle;
  final String description;
  final Color themeColor;
  final List<StageDefinition> stages;

  const WorldDefinition({
    required this.worldNumber,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.themeColor,
    required this.stages,
  });

  static WorldDefinition getWhisperingMeadow() {
    return const WorldDefinition(
      worldNumber: 1,
      name: 'Whispering Meadow',
      subtitle: 'The Sunlit Grasslands',
      description: 'Lush blooming meadows enchanted with glowing mana crystals and wild sprites.',
      themeColor: EmberColors.success,
      stages: [
        StageDefinition(
          stageNumber: 1,
          name: 'Sunlit Glade',
          type: StageType.normal,
          totalWaves: 3,
          targetKillCount: 15,
          goldReward: 150,
          gemReward: 10,
          xpReward: 60,
          description: 'Defeat wandering Mosslings and learn basic combat.',
          icon: Icons.grass,
        ),
        StageDefinition(
          stageNumber: 2,
          name: 'Crystal Outcrop',
          type: StageType.combat,
          totalWaves: 4,
          targetKillCount: 25,
          goldReward: 220,
          gemReward: 15,
          xpReward: 90,
          description: 'Survive fast-moving Crystal Bats and Archers.',
          icon: Icons.diamond,
        ),
        StageDefinition(
          stageNumber: 3,
          name: 'Ancient Rune Garden',
          type: StageType.puzzle,
          totalWaves: 3,
          targetKillCount: 20,
          goldReward: 300,
          gemReward: 20,
          xpReward: 120,
          description: 'Step on ancient pressure plates to unlock the secret path.',
          icon: Icons.extension,
        ),
        StageDefinition(
          stageNumber: 4,
          name: 'The Overgrowth Grove',
          type: StageType.elite,
          totalWaves: 4,
          targetKillCount: 30,
          goldReward: 450,
          gemReward: 30,
          xpReward: 180,
          description: 'Confront the armored Root Beast elite.',
          icon: Icons.shield,
        ),
        StageDefinition(
          stageNumber: 5,
          name: 'Heart of the Colossus',
          type: StageType.boss,
          totalWaves: 1,
          targetKillCount: 1,
          goldReward: 800,
          gemReward: 50,
          xpReward: 300,
          description: 'Defeat ROOT COLOSSUS to restore peace to the realm!',
          icon: Icons.warning_amber,
        ),
      ],
    );
  }
}
