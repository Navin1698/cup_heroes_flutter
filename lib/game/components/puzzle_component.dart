import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/constants/color_constants.dart';
import '../emberbound_game.dart';

class PressurePlateComponent extends PositionComponent with HasGameReference<EmberboundGame> {
  final int plateIndex;
  bool isActivated = false;

  PressurePlateComponent({
    required this.plateIndex,
    required Vector2 position,
  }) : super(position: position, size: Vector2(36, 36), anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    if (isActivated) return;

    final player = game.player;
    final dist = (player.position - position).length;

    if (dist <= 24.0) {
      isActivated = true;
      game.onPressurePlateActivated(plateIndex);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final bgPaint = Paint()..color = isActivated ? const Color(0xFF1E3A2F) : const Color(0xFF151A38);
    final borderPaint = Paint()
      ..color = isActivated ? EmberColors.success : EmberColors.surfaceBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final rect = Rect.fromCenter(center: Offset.zero, width: 32, height: 32);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), bgPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), borderPaint);

    // Glowing Rune
    final runePaint = Paint()
      ..color = isActivated ? EmberColors.success : EmberColors.secondary.withValues(alpha: 0.5);
    canvas.drawCircle(Offset.zero, 6, runePaint);
  }
}
