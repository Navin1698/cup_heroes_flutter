import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/constants/color_constants.dart';
import '../../models/enemy_definition.dart';
import '../../models/damage_info.dart';
import '../emberbound_game.dart';
import 'damage_number_component.dart';
import 'pickup_component.dart';
import 'projectile_component.dart';

enum EnemyAiState {
  idle,
  chase,
  telegraph,
  attack,
  hurt,
  dead,
}

class EnemyComponent extends PositionComponent with HasGameReference<EmberboundGame> {
  final EnemyDefinition definition;

  int currentHp;
  EnemyAiState state = EnemyAiState.chase;
  double attackCooldownTimer = 0.0;
  double telegraphTimer = 0.0;
  double hitFlashTimer = 0.0;
  double slowTimer = 0.0;
  double burnTimer = 0.0;
  double burnTickTimer = 0.0;
  double stunTimer = 0.0;

  Vector2 velocity = Vector2.zero();

  EnemyComponent({
    required this.definition,
    required Vector2 position,
  })  : currentHp = definition.maxHp,
        super(position: position, size: Vector2.all(definition.radius * 2), anchor: Anchor.center);

  bool get isDead => currentHp <= 0;

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead) return;

    if (hitFlashTimer > 0) hitFlashTimer -= dt;
    if (attackCooldownTimer > 0) attackCooldownTimer -= dt;
    if (stunTimer > 0) {
      stunTimer -= dt;
      return; // Stunned, cannot act
    }

    // Status effect ticks
    if (burnTimer > 0) {
      burnTimer -= dt;
      burnTickTimer += dt;
      if (burnTickTimer >= 0.5) {
        burnTickTimer = 0.0;
        takeDamage(const DamageInfo(amount: 10, type: DamageType.fire, source: 'burn'));
      }
    }

    double currentSpeed = definition.moveSpeed;
    if (slowTimer > 0) {
      slowTimer -= dt;
      currentSpeed *= 0.65;
    }

    final player = game.player;
    if (player.isDead) return;

    final toPlayer = player.position - position;
    final distance = toPlayer.length;

    // AI State Machine
    switch (state) {
      case EnemyAiState.idle:
      case EnemyAiState.chase:
        if (distance <= definition.attackRange && attackCooldownTimer <= 0) {
          // Enter telegraph warning phase
          state = EnemyAiState.telegraph;
          telegraphTimer = 0.45;
        } else {
          // Chase player
          if (distance > 10.0) {
            velocity = toPlayer.normalized() * currentSpeed;
            position += velocity * dt;
          }
        }
        break;

      case EnemyAiState.telegraph:
        telegraphTimer -= dt;
        if (telegraphTimer <= 0) {
          _performAttack(player);
          state = EnemyAiState.attack;
          attackCooldownTimer = definition.attackCooldown;
        }
        break;

      case EnemyAiState.attack:
        state = EnemyAiState.chase;
        break;

      case EnemyAiState.hurt:
      case EnemyAiState.dead:
        break;
    }
  }

  void _performAttack(dynamic player) {
    if (definition.type == EnemyType.ranged) {
      // Shoot projectile
      final toPlayer = (player.position - position).normalized();
      game.world.add(
        ProjectileComponent(
          position: position.clone(),
          velocity: toPlayer * 220.0,
          damageInfo: DamageInfo(
            amount: definition.attackDamage.toDouble(),
            type: DamageType.crystal,
            source: 'enemy_ranged',
          ),
          isPlayerProjectile: false,
          color: EmberColors.danger,
        ),
      );
    } else if (definition.type == EnemyType.bomber) {
      // Explode in radius
      final toPlayer = (player.position - position).length;
      if (toPlayer <= 60.0) {
        player.takeDamage(DamageInfo(amount: definition.attackDamage.toDouble(), source: 'enemy_bomber'));
      }
      takeDamage(DamageInfo(amount: currentHp.toDouble(), source: 'self_destruct'));
    } else {
      // Melee strike
      final toPlayer = (player.position - position).length;
      if (toPlayer <= definition.attackRange + 15.0) {
        player.takeDamage(DamageInfo(amount: definition.attackDamage.toDouble(), source: 'enemy_melee'));
      }
    }
  }

  void takeDamage(DamageInfo info) {
    if (isDead) return;

    currentHp = max(0, currentHp - info.amount.round());
    hitFlashTimer = 0.12;

    // Floating damage text
    final dmgColor = info.isCritical
        ? EmberColors.accent
        : (info.type == DamageType.fire ? EmberColors.danger : Colors.white);

    game.world.add(
      DamageNumberComponent(
        position: position.clone() + Vector2(0, -16),
        text: info.amount.round().toString(),
        color: dmgColor,
        isCritical: info.isCritical,
      ),
    );

    // Apply Knockback
    if (info.knockbackForce > 0) {
      final fromSource = (position - game.player.position).normalized();
      position += fromSource * (info.knockbackForce * 0.15);
    }

    // Apply Status Effects
    if (info.statusEffect != null) {
      switch (info.statusEffect!.type) {
        case StatusEffectType.slow:
          slowTimer = info.statusEffect!.duration;
          break;
        case StatusEffectType.burn:
          burnTimer = info.statusEffect!.duration;
          break;
        case StatusEffectType.stun:
          stunTimer = info.statusEffect!.duration;
          break;
        default:
          break;
      }
    }

    if (currentHp <= 0) {
      _die();
    }
  }

  void _die() {
    state = EnemyAiState.dead;

    // Drop XP and Coins
    game.world.add(
      PickupComponent(
        position: position.clone(),
        type: PickupType.xp,
        value: definition.xpReward,
      ),
    );

    game.world.add(
      PickupComponent(
        position: position.clone() + Vector2(10, 0),
        type: PickupType.coin,
        value: definition.coinReward,
      ),
    );

    game.onEnemyKilled(this);
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final r = definition.radius;
    final isHit = hitFlashTimer > 0;

    // Drop shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, r + 4), width: r * 2.2, height: 10),
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );

    // Attack Warning Circle (Telegraph)
    if (state == EnemyAiState.telegraph) {
      final warnPaint = Paint()
        ..color = EmberColors.danger.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(Offset.zero, definition.attackRange, warnPaint);
    }

    // Enemy Body
    final bodyPaint = Paint()..color = isHit ? Colors.white : definition.primaryColor;
    canvas.drawCircle(Offset.zero, r, bodyPaint);

    // Outline / Shading
    canvas.drawCircle(
      Offset.zero,
      r,
      Paint()
        ..color = definition.secondaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Expressive Eyes
    canvas.drawCircle(Offset(-r * 0.35, -r * 0.1), r * 0.22, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(r * 0.35, -r * 0.1), r * 0.22, Paint()..color = Colors.white);

    // Pupils
    canvas.drawCircle(Offset(-r * 0.35, -r * 0.1), r * 0.12, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(r * 0.35, -r * 0.1), r * 0.12, Paint()..color = Colors.black);

    // Health Bar
    _drawHealthBar(canvas, r);
  }

  void _drawHealthBar(Canvas canvas, double r) {
    const width = 32.0;
    const height = 4.0;
    final barRect = Rect.fromCenter(center: Offset(0, -r - 10), width: width, height: height);

    // BG
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, const Radius.circular(2)),
      Paint()..color = const Color(0xFF100E22),
    );

    // Fill
    final hpPct = (currentHp / definition.maxHp).clamp(0.0, 1.0);
    if (hpPct > 0) {
      final fillRect = Rect.fromLTWH(barRect.left, barRect.top, width * hpPct, height);
      canvas.drawRRect(
        RRect.fromRectAndRadius(fillRect, const Radius.circular(2)),
        Paint()..color = EmberColors.danger,
      );
    }
  }
}
