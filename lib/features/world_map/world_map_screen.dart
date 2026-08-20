import 'package:flutter/material.dart';
import '../../core/constants/color_constants.dart';
import '../../core/theme/ember_theme.dart';
import '../../models/hero_definition.dart';
import '../../models/world_definition.dart';
import '../../repositories/save_repository.dart';
import '../battle/battle_screen.dart';

class WorldMapScreen extends StatefulWidget {
  final HeroDefinition selectedHero;

  const WorldMapScreen({super.key, required this.selectedHero});

  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen> {
  final WorldDefinition _world = WorldDefinition.getWhisperingMeadow();
  int _highestUnlockedStage = 1;
  Map<String, int> _stageStars = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final data = await SaveRepository.instance.loadSaveData();
    setState(() {
      _highestUnlockedStage = data['highestStage'] as int;
      _stageStars = data['stageStars'] as Map<String, int>;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EmberColors.background,
      appBar: AppBar(
        backgroundColor: EmberColors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _world.name.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white, letterSpacing: 1.2),
            ),
            Text(
              _world.subtitle,
              style: const TextStyle(fontSize: 11, color: EmberColors.success, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemCount: _world.stages.length,
          itemBuilder: (context, index) {
            final stage = _world.stages[index];
            final isUnlocked = stage.stageNumber <= _highestUnlockedStage;
            final isCurrent = stage.stageNumber == _highestUnlockedStage;
            final stars = _stageStars[stage.stageNumber.toString()] ?? 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: isUnlocked ? () => _startStage(stage) : null,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: EmberTheme.crystalCard(
                    color: isUnlocked ? EmberColors.surface : const Color(0xFF101328),
                    borderColor: isCurrent
                        ? EmberColors.secondary
                        : (isUnlocked ? EmberColors.surfaceBorder : const Color(0xFF1E2342)),
                    borderRadius: 20,
                    glow: isCurrent,
                    glowColor: EmberColors.secondary,
                  ),
                  child: Row(
                    children: [
                      // Node Icon
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isUnlocked ? EmberColors.primary.withValues(alpha: 0.25) : Colors.black26,
                          border: Border.all(
                            color: isUnlocked ? EmberColors.secondary : Colors.white24,
                            width: 2.0,
                          ),
                        ),
                        child: Icon(
                          isUnlocked ? stage.icon : Icons.lock,
                          color: isUnlocked ? (stage.type == StageType.boss ? EmberColors.danger : EmberColors.secondary) : Colors.white24,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Stage Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'STAGE ${stage.stageNumber}',
                                  style: TextStyle(
                                    color: isUnlocked ? EmberColors.secondary : Colors.white38,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (stage.type == StageType.boss)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: EmberColors.danger.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: EmberColors.danger),
                                    ),
                                    child: const Text(
                                      'BOSS',
                                      style: TextStyle(color: EmberColors.danger, fontSize: 9, fontWeight: FontWeight.w900),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              stage.name,
                              style: TextStyle(
                                color: isUnlocked ? Colors.white : Colors.white38,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stage.description,
                              style: TextStyle(
                                color: isUnlocked ? EmberColors.textSecondary : Colors.white24,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Stars / Play arrow
                      if (isUnlocked)
                        Column(
                          children: [
                            Row(
                              children: List.generate(3, (starIdx) {
                                return Icon(
                                  Icons.star,
                                  size: 16,
                                  color: starIdx < stars ? EmberColors.accent : Colors.white24,
                                );
                              }),
                            ),
                            const SizedBox(height: 6),
                            const Icon(Icons.arrow_forward_ios, color: EmberColors.secondary, size: 16),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _startStage(StageDefinition stage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BattleScreen(hero: widget.selectedHero, stage: stage),
      ),
    ).then((_) => _loadProgress());
  }
}
