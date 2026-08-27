import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class CupCollectorComponent extends PositionComponent {
  final String label;
  final void Function(int count, bool isGold)? onBallCollected;

  int collectedCount = 0;
  double _bounceEffectTimer = 0.0;

  CupCollectorComponent({
    required Vector2 position,
    double width = 110.0,
    double height = 50.0,
    this.label = 'HERO CUP',
    this.onBallCollected,
  }) : super(position: position, size: Vector2(width, height), anchor: Anchor.center);

  void collectBall({bool isGold = false}) {
    collectedCount++;
    _bounceEffectTimer = 0.15;
    onBallCollected?.call(1, isGold);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_bounceEffectTimer > 0) {
      _bounceEffectTimer -= dt;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final isExcited = _bounceEffectTimer > 0;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    // 1. Ornate Cup Outer Glow
    final glowPaint = Paint()
      ..color = (isExcited ? const Color(0xFFFFD700) : const Color(0xFF00E5FF)).withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRect(rect, glowPaint);

    // 2. Cup Body Gradient
    final cupPath = Path()
      ..moveTo(0, 0)
      ..lineTo(6, size.y)
      ..lineTo(size.x - 6, size.y)
      ..lineTo(size.x, 0)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF1E293B).withValues(alpha: 0.85),
          const Color(0xFF0F172A).withValues(alpha: 0.95),
        ],
      ).createShader(rect);
    canvas.drawPath(cupPath, fillPaint);

    // 3. Golden Rim Borders
    final rimPaint = Paint()
      ..color = isExcited ? const Color(0xFFFFEA79) : const Color(0xFFFFB800)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isExcited ? 3.0 : 2.0;
    canvas.drawPath(cupPath, rimPaint);

    // 4. Hero Cup Emblem & Count
    final textPainter = TextPainter(
      text: TextSpan(
        text: '\n🏆 ',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 10,
          height: 1.2,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2),
    );
  }
}
