import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/color_constants.dart';

class PegComponent extends PositionComponent {
  final double radius;
  final bool isBumper;

  double _hitFlashTimer = 0.0;

  PegComponent({
    required Vector2 position,
    this.radius = 6.0,
    this.isBumper = false,
  }) : super(position: position, size: Vector2.all(radius * 2), anchor: Anchor.center);

  void onHit() {
    _hitFlashTimer = 0.12;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_hitFlashTimer > 0) {
      _hitFlashTimer -= dt;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final isHit = _hitFlashTimer > 0;
    final center = Offset(size.x / 2, size.y / 2);

    if (isBumper) {
      final bumperGlow = Paint()
        ..color = isHit ? Colors.white : EmberColors.accent.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(center, radius * 1.5, bumperGlow);
    }

    final rimPaint = Paint()
      ..color = isHit
          ? Colors.white
          : (isBumper ? const Color(0xFFFFB800) : const Color(0xFF64748B));
    canvas.drawCircle(center, radius, rimPaint);

    final corePaint = Paint()
      ..color = isHit
          ? Colors.white
          : (isBumper ? const Color(0xFFFF8800) : const Color(0xFF1E293B));
    canvas.drawCircle(center, radius * 0.65, corePaint);

    final glintPaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    canvas.drawCircle(center + Offset(-radius * 0.25, -radius * 0.25), radius * 0.2, glintPaint);
  }
}
