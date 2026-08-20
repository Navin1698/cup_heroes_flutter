import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/game_constants.dart';
import '../core/audio/audio_manager.dart';
import '../models/hero_model.dart';
import '../models/enemy_model.dart';
import '../models/skill_perk_model.dart';
import '../models/chapter_model.dart';
import 'physics/ball_physics.dart';
import 'combat/combat_manager.dart';
import 'renderers/particle_system.dart';

enum GameStatus {
  playing,
  paused,
  perkDrafting,
  victory,
  defeat,
}

class GameController extends ChangeNotifier {
  final ChapterModel chapter;
  final HeroModel heroModel;
  final int bonusHp;
  final int bonusAttack;
  final double bonusCritRate;
  final double bonusAttackSpeed;
  final double talentCupMultiplier;
  final double talentBallDropChance;
  final double talentSuperChargeRate;

  GameStatus status = GameStatus.playing;
  double gameSpeed = 1.0; // 1x or 2x

  // Core Combat Entities
  late HeroEntity hero;
  final List<EnemyEntity> enemies = [];
  final List<Projectile> projectiles = [];
  final List<FloatingText> floatingTexts = [];

  // Core Pachinko Entities
  final List<GameBall> balls = [];
  final List<Peg> pegs = [];
  final List<MultiplierGate> gates = [];
  late CupCatcher cup;

  // Particle System
  final ParticleSystem particles = ParticleSystem();

  // Wave Management
  int currentWave = 1;
  int enemiesSpawnedInWave = 0;
  int totalEnemiesInWave = 6;
  double waveSpawnTimer = 0.0;
  bool isWaveComplete = false;
  double waveTransitionTimer = 0.0;

  // Run Stats & Leveling
  int currentExp = 0;
  int expToNextLevel = 15;
  int currentRunLevel = 1;
  int totalKills = 0;
  int totalBallsCaught = 0;
  int goldEarned = 0;

  // Active Perks in Run
  final Map<PerkId, int> activePerks = {};
  List<SkillPerkModel> currentPerkDraftOptions = [];

  // Screen Shake & Visual Juice
  double screenShakeAmount = 0.0;
  Offset screenShakeOffset = Offset.zero;
  double heroEnergyStreamTimer = 0.0;
  Offset lastCupCatchPos = Offset.zero;

  // Super Ability State
  bool get isSuperReady => cup.superCharge >= cup.maxSuperCharge;

  // RNG
  final Random _rng = Random();

  void triggerScreenShake(double amount) {
    screenShakeAmount = amount;
  }

  GameController({
    required this.chapter,
    required this.heroModel,
    this.bonusHp = 0,
    this.bonusAttack = 0,
    this.bonusCritRate = 0.0,
    this.bonusAttackSpeed = 0.0,
    this.talentCupMultiplier = 1.0,
    this.talentBallDropChance = 0.0,
    this.talentSuperChargeRate = 1.0,
  }) {
    _initHero();
    _initPachinkoBoard();
    _initWave();
  }

  void _initHero() {
    final maxHp = heroModel.baseHp + bonusHp;
    final attack = heroModel.baseAttack + bonusAttack;
    final speed = heroModel.attackSpeed + bonusAttackSpeed;
    final crit = 0.08 + bonusCritRate;

    hero = HeroEntity(
      model: heroModel,
      position: const Offset(GameConstants.heroX, GameConstants.heroY),
      maxHp: maxHp,
      attackDamage: attack,
      attackSpeed: speed,
      attackRange: heroModel.attackRange,
      critRate: crit,
    );
  }

