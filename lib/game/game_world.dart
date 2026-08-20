import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/constants/color_constants.dart';
import '../../core/constants/game_constants.dart';

class GameWorld extends World {
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 1. Procedural Whispering Meadow Ground (Lush Fantasy Indigo & Emerald Grass)
    final bgRect = const Rect.fromLTWH(0, 0, GameConstants.gameWorldWidth, GameConstants.gameWorldHeight);
    final bgGrad = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0F1E2A),
          Color(0xFF142738),
          Color(0xFF0C1424),
        ],
      ).createShader(bgRect);
    canvas.drawRect(bgRect, bgGrad);

    // Subtle Grass / Paver Grid
    final gridPaint = Paint()
      ..color = EmberColors.success.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (double x = 0; x < GameConstants.gameWorldWidth; x += 80) {
      canvas.drawLine(Offset(x, 0), Offset(x, GameConstants.gameWorldHeight), gridPaint);
    }
    for (double y = 0; y < GameConstants.gameWorldHeight; y += 80) {
      canvas.drawLine(Offset(0, y), Offset(GameConstants.gameWorldWidth, y), gridPaint);
    }

    // World Boundary Barrier (Crystal Border)
    final borderPaint = Paint()
      ..color = EmberColors.secondary.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawRect(bgRect, borderPaint);

    // Decorative Mana Crystals around the arena
    final crystalPaint = Paint()..color = EmberColors.secondary;
    final crystalGlow = Paint()
      ..color = EmberColors.secondary.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final crystalNodes = [
      const Offset(150, 200),
      const Offset(950, 250),
      const Offset(200, 1300),
      const Offset(1000, 1350),
      const Offset(600, 800),
    ];

    for (final node in crystalNodes) {
      canvas.drawCircle(node, 18.0, crystalGlow);
      final path = Path()
        ..moveTo(node.dx, node.dy - 16)
        ..lineTo(node.dx + 10, node.dy)
        ..lineTo(node.dx, node.dy + 16)
        ..lineTo(node.dx - 10, node.dy)
        ..close();
      canvas.drawPath(path, crystalPaint);
    }
  }
}
