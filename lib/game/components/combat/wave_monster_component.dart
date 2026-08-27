import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/color_constants.dart';

enum MonsterType { greenSlime, redMagma, goblin, skeleton, golemBoss }

class WaveMonsterComponent extends PositionComponent {
  final MonsterType type;
  final int maxHp;
  int currentHp;
  final double moveSpeed;
  final int goldReward;
  final int xpReward;
  final void Function(WaveMonsterComponent monster)? onDefeated;
  final void Function(WaveMonsterComponent monster)? onReachedBottom;

  double _hitFlashTimer = 0.0;
  double _animTimer = 0.0;

  WaveMonsterComponent({
    required this.type,
    required this.maxHp,
    required Vector2 position,
    this.moveSpeed = 22.0,
    this.goldReward = 15,
    this.xpReward = 20,
    this.onDefeated,
    this.onReachedBottom,
  })  : currentHp = maxHp,
        super(position: position, size: Vector2(36, 36), anchor: Anchor.center);

  bool get isDead => currentHp <= 0;

  void takeDamage(int amount, {bool isCrit = false}) {
    if (isDead) return;
    currentHp = max(0, currentHp - amount);
    _hitFlashTimer = 0.12;

    if (currentHp <= 0) {
      onDefeated?.call(this);
      removeFromParent();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead) return;

    _animTimer += dt * 4.0;
    if (_hitFlashTimer > 0) _hitFlashTimer -= dt;

    // Advance downwards
    position.y += moveSpeed * dt;

    // Check if breached hero line
    if (position.y > 420.0) {
      onReachedBottom?.call(this);
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final isHit = _hitFlashTimer > 0;
    final center = Offset.zero;
    final hopY = sin(_animTimer) * 3.0;

    // 1. Monster Shadow
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 14), width: 30, height: 10),
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );

    // 2. Monster Body
    Color bodyColor;
    Color glowColor;

    switch (type) {
      case MonsterType.greenSlime:
        bodyColor = const Color(0xFF22C55E);
        glowColor = const Color(0xFF4ADE80);
        break;
      case MonsterType.redMagma:
        bodyColor = const Color(0xFFEF4444);
        glowColor = const Color(0xFFF87171);
        break;
      case MonsterType.goblin:
        bodyColor = const Color(0xFF10B981);
        glowColor = const Color(0xFF34D399);
        break;
      case MonsterType.skeleton:
        bodyColor = const Color(0xFFE2E8F0);
        glowColor = const Color(0xFF94A3B8);
        break;
      case MonsterType.golemBoss:
        bodyColor = const Color(0xFFF97316);
        glowColor = const Color(0xFFFB923C);
        break;
    }

    if (isHit) {
      bodyColor = Colors.white;
      glowColor = Colors.white;
    }

    // Outer Glow
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(0, hopY), 16, glowPaint);

    // Slime Dome / Body
    final bodyPaint = Paint()..color = bodyColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, hopY), width: 28, height: 26),
        const Radius.circular(12),
      ),
      bodyPaint,
    );

    // Eyes
    final eyePaint = Paint()..color = isHit ? Colors.black : Colors.white;
    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(-6, -2 + hopY), 3.5, eyePaint);
    canvas.drawCircle(Offset(6, -2 + hopY), 3.5, eyePaint);
    if (!isHit) {
      canvas.drawCircle(Offset(-6, -1 + hopY), 1.8, pupilPaint);
      canvas.drawCircle(Offset(6, -1 + hopY), 1.8, pupilPaint);
    }

    // 3. Health Bar
    if (currentHp < maxHp) {
      final hpPct = (currentHp / maxHp).clamp(0.0, 1.0);
      final barRect = Rect.fromLTWH(-16, -18 + hopY, 32, 4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(barRect, const Radius.circular(2)),
        Paint()..color = Colors.black.withValues(alpha: 0.7),
      );
      final fillRect = Rect.fromLTWH(-16, -18 + hopY, 32 * hpPct, 4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(fillRect, const Radius.circular(2)),
        Paint()..color = hpPct > 0.3 ? const Color(0xFF00FF88) : const Color(0xFFFF2A85),
      );
    }
  }
}