  void _initPachinkoBoard() {
    // 1. Sliding Cup
    final cupW = GameConstants.cupWidth * talentCupMultiplier;
    cup = CupCatcher(
      x: GameConstants.worldWidth / 2,
      y: GameConstants.worldHeight - GameConstants.cupYOffsetFromBottom,
      width: cupW,
    );

    // 2. Pegs Layout (Staggered Grid)
    pegs.clear();
    const rows = 5;
    const startY = GameConstants.pachinkoTop + 45.0;
    const rowSpacing = 42.0;

    for (int r = 0; r < rows; r++) {
      final isOffset = r % 2 == 1;
      final count = isOffset ? 7 : 8;
      final step = (GameConstants.worldWidth - 50.0) / (count + 1);

      for (int c = 1; c <= count; c++) {
        final x = 25.0 + c * step + (isOffset ? step * 0.5 - 15 : 0);
        final y = startY + r * rowSpacing;
        pegs.add(Peg(position: Offset(x, y)));
      }
    }

    // 3. Multiplier Gates
    gates.clear();
    // Top Gate (Addition Gate)
    gates.add(MultiplierGate(
      id: 'gate_top',
      position: const Offset(GameConstants.worldWidth / 2, GameConstants.pachinkoTop + 25.0),
      width: 70.0,
      height: 22.0,
      type: GateType.add,
      value: 5,
      isMoving: true,
      moveSpeed: 35.0,
    ));

    // Middle Left & Right Gates (Multiplier Gates)
    gates.add(MultiplierGate(
      id: 'gate_mid_left',
      position: const Offset(110.0, GameConstants.pachinkoTop + 140.0),
      width: 65.0,
      height: 22.0,
      type: GateType.multiply,
      value: 2,
      isMoving: true,
      moveSpeed: 25.0,
      minX: 40.0,
      maxX: 190.0,
    ));

    gates.add(MultiplierGate(
      id: 'gate_mid_right',
      position: const Offset(290.0, GameConstants.pachinkoTop + 140.0),
      width: 65.0,
      height: 22.0,
      type: GateType.multiply,
      value: 3,
      isMoving: true,
      moveSpeed: 28.0,
      moveDirection: -1,
      minX: 210.0,
      maxX: 360.0,
    ));

    // Lower Super Gate
    gates.add(MultiplierGate(
      id: 'gate_bot',
      position: const Offset(GameConstants.worldWidth / 2, GameConstants.pachinkoTop + 240.0),
      width: 80.0,
      height: 24.0,
      type: GateType.add,
      value: 10,
      isMoving: true,
      moveSpeed: 45.0,
    ));
  }

  void _initWave() {
    isWaveComplete = false;
    enemiesSpawnedInWave = 0;
    waveSpawnTimer = 0.0;
    
    final isBossWave = (currentWave == chapter.totalWaves);
    totalEnemiesInWave = isBossWave ? 8 : (4 + currentWave * 2);
  }

  // Cup Drag Interaction
  void updateCupPosition(double normalizedX) {
    if (status != GameStatus.playing) return;
    final clampedX = normalizedX.clamp(cup.width / 2 + 10.0, GameConstants.worldWidth - cup.width / 2 - 10.0);
    cup.x = clampedX;
    notifyListeners();
  }

  // Master Frame Update (60fps)
  void update(double dt) {
    if (status != GameStatus.playing) return;
    final delta = dt * gameSpeed;

    // Sub-stepping for ultra smooth physics
    const subSteps = 2;
    final subDelta = delta / subSteps;

    for (int step = 0; step < subSteps; step++) {
      _updatePhysics(subDelta);
    }

    // Process Screen Shake
    if (screenShakeAmount > 0) {
      screenShakeOffset = Offset(
        (_rng.nextDouble() - 0.5) * screenShakeAmount,
        (_rng.nextDouble() - 0.5) * screenShakeAmount,
      );
      screenShakeAmount = max(0.0, screenShakeAmount - delta * 15.0);
    } else {
      screenShakeOffset = Offset.zero;
    }

    if (heroEnergyStreamTimer > 0) {
      heroEnergyStreamTimer = max(0.0, heroEnergyStreamTimer - delta);
    }

    _updateCombat(delta);
    _updateWave(delta);
    particles.update(delta);
    _updateFloatingTexts(delta);

    notifyListeners();
  }

