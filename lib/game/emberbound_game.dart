import 'dart:math';
import 'package:flame/game.dart';
import '../core/audio/audio_service.dart';
import '../core/constants/game_constants.dart';
import '../core/haptics/haptic_service.dart';
import '../models/boss_definition.dart';
import '../models/enemy_definition.dart';
import '../models/hero_definition.dart';
import '../models/skill_definition.dart';
import '../models/world_definition.dart';
import 'components/boss_component.dart';
import 'components/enemy_component.dart';
import 'components/player_component.dart';
import 'components/puzzle_component.dart';
import 'game_world.dart';
import 'systems/combat_system.dart';

enum GamePlayState {
  playing,
  paused,
  skillSelection,
  victory,
  gameOver,
}

class EmberboundGame extends FlameGame with HasCollisionDetection {
  final HeroDefinition heroDefinition;
  final StageDefinition stageDefinition;
  final Function(GamePlayState) onStateChanged;
  final Function(List<SkillDefinition>) onSkillDraftRequested;
  final Function() onGameCompleted;

  late PlayerComponent player;
  late GameWorld gameWorld;
  late CombatSystem combatSystem;

  final AudioService audio = AudioService.instance;
  final HapticService haptics = HapticService.instance;

  GamePlayState playState = GamePlayState.playing;

  // Wave & Stage Progress
  int currentWave = 1;
  int enemiesKilledInStage = 0;
  int enemiesSpawnedInWave = 0;
  int targetEnemiesInWave = 5;
  double waveSpawnTimer = 0.0;
  bool isWaveComplete = false;

  // XP & Roguelike Leveling
  int currentXp = 0;
  int xpToNextLevel = 30;
  int heroInRunLevel = 1;

  // Puzzle State (Stage 3)
  int activatedPlatesCount = 0;

  // Camera Shake
  double shakeIntensity = 0.0;
  final Random _rng = Random();

  EmberboundGame({
    required this.heroDefinition,
    required this.stageDefinition,
    required this.onStateChanged,
    required this.onSkillDraftRequested,
    required this.onGameCompleted,
  }) {
    gameWorld = GameWorld();
    world = gameWorld;
    combatSystem = CombatSystem(this);
    player = PlayerComponent(
      heroDefinition: heroDefinition,
      position: Vector2(GameConstants.gameWorldWidth / 2, GameConstants.gameWorldHeight / 2),
    );
    world.add(player);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Camera follow player
    camera.follow(player);

    _initStage();
  }

  void _initStage() {
    currentWave = 1;
    enemiesKilledInStage = 0;
    enemiesSpawnedInWave = 0;
    targetEnemiesInWave = (stageDefinition.type == StageType.boss) ? 1 : 5;

    if (stageDefinition.type == StageType.boss) {
      // Spawn Boss
      final bossDef = BossDefinition.getRootColossus();
      world.add(
        BossComponent(
          definition: bossDef,
          position: Vector2(GameConstants.gameWorldWidth / 2, GameConstants.gameWorldHeight / 2 - 250),
        ),
      );
    } else if (stageDefinition.type == StageType.puzzle) {
      // Spawn 3 Pressure Plates
      world.add(PressurePlateComponent(plateIndex: 1, position: Vector2(400, 600)));
      world.add(PressurePlateComponent(plateIndex: 2, position: Vector2(600, 600)));
      world.add(PressurePlateComponent(plateIndex: 3, position: Vector2(800, 600)));
    }
  }

  @override
  void update(double dt) {
    if (playState != GamePlayState.playing) return;
    super.update(dt);

    // Handle Camera Shake
    if (shakeIntensity > 0) {
      final shakeOffset = Vector2(
        (_rng.nextDouble() - 0.5) * shakeIntensity,
        (_rng.nextDouble() - 0.5) * shakeIntensity,
      );
      camera.viewfinder.position += shakeOffset;
      shakeIntensity = max(0.0, shakeIntensity - dt * 20.0);
    }

    if (stageDefinition.type != StageType.boss) {
      _updateWaveSpawner(dt);
    }
  }

