import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../core/constants/color_constants.dart';
import '../models/hero_definition.dart';
import '../models/skill_definition.dart';
import '../models/world_definition.dart';
import 'components/combat/hero_cannon_component.dart';
import 'components/combat/hero_projectile_component.dart';
import 'components/combat/wave_monster_component.dart';

enum BattlePhase { playing, skillSelection, victory, defeat, paused }

class UnifiedCupBattleGame extends FlameGame {
  final HeroDefinition heroDefinition;
  final StageDefinition stageDefinition;
  final Function(BattlePhase phase)? onPhaseChanged;
  final Function(List<SkillDefinition> options)? onSkillDraftRequested;
  final Function(int playerHp, int maxHp, int wave, int totalWaves, int xp, int xpTarget, int goldEarned)? onStatsUpdated;

  int maxPlayerHp = 100;
  int currentPlayerHp = 100;
  int currentWave = 1;
  final int totalWaves = 5;

  int currentXp = 0;
  int xpTarget = 60;
  int currentLevel = 1;
  int goldEarned = 0;

  BattlePhase phase = BattlePhase.playing;
  late HeroCannonComponent heroCannon;

  final List<WaveMonsterComponent> activeMonsters = [];
  final List<HeroProjectileComponent> activeProjectiles = [];
  final Random _rng = Random();

  double _waveSpawnTimer = 0.0;
  int _monstersRemainingInWave = 6;
  bool _isWaveSpawning = false;

  // Active Modifiers from roguelike skills
  final Map<String, int> activeSkills = {};
  double damageMultiplier = 1.0;
  double critChance = 0.1;
  double goldenBallRate = 0.0;
  double gateWidthBonus = 0.0;
  int gateValueBonus = 0;

  UnifiedCupBattleGame({
    required this.heroDefinition,
    required this.stageDefinition,
    this.onPhaseChanged,
    this.onSkillDraftRequested,
    this.onStatsUpdated,
  });

  @override
  Color backgroundColor() => const Color(0xFF0C1024);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    maxPlayerHp = heroDefinition.baseHp;
    currentPlayerHp = maxPlayerHp;

    // Center Hero Cannon at the bottom of the upper arena (Arena size ~ 400 wide x 430 high)
    heroCannon = HeroCannonComponent(
      hero: heroDefinition,
      position: Vector2(200, 370),
      onSpawnProjectile: (proj) {
        activeProjectiles.add(proj);
        world.add(proj);
      },
    );
    world.add(heroCannon);

    _startWave(currentWave);
  }

  void _startWave(int wave) {
    currentWave = wave;
    _monstersRemainingInWave = 4 + (wave * 2);
    _isWaveSpawning = true;
    _waveSpawnTimer = 0.5;
    _notifyStats();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (phase != BattlePhase.playing) return;

    // 1. Wave Spawner
    if (_isWaveSpawning) {
      _waveSpawnTimer -= dt;
      if (_waveSpawnTimer <= 0 && _monstersRemainingInWave > 0) {
        _spawnMonster();
        _monstersRemainingInWave--;
        _waveSpawnTimer = 1.2 + (_rng.nextDouble() * 0.8);
      } else if (_monstersRemainingInWave <= 0 && activeMonsters.isEmpty) {
        _isWaveSpawning = false;
        if (currentWave < totalWaves) {
          Future.delayed(const Duration(milliseconds: 800), () {
            if (phase == BattlePhase.playing) {
              _startWave(currentWave + 1);
            }
          });
        } else {
          // All waves completed -> Victory!
          _triggerVictory();
        }
      }
    }

    // 2. Projectile - Monster Collision Detection
    for (int p = activeProjectiles.length - 1; p >= 0; p--) {
      final proj = activeProjectiles[p];
      if (!proj.isMounted) {
        activeProjectiles.removeAt(p);
        continue;
      }

      for (int m = activeMonsters.length - 1; m >= 0; m--) {
        final monster = activeMonsters[m];
        if (!monster.isMounted || monster.isDead) continue;

        if (proj.position.distanceTo(monster.position) < 26.0) {
          proj.hit(monster);
          activeProjectiles.removeAt(p);
          break;
        }
      }
    }
  }

  void _spawnMonster() {
    final x = 40.0 + _rng.nextDouble() * 320.0;
    final y = 20.0 + _rng.nextDouble() * 40.0;

    MonsterType type = MonsterType.greenSlime;
    int hp = 40 + (currentWave * 20);

    if (currentWave >= 3 && _rng.nextDouble() < 0.4) {
      type = MonsterType.redMagma;
      hp = 80 + (currentWave * 30);
    } else if (currentWave == totalWaves && _monstersRemainingInWave == 1) {
      type = MonsterType.golemBoss;
      hp = 250 + (currentWave * 80);
    } else if (currentWave >= 2 && _rng.nextDouble() < 0.3) {
      type = MonsterType.goblin;
      hp = 60 + (currentWave * 20);
    }

    final monster = WaveMonsterComponent(
      type: type,
      maxHp: hp,
      position: Vector2(x, y),
      moveSpeed: 16.0 + (currentWave * 2.0),
      onDefeated: _handleMonsterDefeated,
      onReachedBottom: (m) {
        activeMonsters.remove(m);
        takePlayerDamage(15);
      },
    );

    activeMonsters.add(monster);
    world.add(monster);
  }

  void _handleMonsterDefeated(WaveMonsterComponent monster) {
    activeMonsters.remove(monster);
    goldEarned += monster.goldReward;
    currentXp += monster.xpReward;

    // Check Level Up
    if (currentXp >= xpTarget) {
      currentXp -= xpTarget;
      currentLevel++;
      xpTarget = (xpTarget * 1.4).round();
      _triggerSkillDraft();
    }

    _notifyStats();
  }

  void fireHeroVolley(int count, {bool isGold = false}) {
    if (phase != BattlePhase.playing) return;
    heroCannon.fireProjectiles(count, isGold: isGold, targets: activeMonsters);
  }

  void takePlayerDamage(int amount) {
    currentPlayerHp = max(0, currentPlayerHp - amount);
    _notifyStats();

    if (currentPlayerHp <= 0) {
      phase = BattlePhase.defeat;
      onPhaseChanged?.call(phase);
    }
  }

  void _triggerSkillDraft() {
    phase = BattlePhase.skillSelection;
    onPhaseChanged?.call(phase);

    final allSkills = List<SkillDefinition>.from(SkillDefinition.getAllSkills())..shuffle(_rng);
    final draftOptions = allSkills.take(3).toList();
    onSkillDraftRequested?.call(draftOptions);
  }

  void selectSkill(SkillDefinition skill) {
    activeSkills[skill.id] = (activeSkills[skill.id] ?? 0) + 1;

    damageMultiplier += skill.attackBonusPct;
    critChance += skill.critChanceBonus;
    gateWidthBonus += skill.gateWidthBonusPct;
    gateValueBonus += skill.gateValueBonus;
    goldenBallRate += skill.goldenBallChance;

    if (skill.maxHpPct > 0) {
      maxPlayerHp = (maxPlayerHp * (1.0 + skill.maxHpPct)).round();
      currentPlayerHp = maxPlayerHp;
    }

    phase = BattlePhase.playing;
    onPhaseChanged?.call(phase);
    _notifyStats();
  }

  void _triggerVictory() {
    phase = BattlePhase.victory;
    onPhaseChanged?.call(phase);
  }

  void _notifyStats() {
    onStatsUpdated?.call(currentPlayerHp, maxPlayerHp, currentWave, totalWaves, currentXp, xpTarget, goldEarned);
  }
}
