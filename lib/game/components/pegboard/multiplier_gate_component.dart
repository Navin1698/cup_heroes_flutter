import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum GateOperation { add, multiply }

class MultiplierGateComponent extends PositionComponent {
  GateOperation operation;
  int value;
  double moveAmplitude;
  double moveSpeed;
  double initialPhase;
  final double initialX;
  final void Function(Vector2 position, Vector2 velocity, bool isGold)? onSpawnBall;

  double _timer = 0.0;
  double _hitFlashTimer = 0.0;

  MultiplierGateComponent({
    required Vector2 position,
    double width = 80.0,
    double height = 24.0,
    required this.operation,
    required this.value,
    this.moveAmplitude = 60.0,
    this.moveSpeed = 1.8,
    this.initialPhase = 0.0,
    this.onSpawnBall,
  })  : initialX = position.x,
        super(position: position, size: Vector2(width, height), anchor: Anchor.center) {
    _timer = initialPhase;
  }

  void updateConfig({required GateOperation op, required int val, double? newWidth}) {
    operation = op;
    value = val;
    if (newWidth != null) {
      size.x = newWidth;
    }
  }

  void triggerHit() {
    _hitFlashTimer = 0.15;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt * moveSpeed;

    if (_hitFlashTimer > 0) {
      _hitFlashTimer -= dt;
    }

    if (moveAmplitude > 0) {
      position.x = initialX + sin(_timer) * moveAmplitude;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final isHit = _hitFlashTimer > 0;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));

    final isMultiply = operation == GateOperation.multiply;
    final primaryColor = isMultiply ? const Color(0xFFFF9900) : const Color(0xFF00FF88);
    final glowColor = isMultiply ? const Color(0xFFFF5500) : const Color(0xFF00E5FF);

    // 1. Neon Outer Glow
    final glowPaint = Paint()
      ..color = (isHit ? Colors.white : glowColor).withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRRect(rrect, glowPaint);

    // 2. Glass Background
    final bgPaint = Paint()
      ..color = (isHit ? Colors.white.withValues(alpha: 0.3) : const Color(0xFF0C1428).withValues(alpha: 0.85));
    canvas.drawRRect(rrect, bgPaint);

    // 3. Neon Border Frame
    final borderPaint = Paint()
      ..color = isHit ? Colors.white : primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(rrect, borderPaint);

    // 4. Multiplier Text (+5 or x2)
    final label = isMultiply ? 'x' : '+';
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: isHit ? Colors.white : primaryColor,
          fontWeight: FontWeight.w900,
          fontSize: 13,
          letterSpacing: 0.5,
          shadows: [
            Shadow(
              color: glowColor,
              blurRadius: 4,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2),
    );
  }
}
