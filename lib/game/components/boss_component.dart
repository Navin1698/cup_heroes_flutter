import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/constants/color_constants.dart';
import '../../models/boss_definition.dart';
import '../../models/damage_info.dart';
import '../../models/enemy_definition.dart';
import '../emberbound_game.dart';
import 'damage_number_component.dart';
import 'enemy_component.dart';
import 'pickup_component.dart';

class BossComponent extends PositionComponent with HasGameReference<EmberboundGame> {
  final BossDefinition definition;

  int currentHp;
  BossPhase phase = BossPhase.phase1;
  double attackCooldownTimer = 2.0;
  double telegraphTimer = 0.0;
  double hitFlashTimer = 0.0;
  double animationTimer = 0.0;

  BossComponent({
    required this.definition,
    required Vector2 position,
  })  : currentHp = definition.maxHp,
        super(position: position, size: Vector2.all(definition.radius * 2), anchor: Anchor.center);

  bool get isDead => currentHp <= 0;

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead) return;

    animationTimer += dt * 3.0;
    if (hitFlashTimer > 0) hitFlashTimer -= dt;
    if (attackCooldownTimer > 0) attackCooldownTimer -= dt;

    // Check Phase transitions
    final hpPct = currentHp / definition.maxHp;
    if (hpPct <= 0.35 && phase != BossPhase.phase3Enraged) {
      phase = BossPhase.phase3Enraged;
      game.cameraShake(10.0);
    } else if (hpPct <= 0.70 && phase == BossPhase.phase1) {
      phase = BossPhase.phase2;
      game.cameraShake(6.0);
    }

    final player = game.player;
    if (player.isDead) return;

    final toPlayer = player.position - position;
    final distance = toPlayer.length;

    // Boss Movement & Attack Loop
    if (telegraphTimer > 0) {
      telegraphTimer -= dt;
      if (telegraphTimer <= 0) {
        _executeBossSlam(player);
        attackCooldownTimer = (phase == BossPhase.phase3Enraged) ? 1.5 : 2.5;
      }
    } else if (attackCooldownTimer <= 0) {
      // Start Telegraph
      telegraphTimer = (phase == BossPhase.phase3Enraged) ? 0.6 : 0.9;
      game.audio.playBossAttack();
    } else {
      // Move slowly towards player
      if (distance > 40.0) {
        final speed = (phase == BossPhase.phase3Enraged) ? definition.moveSpeed * 1.4 : definition.moveSpeed;
        position += toPlayer.normalized() * speed * dt;
      }
    }
  }

  void _executeBossSlam(dynamic player) {
    game.cameraShake(8.0);
    game.haptics.heavyImpact();

    // Damage in radius
    final dist = (player.position - position).length;
    final slamRadius = (phase == BossPhase.phase3Enraged) ? 140.0 : 100.0;

    if (dist <= slamRadius) {
      player.takeDamage(
        DamageInfo(
          amount: definition.baseDamage.toDouble() * (phase == BossPhase.phase3Enraged ? 1.4 : 1.0),
          source: 'boss_slam',
          knockbackForce: 100.0,
        ),
      );
    }

    // Phase 1 / 2 minion spawn
    if (phase == BossPhase.phase1 || phase == BossPhase.phase2) {
      final rng = Random();
      final offset = Vector2((rng.nextDouble() - 0.5) * 120, (rng.nextDouble() - 0.5) * 120);
      final mossling = EnemyDefinition.getWhisperingMeadowEnemies().first;
      game.world.add(EnemyComponent(definition: mossling, position: position + offset));
    }
  }

  void takeDamage(DamageInfo info) {
    if (isDead) return;

    currentHp = max(0, currentHp - info.amount.round());
    hitFlashTimer = 0.14;

    game.world.add(
      DamageNumberComponent(
        position: position.clone() + Vector2(0, -32),
        text: info.amount.round().toString(),
        color: info.isCritical ? EmberColors.accent : Colors.white,
        isCritical: info.isCritical,
      ),
    );

    if (currentHp <= 0) {
      _die();
    }
  }

  void _die() {
    // Drop massive loot
    for (int i = 0; i < 5; i++) {
      final rng = Random();
      final offset = Vector2((rng.nextDouble() - 0.5) * 80, (rng.nextDouble() - 0.5) * 80);
      game.world.add(
        PickupComponent(
          position: position + offset,
          type: PickupType.gem,
          value: 10,
        ),
      );
    }

    game.onBossDefeated();
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final r = definition.radius;
    final isHit = hitFlashTimer > 0;

    // Drop Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, r + 6), width: r * 2.4, height: 16),
      Paint()..color = Colors.black.withValues(alpha: 0.4),
    );

    // Telegraph Area Warning
    if (telegraphTimer > 0) {
      final slamRadius = (phase == BossPhase.phase3Enraged) ? 140.0 : 100.0;
      final warnPaint = Paint()
        ..color = EmberColors.danger.withValues(alpha: 0.35)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset.zero, slamRadius, warnPaint);

      final warnBorder = Paint()
        ..color = EmberColors.danger
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawCircle(Offset.zero, slamRadius, warnBorder);
    }

    // Boss Body (Ancient Colossus Bark & Moss)
    final bodyPaint = Paint()..color = isHit ? Colors.white : definition.primaryColor;
    canvas.drawCircle(Offset.zero, r, bodyPaint);

    // Moss / Foliage Crest
    final mossPaint = Paint()..color = EmberColors.success;
    canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: r), -pi, pi, true, mossPaint);

    // Enraged Glowing Eyes / Core
    final eyeColor = (phase == BossPhase.phase3Enraged) ? EmberColors.danger : EmberColors.accent;
    final eyeGlow = Paint()
      ..color = eyeColor.withValues(alpha: 0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(const Offset(-14, -8), 6, eyeGlow);
    canvas.drawCircle(const Offset(14, -8), 6, eyeGlow);

    canvas.drawCircle(const Offset(-14, -8), 4, Paint()..color = eyeColor);
    canvas.drawCircle(const Offset(14, -8), 4, Paint()..color = eyeColor);
  }
}
