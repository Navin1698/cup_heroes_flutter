import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/constants/color_constants.dart';
import '../../core/constants/game_constants.dart';
import '../../models/hero_definition.dart';
import '../../models/damage_info.dart';
import '../../models/skill_definition.dart';
import '../emberbound_game.dart';
import 'slash_effect_component.dart';

class PlayerComponent extends PositionComponent with HasGameReference<EmberboundGame> {
  final HeroDefinition heroDefinition;

  // Combat Stats
  int maxHp;
  int currentHp;
  int attackDamage;
  int defense;
  double moveSpeed;
  double critChance;
  double critDamage;
  double attackSpeed;

  // Modifiers from Roguelike Skills
  final Map<String, int> activeSkills = {};
  double damageReduction = 0.0;
  bool hasLifeDrain = false;
  bool hasChainStrike = false;
  bool hasFireBurn = false;
  bool hasFrostChill = false;
  bool hasExplosiveHit = false;

  // Input & Movement
  Vector2 moveDirection = Vector2.zero();
  Vector2 facingDirection = Vector2(1, 0);

  // Dash State
  bool isDashing = false;
  double dashTimer = 0.0;
  double dashCooldownTimer = 0.0;

  // Attack Timers & Cooldowns
  double attackCooldownTimer = 0.0;
  double heavyAttackCooldownTimer = 0.0;
  double specialCooldownTimer = 0.0;
  double ultimateCooldownTimer = 0.0;
  double hitFlashTimer = 0.0;
  double animationTimer = 0.0;

  // Energy / Ultimate Charge (0 - 100)
  double ultimateCharge = 0.0;
  final double maxUltimateCharge = 100.0;

  PlayerComponent({
    required this.heroDefinition,
    required Vector2 position,
  })  : maxHp = heroDefinition.baseHp,
        currentHp = heroDefinition.baseHp,
        attackDamage = heroDefinition.baseAttack,
        defense = heroDefinition.baseDefense,
        moveSpeed = heroDefinition.baseSpeed,
        critChance = heroDefinition.baseCritChance,
        critDamage = heroDefinition.baseCritDamage,
        attackSpeed = 1.0,
        super(position: position, size: Vector2(36, 44), anchor: Anchor.center);

