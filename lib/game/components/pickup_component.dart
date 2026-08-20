import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/constants/color_constants.dart';

enum PickupType {
  xp,
  coin,
  gem,
  health,
}

class PickupComponent extends PositionComponent {
  final PickupType type;
  final int value;
  double hoverTimer = 0.0;

  PickupComponent({
    required Vector2 position,
    required this.type,
    required this.value,
  }) : super(position: position, size: Vector2(16, 16), anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    hoverTimer += dt * 3.0;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final offsetY = sin(hoverTimer) * 3.0;

    switch (type) {
      case PickupType.xp:
        // Glowing cyan mana crystal
        final crystalPaint = Paint()..color = EmberColors.secondary;
        final glowPaint = Paint()
          ..color = EmberColors.secondary.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(Offset(0, offsetY), 6, glowPaint);
        canvas.drawRect(Rect.fromCenter(center: Offset(0, offsetY), width: 8, height: 8), crystalPaint);
        break;

      case PickupType.coin:
        // Golden coin
        final coinPaint = Paint()..color = EmberColors.accent;
        canvas.drawCircle(Offset(0, offsetY), 6, coinPaint);
        canvas.drawCircle(Offset(0, offsetY), 4, Paint()..color = Colors.amberAccent);
        break;

      case PickupType.gem:
        // Royal purple gem
        final gemPaint = Paint()..color = EmberColors.epic;
        canvas.drawCircle(Offset(0, offsetY), 6, gemPaint);
        break;

      case PickupType.health:
        // Green healing orb
        final hpPaint = Paint()..color = EmberColors.success;
        canvas.drawCircle(Offset(0, offsetY), 7, hpPaint);
        break;
    }
  }
}