  // -------------------------------------------------------------
  // Physics & Pachinko Loop
  // -------------------------------------------------------------
  void _updatePhysics(double dt) {
    // Update Cup & Gates
    cup.update(dt);
    for (final gate in gates) {
      gate.update(dt);
    }
    for (final peg in pegs) {
      peg.update(dt);
    }

    // Update Balls
    final List<GameBall> newClonedBalls = [];

    for (int i = balls.length - 1; i >= 0; i--) {
      final ball = balls[i];
      final bounceFactor = activePerks.containsKey(PerkId.bouncyBalls) ? 1.35 : 1.0;
      ball.updatePhysics(dt, bounceFactor);

      // 1. Wall Collisions
      if (ball.position.dx <= ball.radius + 8.0) {
        ball.position = Offset(ball.radius + 8.0, ball.position.dy);
        ball.velocity = Offset(ball.velocity.dx.abs() * GameConstants.ballRestitution * bounceFactor, ball.velocity.dy);
      } else if (ball.position.dx >= GameConstants.worldWidth - ball.radius - 8.0) {
        ball.position = Offset(GameConstants.worldWidth - ball.radius - 8.0, ball.position.dy);
        ball.velocity = Offset(-ball.velocity.dx.abs() * GameConstants.ballRestitution * bounceFactor, ball.velocity.dy);
      }

      // Top bounce limit (separator)
      if (ball.position.dy <= GameConstants.pachinkoTop + ball.radius) {
        ball.position = Offset(ball.position.dx, GameConstants.pachinkoTop + ball.radius);
        ball.velocity = Offset(ball.velocity.dx, ball.velocity.dy.abs() * 0.5);
      }

      // 2. Peg Collisions
      for (final peg in pegs) {
        final dist = (ball.position - peg.position).distance;
        final minDist = ball.radius + peg.radius;

        if (dist < minDist && dist > 0.0001) {
          peg.triggerHit();
          AudioManager.instance.playBallBounce();

          // Normal vector
          final normal = (ball.position - peg.position) / dist;
          ball.position = peg.position + normal * minDist;

          // Rebound velocity
          final dot = ball.velocity.dx * normal.dx + ball.velocity.dy * normal.dy;
          ball.velocity = (ball.velocity - normal * (2.0 * dot)) * (GameConstants.pegRestitution * bounceFactor);

          // Add slight random deflection for organic feel
          final randomDeflect = (_rng.nextDouble() - 0.5) * 40.0;
          ball.velocity = Offset(ball.velocity.dx + randomDeflect, ball.velocity.dy);
        }
      }

      // 3. Multiplier Gate Triggers
      for (final gate in gates) {
        if (!ball.passedGateIds.contains(gate.id) && gate.bounds.contains(ball.position)) {
          ball.passedGateIds.add(gate.id);
          gate.triggerHit();
          gate.moveSpeed += 2.0; // slight impulse
          AudioManager.instance.playGateHit(isMultiply: gate.type == GateType.multiply);
          particles.spawnBurst(gate.position, gate.type == GateType.multiply ? GameConstants.gateMultiplyColor : GameConstants.gateAddColor, count: 8);

          // Calculate spawned clones
          int clonesToSpawn = 0;
          if (gate.type == GateType.add) {
            clonesToSpawn = min(gate.value, 15);
          } else if (gate.type == GateType.multiply) {
            clonesToSpawn = min((gate.value - 1) * 3, 20);
          }

          for (int c = 0; c < clonesToSpawn; c++) {
            final spreadX = (_rng.nextDouble() - 0.5) * 35.0;
            final spreadY = _rng.nextDouble() * 30.0 + 10.0;
            final clonedBall = GameBall(
              position: Offset(ball.position.dx + spreadX, ball.position.dy + 8.0),
              velocity: Offset(ball.velocity.dx + spreadX * 2, ball.velocity.dy + spreadY),
              isSuper: ball.isSuper,
              color: gate.type == GateType.multiply ? const Color(0xFFFFA502) : const Color(0xFF2ED573),
            );
            clonedBall.passedGateIds.add(gate.id);
            newClonedBalls.add(clonedBall);
          }
        }
      }

      // 4. Cup Catch Check
      if (cup.catchArea.contains(ball.position)) {
        ball.isCaught = true;
        totalBallsCaught++;
        AudioManager.instance.playBallCaught();
        particles.spawnBallCatchStars(ball.position);

        // Surge Hero Attack Speed from Caught Balls!
        hero.attackTimer += 0.35;
        heroEnergyStreamTimer = 0.22;
        lastCupCatchPos = ball.position;

        // Fill Super Charge
        final chargeBonus = activePerks.containsKey(PerkId.superMeterFast) ? 1.5 : 1.0;
        cup.triggerCatch((ball.isSuper ? 6.0 : 2.5) * talentSuperChargeRate * chargeBonus);

        // Add EXP
        _addExp(ball.isSuper ? 4 : 2);

        // Small Hero Heal or Shield boost if perks active
        if (activePerks.containsKey(PerkId.energyShield)) {
          hero.currentShield = min(hero.maxShield, hero.currentShield + 2);
        }

        balls.removeAt(i);
        continue;
      }

      // Bottom Expiry (Missed Cup)
      if (ball.position.dy >= GameConstants.worldHeight + 10.0) {
        ball.isExpired = true;
        balls.removeAt(i);
      }
    }

    // Limit maximum simultaneous balls on screen for 60fps performance
    if (balls.length + newClonedBalls.length < 180) {
      balls.addAll(newClonedBalls);
    }
  }

