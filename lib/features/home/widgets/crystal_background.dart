import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/color_constants.dart';

class CrystalBackground extends StatefulWidget {
  const CrystalBackground({super.key});

  @override
  State<CrystalBackground> createState() => _CrystalBackgroundState();
}

class _CrystalBackgroundState extends State<CrystalBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _CrystalBackgroundPainter(progress: _controller.value),
        );
      },
    );
  }
}

class _CrystalBackgroundPainter extends CustomPainter {
  final double progress;

  _CrystalBackgroundPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Deep Space/Crystal Gradient
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          EmberColors.background,
          Color(0xFF0F1532),
          EmberColors.background,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Floating Mana Crystals
    final rng = Random(42);
    for (int i = 0; i < 16; i++) {
      final baseX = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = 0.5 + rng.nextDouble() * 0.5;

      final currentY = (baseY - progress * size.height * speed) % size.height;
      final currentX = baseX + sin(progress * 2 * pi + i) * 12.0;

      final crystalGlow = Paint()
        ..color = (i % 2 == 0 ? EmberColors.secondary : EmberColors.primary).withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      final crystalPaint = Paint()
        ..color = (i % 2 == 0 ? EmberColors.secondary : EmberColors.primary).withValues(alpha: 0.6);

      canvas.drawCircle(Offset(currentX, currentY), 6.0, crystalGlow);
      canvas.drawRect(Rect.fromCenter(center: Offset(currentX, currentY), width: 6, height: 6), crystalPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CrystalBackgroundPainter oldDelegate) => true;
}
