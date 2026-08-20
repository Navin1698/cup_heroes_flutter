import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DamageNumberComponent extends PositionComponent {
  final String text;
  final Color color;
  final bool isCritical;
  double lifeTime = 0.75;
  double opacity = 1.0;
  Vector2 velocity = Vector2(0, -60);

  DamageNumberComponent({
    required Vector2 position,
    required this.text,
    required this.color,
    this.isCritical = false,
  }) : super(position: position) {
    final rng = Random();
    velocity.x = (rng.nextDouble() - 0.5) * 50;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    velocity.y += 40 * dt; // gravity deceleration
    lifeTime -= dt;

    if (lifeTime <= 0.3) {
      opacity = (lifeTime / 0.3).clamp(0.0, 1.0);
    }

    if (lifeTime <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final span = TextSpan(
      text: isCritical ? 'CRIT! $text' : text,
      style: TextStyle(
        color: color.withValues(alpha: opacity),
        fontSize: isCritical ? 16 : 12,
        fontWeight: FontWeight.w900,
        shadows: [
          Shadow(color: Colors.black.withValues(alpha: opacity), offset: const Offset(1.5, 1.5), blurRadius: 2),
        ],
      ),
    );

    final tp = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
  }
}