  // -------------------------------------------------------------
  // Combat Loop
  // -------------------------------------------------------------
  void _updateCombat(double dt) {
    hero.update(dt);

    // Hero Auto-Attack
    final attackInterval = 1.0 / hero.attackSpeed;
    if (hero.attackTimer >= attackInterval && enemies.isNotEmpty) {
      hero.attackTimer = 0.0;
      _performHeroAttack();
    }

    // Update Projectiles
    for (int i = projectiles.length - 1; i >= 0; i--) {
      final proj = projectiles[i];
      proj.update(dt);

      if (proj.isExpired) {
        projectiles.removeAt(i);
        continue;
      }

      // Check collision against enemies
      for (final enemy in enemies) {
        if (!enemy.isDead && !proj.hitEnemyIds.contains(enemy.instanceId)) {
          final dist = (proj.position - enemy.position).distance;
          if (dist <= enemy.model.size * 0.6 + proj.radius) {
            proj.hitEnemyIds.add(enemy.instanceId);
            _applyDamageToEnemy(enemy, proj.damage, proj.isCrit, proj.damageType);

            // Chain Lightning
            if (proj.chainCount > 0) {
              _triggerChainLightning(enemy.position, proj.damage, proj.chainCount - 1);
            }

            // Piercing
            if (proj.pierceCount > 0) {
              proj.pierceCount--;
            } else {
              proj.isExpired = true;
              projectiles.removeAt(i);
              break;
            }
          }
        }
      }
    }

    // Update Enemies
    for (int i = enemies.length - 1; i >= 0; i--) {
      final enemy = enemies[i];
      enemy.update(dt, hero.position);

      // Enemy Attack
      if (enemy.attackTimer >= enemy.model.attackCooldown) {
        enemy.attackTimer = 0.0;
        _performEnemyAttack(enemy);
      }

      // Enemy Defeated
      if (enemy.isDead) {
        _handleEnemyDeath(enemy);
        enemies.removeAt(i);
      }
    }

    // Check Hero Defeat
    if (hero.currentHp <= 0 && status == GameStatus.playing) {
      status = GameStatus.defeat;
      AudioManager.instance.playDefeat();
      notifyListeners();
    }
  }