  void _updateWaveSpawner(double dt) {
    if (enemiesSpawnedInWave >= targetEnemiesInWave) {
      final aliveEnemies = world.children.whereType<EnemyComponent>().where((e) => !e.isDead).length;
      if (aliveEnemies == 0 && !isWaveComplete) {
        isWaveComplete = true;
        if (currentWave < stageDefinition.totalWaves) {
          currentWave++;
          enemiesSpawnedInWave = 0;
          targetEnemiesInWave += 3;
          isWaveComplete = false;
        } else {
          // All waves complete!
          _triggerVictory();
        }
      }
      return;
    }

    waveSpawnTimer += dt;
    if (waveSpawnTimer >= 1.2) {
      waveSpawnTimer = 0.0;
      _spawnNextEnemy();
    }
  }

  void _spawnNextEnemy() {
    final meadowEnemies = EnemyDefinition.getWhisperingMeadowEnemies();
    final enemyIndex = _rng.nextInt(stageDefinition.type == StageType.elite ? meadowEnemies.length : 3);
    final def = meadowEnemies[enemyIndex];

    final angle = _rng.nextDouble() * 2 * pi;
    final spawnDist = 320.0 + _rng.nextDouble() * 100.0;
    final spawnPos = player.position + Vector2(cos(angle) * spawnDist, sin(angle) * spawnDist);

    spawnPos.x = spawnPos.x.clamp(80.0, GameConstants.gameWorldWidth - 80.0);
    spawnPos.y = spawnPos.y.clamp(80.0, GameConstants.gameWorldHeight - 80.0);

    world.add(EnemyComponent(definition: def, position: spawnPos));
    enemiesSpawnedInWave++;
  }

  // -------------------------------------------------------------
  // Input Handling
  // -------------------------------------------------------------

  void setJoystickDirection(Vector2 direction) {
    player.moveDirection = direction;
  }

  void onBasicAttackPressed() => player.performBasicAttack();
  void onHeavyAttackPressed() => player.performHeavyAttack();
  void onSpecialPressed() => player.performSpecialAbility();
  void onUltimatePressed() => player.performUltimate();
  void onDashPressed() => player.dash();

  // -------------------------------------------------------------
  // Game Events
  // -------------------------------------------------------------

  void onEnemyKilled(EnemyComponent enemy) {
    enemiesKilledInStage++;
    player.addUltimateCharge(8.0);
    if (player.hasLifeDrain) {
      player.heal((player.maxHp * 0.05).round());
    }
    _addXp(enemy.definition.xpReward);
  }

  void onBossDefeated() {
    audio.playVictory();
    _triggerVictory();
  }

  void onPlayerDefeated() {
    playState = GamePlayState.gameOver;
    audio.playGameOver();
    onStateChanged(playState);
  }

  void onPressurePlateActivated(int index) {
    activatedPlatesCount++;
    audio.playPuzzleSuccess();
    haptics.mediumImpact();
    cameraShake(4.0);

    if (activatedPlatesCount >= 3) {
      _triggerVictory();
    }
  }

  void _addXp(int amount) {
    currentXp += amount;
    if (currentXp >= xpToNextLevel) {
      currentXp -= xpToNextLevel;
      heroInRunLevel++;
      xpToNextLevel = (xpToNextLevel * 1.4).round();

      audio.playLevelUp();
      haptics.vibrate();

      // Trigger Roguelike 3-Skill Selection Draft
      _promptSkillSelection();
    }
  }

  void _promptSkillSelection() {
    playState = GamePlayState.skillSelection;
    onStateChanged(playState);

    final allSkills = SkillDefinition.getAllSkills();
    final shuffled = List<SkillDefinition>.from(allSkills)..shuffle(_rng);
    final options = shuffled.take(3).toList();

    onSkillDraftRequested(options);
  }

  void selectSkill(SkillDefinition skill) {
    player.applySkill(skill);
    playState = GamePlayState.playing;
    onStateChanged(playState);
  }

  void pauseGame() {
    if (playState == GamePlayState.playing) {
      playState = GamePlayState.paused;
      onStateChanged(playState);
    }
  }

  void resumeGame() {
    if (playState == GamePlayState.paused) {
      playState = GamePlayState.playing;
      onStateChanged(playState);
    }
  }

  void _triggerVictory() {
    playState = GamePlayState.victory;
    audio.playVictory();
    haptics.vibrate();
    onStateChanged(playState);
    onGameCompleted();
  }

  void cameraShake(double intensity) {
    shakeIntensity = intensity;
  }
}
