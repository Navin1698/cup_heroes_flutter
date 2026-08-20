import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/constants/color_constants.dart';
import '../../models/damage_info.dart';

class ProjectileComponent extends PositionComponent {
  Vector2 velocity;
  final DamageInfo damageInfo;
  final bool isPlayerProjectile;
  double lifeTime;
  final Color color;
  final double radius;

  ProjectileComponent({
    required Vector2 position,
    required this.velocity,
    required this.damageInfo,
    this.isPlayerProjectile = true,
    this.lifeTime = 2.5,
    this.color = EmberColors.secondary,
    this.radius = 6.0,
  }) : super(position: position, size: Vector2.all(radius * 2), anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    lifeTime -= dt;

    if (lifeTime <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Glowing Trail & Core
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(Offset.zero, radius * 1.5, glowPaint);

    final corePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset.zero, radius, corePaint);

    final trailPaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..strokeWidth = radius * 1.2
      ..strokeCap = StrokeCap.round;

    final angle = atan2(velocity.y, velocity.x);
    canvas.drawLine(
      Offset.zero,
      Offset(-cos(angle) * 14, -sin(angle) * 14),
      trailPaint,
    );
  }
}