  void _performHeroAttack() {
    AudioManager.instance.playAttack();
    hero.attackAnimationTimer = 0.15;

    // Target closest enemy
    EnemyEntity? target;
    double closestDist = double.infinity;
    for (final e in enemies) {
      final dist = (e.position - hero.position).distance;
      if (dist < closestDist) {
        closestDist = dist;
        target = e;
      }
    }

    if (target == null) return;

    final shots = hero.multiShotCount;
    final isCrit = _rng.nextDouble() < hero.critRate;
    final baseDmg = isCrit
        ? (hero.attackDamage * hero.critDamageMultiplier).round()
        : hero.attackDamage;

    for (int s = 0; s < shots; s++) {
      final spreadAngle = (s - (shots - 1) / 2.0) * 0.18;
      final dir = (target.position - hero.position);
      final angle = atan2(dir.dy, dir.dx) + spreadAngle;
      final speed = 460.0;

      projectiles.add(Projectile(
        position: hero.position + const Offset(15.0, 0.0),
        velocity: Offset(cos(angle) * speed, sin(angle) * speed),
        damage: baseDmg,
        isCrit: isCrit,
        damageType: hero.hasFireBurn ? DamageType.fire : DamageType.physical,
        pierceCount: hero.pierceCount,
        chainCount: hero.hasChainLightning ? 2 : 0,
        color: isCrit ? Colors.orangeAccent : hero.model.primaryColor,
      ));
    }
  }

  void _performEnemyAttack(EnemyEntity enemy) {
    hero.takeDamage(enemy.model.attackDamage);
    AudioManager.instance.playEnemyHit();
    particles.spawnBurst(hero.position, Colors.redAccent, count: 6);

    _addFloatingText('-${enemy.model.attackDamage}', hero.position + const Offset(-10, -20), Colors.redAccent);

    // Thorns damage perk
    if (activePerks.containsKey(PerkId.thornsDamage)) {
      final thornsDmg = (enemy.model.attackDamage * 0.5).round();
      _applyDamageToEnemy(enemy, thornsDmg, false, DamageType.physical);
    }
  }

  void _applyDamageToEnemy(EnemyEntity enemy, int damage, bool isCrit, DamageType type) {
    enemy.takeDamage(damage, isCrit);
    particles.spawnBurst(enemy.position, isCrit ? Colors.amber : Colors.white, count: isCrit ? 10 : 5);

    // Life Steal
    if (hero.lifeStealPercent > 0) {
      final healAmount = (damage * hero.lifeStealPercent).round();
      if (healAmount > 0) hero.heal(healAmount);
    }

    // Status Ailments
    if (hero.hasFireBurn) {
      enemy.applyBurn((damage * 0.3).round(), 3.0);
    }
    if (hero.hasFrostNova) {
      enemy.applyChill(2.5);
    }

    _addFloatingText(
      '$damage${isCrit ? '!' : ''}',
      enemy.position + Offset((_rng.nextDouble() - 0.5) * 16.0, -18.0),
      isCrit ? Colors.amberAccent : Colors.white,
      isCrit: isCrit,
    );
  }

  void _triggerChainLightning(Offset origin, int dmg, int remainingChains) {
    if (enemies.isEmpty || remainingChains <= 0) return;

    for (final e in enemies) {
      if ((e.position - origin).distance < 120.0 && !e.isDead) {
        _applyDamageToEnemy(e, (dmg * 0.7).round(), false, DamageType.lightning);
        particles.spawnBurst(e.position, Colors.cyanAccent, count: 8);
        break;
      }
    }
  }

