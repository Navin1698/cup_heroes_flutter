import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/constants/color_constants.dart';

class SlashEffectComponent extends PositionComponent {
  final double radius;
  final double startAngle;
  final double sweepAngle;
  final Color color;
  final bool isHeavy;
  double lifeTime;
  final double totalLifeTime;

  SlashEffectComponent({
    required Vector2 position,
    this.radius = 48.0,
    this.startAngle = -0.8,
    this.sweepAngle = 1.6,
    this.color = EmberColors.secondary,
    this.isHeavy = false,
    this.totalLifeTime = 0.22,
  })  : lifeTime = totalLifeTime,
        super(position: position, size: Vector2.all(radius * 2), anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    lifeTime -= dt;
    if (lifeTime <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final progress = (1.0 - (lifeTime / totalLifeTime)).clamp(0.0, 1.0);
    final alpha = (lifeTime / totalLifeTime).clamp(0.0, 1.0);

    final slashPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          isHeavy ? EmberColors.accent : Colors.white,
          color.withValues(alpha: alpha),
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = (isHeavy ? 10.0 : 6.0) * (1.0 - progress * 0.4)
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: radius * (0.8 + progress * 0.3)),
      startAngle,
      sweepAngle,
      false,
      slashPaint,
    );
  }
}