  bool get isDead => currentHp <= 0;
  bool get canDash => dashCooldownTimer <= 0 && !isDashing;
  bool get canBasicAttack => attackCooldownTimer <= 0;
  bool get canHeavyAttack => heavyAttackCooldownTimer <= 0;
  bool get canSpecial => specialCooldownTimer <= 0;
  bool get canUltimate => ultimateCharge >= maxUltimateCharge;

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead) return;

    animationTimer += dt * 6.0;

    // Cooldown management
    if (dashCooldownTimer > 0) dashCooldownTimer -= dt;
    if (attackCooldownTimer > 0) attackCooldownTimer -= dt;
    if (heavyAttackCooldownTimer > 0) heavyAttackCooldownTimer -= dt;
    if (specialCooldownTimer > 0) specialCooldownTimer -= dt;
    if (hitFlashTimer > 0) hitFlashTimer -= dt;

    // Dash logic
    if (isDashing) {
      dashTimer -= dt;
      position += facingDirection * GameConstants.playerDashSpeed * dt;
      if (dashTimer <= 0) {
        isDashing = false;
      }
    } else if (moveDirection.length2 > 0.01) {
      // Normal walk/run
      facingDirection = moveDirection.normalized();
      position += facingDirection * moveSpeed * dt;
    }

    // Clamp inside world boundaries
    position.x = position.x.clamp(30.0, GameConstants.gameWorldWidth - 30.0);
    position.y = position.y.clamp(30.0, GameConstants.gameWorldHeight - 30.0);
  }

  // -------------------------------------------------------------
  // Player Actions
  // -------------------------------------------------------------

  void dash() {
    if (!canDash || isDead) return;
    isDashing = true;
    dashTimer = GameConstants.playerDashDuration;
    dashCooldownTimer = GameConstants.playerDashCooldown;
    game.haptics.lightImpact();
  }

  void performBasicAttack() {
    if (!canBasicAttack || isDead) return;
    attackCooldownTimer = 0.35 / attackSpeed;

    final angle = atan2(facingDirection.y, facingDirection.x);
    final slashPos = position + facingDirection * 28.0;

    game.world.add(
      SlashEffectComponent(
        position: slashPos,
        startAngle: angle - 0.9,
        sweepAngle: 1.8,
        color: EmberColors.secondary,
      ),
    );

    // Apply combat hit check
    final rng = Random();
    final isCrit = rng.nextDouble() < critChance;
    final finalDamage = (attackDamage * (isCrit ? critDamage : 1.0)).round();

    final dmgInfo = DamageInfo(
      amount: finalDamage.toDouble(),
      type: DamageType.crystal,
      source: 'player_basic',
      isCritical: isCrit,
      knockbackForce: 45.0,
      statusEffect: hasFrostChill
          ? StatusEffect(type: StatusEffectType.slow, duration: 2.0, power: 0.3)
          : (hasFireBurn ? StatusEffect(type: StatusEffectType.burn, duration: 2.5, power: 12) : null),
    );

    game.combatSystem.executePlayerMeleeAttack(slashPos, 48.0, dmgInfo);
    game.audio.playAttack();
    game.haptics.selectionClick();
  }

  void performHeavyAttack() {
    if (!canHeavyAttack || isDead) return;
    heavyAttackCooldownTimer = 3.5;

    final angle = atan2(facingDirection.y, facingDirection.x);
    final slashPos = position + facingDirection * 36.0;

    game.world.add(
      SlashEffectComponent(
        position: slashPos,
        radius: 64.0,
        startAngle: angle - 1.2,
        sweepAngle: 2.4,
        color: EmberColors.accent,
        isHeavy: true,
      ),
    );

    final dmgInfo = DamageInfo(
      amount: (attackDamage * 2.5).toDouble(),
      type: DamageType.crystal,
      source: 'player_heavy',
      isCritical: true,
      knockbackForce: 120.0,
    );

    game.combatSystem.executePlayerMeleeAttack(slashPos, 68.0, dmgInfo);
    game.audio.playHeavyAttack();
    game.haptics.mediumImpact();
    game.cameraShake(5.0);
  }

  void performSpecialAbility() {
    if (!canSpecial || isDead) return;
    specialCooldownTimer = 6.0;

    // Crystal Nova radial burst
    final dmgInfo = DamageInfo(
      amount: (attackDamage * 1.8).toDouble(),
      type: DamageType.crystal,
      source: 'player_nova',
      knockbackForce: 150.0,
      statusEffect: StatusEffect(type: StatusEffectType.stun, duration: 1.0, power: 1.0),
    );

    game.combatSystem.executeRadialNova(position, 110.0, dmgInfo);
    game.audio.playSpecial();
    game.haptics.heavyImpact();
    game.cameraShake(7.0);
  }

  void performUltimate() {
    if (!canUltimate || isDead) return;
    ultimateCharge = 0.0;

    // Celestial Burst
    final dmgInfo = DamageInfo(
      amount: (attackDamage * 4.5).toDouble(),
      type: DamageType.crystal,
      source: 'player_ultimate',
      isCritical: true,
      knockbackForce: 200.0,
    );

    game.combatSystem.executeLinearBeam(position, facingDirection, 280.0, 60.0, dmgInfo);
    game.audio.playUltimate();
    game.haptics.vibrate();
    game.cameraShake(12.0);
  }

  void takeDamage(DamageInfo info) {
    if (isDead || isDashing) return;

    final reducedDamage = (info.amount * (1.0 - damageReduction) - defense * 0.3).clamp(1.0, 9999.0);
    currentHp = max(0, currentHp - reducedDamage.round());
    hitFlashTimer = 0.15;

    game.audio.playHit();
    game.haptics.mediumImpact();
    game.cameraShake(4.0);

    if (currentHp <= 0) {
      game.onPlayerDefeated();
    }
  }

  void heal(int amount) {
    currentHp = min(maxHp, currentHp + amount);
  }

  void addUltimateCharge(double amount) {
    ultimateCharge = (ultimateCharge + amount).clamp(0.0, maxUltimateCharge);
  }

  void applySkill(SkillDefinition skill) {
    final lvl = (activeSkills[skill.id] ?? 0) + 1;
    activeSkills[skill.id] = lvl;

    attackDamage = (attackDamage * (1.0 + skill.attackBonusPct)).round();
    attackSpeed += skill.attackSpeedPct;
    critChance += skill.critChanceBonus;
    critDamage += skill.critDamageBonus;
    moveSpeed += heroDefinition.baseSpeed * skill.moveSpeedPct;
    damageReduction = (damageReduction + skill.damageReductionPct).clamp(0.0, 0.75);

    if (skill.hasLifeDrain) hasLifeDrain = true;
    if (skill.hasChainStrike) hasChainStrike = true;
    if (skill.hasFireBurn) hasFireBurn = true;
    if (skill.hasFrostChill) hasFrostChill = true;
    if (skill.hasExplosiveHit) hasExplosiveHit = true;

    if (skill.maxHpPct > 0) {
      final oldMax = maxHp;
      maxHp = (maxHp * (1.0 + skill.maxHpPct)).round();
      heal(maxHp - oldMax);
    }
  }

  // -------------------------------------------------------------
  // Rendering ARIN (Crystal Guardian Character)
  // -------------------------------------------------------------
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final isMoving = moveDirection.length2 > 0.01;
    final bobY = isMoving ? sin(animationTimer) * 2.5 : sin(animationTimer * 0.5) * 1.0;
    final isHit = hitFlashTimer > 0;

    // Drop Shadow
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 20), width: 34, height: 12),
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );

    // 1. Hero Cape
    final capePaint = Paint()..color = isHit ? Colors.white : EmberColors.primary;
    final capePath = Path()
      ..moveTo(-10, 4 + bobY)
      ..lineTo(10, 4 + bobY)
      ..lineTo(14, 22 + bobY)
      ..lineTo(-14, 22 + bobY)
      ..close();
    canvas.drawPath(capePath, capePaint);

    // 2. Body / Tunic
    final bodyPaint = Paint()..color = isHit ? Colors.white : const Color(0xFF2C3E50);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, 4 + bobY), width: 22, height: 26), const Radius.circular(8)),
      bodyPaint,
    );

    // 3. Crystal Shoulder Armor (Pauldron)
    final crystalPauldron = Paint()..color = isHit ? Colors.white : EmberColors.secondary;
    canvas.drawCircle(Offset(-12, -2 + bobY), 5.0, crystalPauldron);
    canvas.drawCircle(Offset(12, -2 + bobY), 5.0, crystalPauldron);

    // 4. Head & Crystal Circlet
    final headPaint = Paint()..color = isHit ? Colors.white : const Color(0xFFF39C12);
    canvas.drawCircle(Offset(0, -10 + bobY), 9.0, headPaint);

    // Hair / Hood
    canvas.drawCircle(Offset(0, -13 + bobY), 9.0, Paint()..color = const Color(0xFF2C3E50));

    // Circlet Crystal
    canvas.drawCircle(Offset(0, -12 + bobY), 3.0, Paint()..color = EmberColors.secondary);

    // 5. Glowing Wrist Crystal & Weapon Blade
    final wristOffset = Offset(facingDirection.x * 12, (facingDirection.y * 12) + bobY);
    final bladeGlow = Paint()
      ..color = EmberColors.secondary.withValues(alpha: 0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(wristOffset, 8.0, bladeGlow);

    // Energy Blade
    final bladeEnd = wristOffset + Offset(facingDirection.x * 16, facingDirection.y * 16);
    final bladePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(wristOffset, bladeEnd, bladePaint);
  }
}