  void _handleEnemyDeath(EnemyEntity enemy) {
    totalKills++;
    goldEarned += enemy.model.goldReward;
    _addExp(enemy.model.expReward);
    AudioManager.instance.playEnemyDefeated();

    // Spawn Dropped Balls directly into Pachinko Spawner Top
    int dropCount = enemy.model.ballDropCount;
    if (activePerks.containsKey(PerkId.extraBallSpawner)) {
      dropCount += 3;
    }
    if (_rng.nextDouble() < talentBallDropChance) {
      dropCount *= 2;
    }

    final dropX = enemy.position.dx.clamp(40.0, GameConstants.worldWidth - 40.0);
    for (int b = 0; b < dropCount; b++) {
      final spreadX = (_rng.nextDouble() - 0.5) * 40.0;
      final speedY = _rng.nextDouble() * 60.0 + 80.0;
      balls.add(GameBall(
        position: Offset(dropX + spreadX, GameConstants.pachinkoTop + 5.0),
        velocity: Offset(spreadX * 2.0, speedY),
        isSuper: enemy.model.isBoss,
        color: enemy.model.isBoss ? const Color(0xFFFFD700) : Colors.white,
      ));
    }
  }

  // -------------------------------------------------------------
  // Super Ability Trigger
  // -------------------------------------------------------------
  void triggerSuperAbility() {
    if (!isSuperReady || status != GameStatus.playing) return;

    cup.resetSuper();
    AudioManager.instance.playLevelUp();
    particles.spawnSuperExplosion(const Offset(GameConstants.worldWidth / 2, GameConstants.arenaHeight / 2));

    // Blast all active enemies
    for (final enemy in enemies) {
      final superDmg = (hero.attackDamage * 3.5).round();
      _applyDamageToEnemy(enemy, superDmg, true, DamageType.fire);
    }

    // Rain 15 Golden Super Balls into Pachinko board
    for (int i = 0; i < 15; i++) {
      final x = 40.0 + _rng.nextDouble() * (GameConstants.worldWidth - 80.0);
      balls.add(GameBall(
        position: Offset(x, GameConstants.pachinkoTop + 5.0),
        velocity: Offset((_rng.nextDouble() - 0.5) * 50.0, 100.0 + _rng.nextDouble() * 60.0),
        isSuper: true,
        color: const Color(0xFFFFD700),
      ));
    }

    _addFloatingText('SUPER ACTIVE!', const Offset(GameConstants.worldWidth / 2 - 40, 100), Colors.amber, isCrit: true);
    notifyListeners();
  }

  // -------------------------------------------------------------
  // Waves & Leveling Loop
  // -------------------------------------------------------------
  void _updateWave(double dt) {
    if (isWaveComplete) {
      waveTransitionTimer += dt;
      if (waveTransitionTimer >= 2.0) {
        waveTransitionTimer = 0.0;
        if (currentWave < chapter.totalWaves) {
          currentWave++;
          _initWave();
        } else {
          status = GameStatus.victory;
          AudioManager.instance.playVictory();
          notifyListeners();
        }
      }
      return;
    }

    // Spawn wave enemies
    waveSpawnTimer += dt;
    if (waveSpawnTimer >= 1.2 && enemiesSpawnedInWave < totalEnemiesInWave) {
      waveSpawnTimer = 0.0;
      enemiesSpawnedInWave++;

      final isBossWave = (currentWave == chapter.totalWaves);
      final isLastInWave = (enemiesSpawnedInWave == totalEnemiesInWave);

      final EnemyType typeToSpawn;
      if (isBossWave && isLastInWave) {
        typeToSpawn = chapter.bossType;
      } else {
        typeToSpawn = chapter.enemyPool[_rng.nextInt(chapter.enemyPool.length)];
      }

      final enemyModel = EnemyModel.createEnemy(typeToSpawn, currentWave);
      final spawnY = 80.0 + _rng.nextDouble() * (GameConstants.arenaHeight - 140.0);

      enemies.add(EnemyEntity(
        instanceId: 'enemy_${DateTime.now().microsecondsSinceEpoch}_$enemiesSpawnedInWave',
        model: enemyModel,
        position: Offset(GameConstants.enemySpawnX, spawnY),
      ));
    }

    // Check if Wave cleared
    if (enemiesSpawnedInWave >= totalEnemiesInWave && enemies.isEmpty) {
      isWaveComplete = true;
      _addFloatingText('WAVE CLEAR!', const Offset(GameConstants.worldWidth / 2 - 35, 120), Colors.greenAccent, isCrit: true);
    }
  }

  void _addExp(int amount) {
    currentExp += amount;
    if (currentExp >= expToNextLevel) {
      currentExp -= expToNextLevel;
      expToNextLevel = (expToNextLevel * 1.45).round();
      currentRunLevel++;
      _triggerPerkDraft();
    }
  }

  void _triggerPerkDraft() {
    status = GameStatus.perkDrafting;
    AudioManager.instance.playLevelUp();

    final allPerks = SkillPerkModel.getAllPerks();
    final List<SkillPerkModel> options = [];
    final shuffled = List<SkillPerkModel>.from(allPerks)..shuffle(_rng);

    for (final perk in shuffled) {
      final currentStacks = activePerks[perk.id] ?? 0;
      if (currentStacks < perk.maxStacks) {
        options.add(perk);
        if (options.length >= 3) break;
      }
    }

    currentPerkDraftOptions = options;
    notifyListeners();
  }

  void selectPerk(SkillPerkModel perk) {
    activePerks[perk.id] = (activePerks[perk.id] ?? 0) + 1;
    _applyPerkEffect(perk.id);
    status = GameStatus.playing;
    notifyListeners();
  }

  void _applyPerkEffect(PerkId id) {
    switch (id) {
      case PerkId.multiShot:
        hero.multiShotCount++;
        break;
      case PerkId.damageBoost:
        hero.attackDamage = (hero.attackDamage * 1.25).round();
        break;
      case PerkId.attackSpeedUp:
        hero.attackSpeed *= 1.30;
        break;
      case PerkId.critChanceUp:
        hero.critRate += 0.20;
        hero.critDamageMultiplier += 0.5;
        break;
      case PerkId.chainLightning:
        hero.hasChainLightning = true;
        break;
      case PerkId.fireBurn:
        hero.hasFireBurn = true;
        break;
      case PerkId.frostNova:
        hero.hasFrostNova = true;
        break;
      case PerkId.piercingShots:
        hero.pierceCount += 2;
        break;
      case PerkId.energyShield:
        hero.maxShield = (hero.maxHp * 0.25).round();
        hero.currentShield = hero.maxShield;
        break;
      case PerkId.lifeSteal:
        hero.lifeStealPercent += 0.15;
        break;
      case PerkId.maxHpUp:
        hero.maxHp = (hero.maxHp * 1.35).round();
        hero.heal((hero.maxHp * 0.35).round());
        break;
      case PerkId.cupWidthUp:
        cup.width *= 1.30;
        break;
      case PerkId.gateBoostMultiply:
        for (final g in gates) {
          if (g.type == GateType.multiply) g.value++;
        }
        break;
      case PerkId.gateBoostPlus:
        for (final g in gates) {
          if (g.type == GateType.add) g.value += 10;
        }
        break;
      default:
        break;
    }
  }

  void toggleSpeed() {
    gameSpeed = (gameSpeed == 1.0) ? 2.0 : 1.0;
    notifyListeners();
  }

  void togglePause() {
    if (status == GameStatus.playing) {
      status = GameStatus.paused;
    } else if (status == GameStatus.paused) {
      status = GameStatus.playing;
    }
    notifyListeners();
  }

  void _addFloatingText(String text, Offset pos, Color color, {bool isCrit = false}) {
    floatingTexts.add(FloatingText(
      text: text,
      position: pos,
      color: color,
      fontSize: isCrit ? 16.0 : 13.0,
      isCrit: isCrit,
    ));
  }

  void _updateFloatingTexts(double dt) {
    for (int i = floatingTexts.length - 1; i >= 0; i--) {
      floatingTexts[i].update(dt);
      if (floatingTexts[i].lifeTime <= 0) {
        floatingTexts.removeAt(i);
      }
    }
  }
}
