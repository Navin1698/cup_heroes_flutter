import 'package:flutter/material.dart';
import '../../core/constants/game_constants.dart';
import '../game_controller.dart';
import '../physics/ball_physics.dart';
import '../combat/combat_manager.dart';

class GameCanvasPainter extends CustomPainter {
  final GameController controller;

  GameCanvasPainter({required this.controller}) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / GameConstants.worldWidth;
    final scaleY = size.height / GameConstants.worldHeight;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    // 1. Draw Backgrounds
    _drawBackground(canvas);

    // 2. Draw Top Combat Arena
    _drawCombatArena(canvas);

    // 3. Draw Middle Separator
    _drawSeparator(canvas);

    // 4. Draw Bottom Pachinko Board
    _drawPachinkoBoard(canvas);

    // 5. Draw Particles
    _drawParticles(canvas);

    // 6. Draw Floating Combat Texts
    _drawFloatingTexts(canvas);

    canvas.restore();
  }

  void _drawBackground(Canvas canvas) {
    // Top Arena Background
    final arenaPaint = Paint()..color = GameConstants.arenaBg;
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameConstants.worldWidth, GameConstants.arenaHeight), arenaPaint);

    // Arena Floor Grid Lines
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.0;
    for (double y = 40; y < GameConstants.arenaHeight; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(GameConstants.worldWidth, y), linePaint);
    }

    // Bottom Pachinko Background
    final pachinkoPaint = Paint()..color = GameConstants.pachinkoBg;
    canvas.drawRect(
      const Rect.fromLTWH(0, GameConstants.pachinkoTop, GameConstants.worldWidth, GameConstants.pachinkoHeight),
      pachinkoPaint,
    );

    // Pachinko Side Rails (Bouncy Neon Walls)
    final railPaint = Paint()
      ..color = const Color(0xFF6C3CE9).withOpacity(0.4)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      const Offset(4, GameConstants.pachinkoTop),
      const Offset(4, GameConstants.worldHeight - 10),
      railPaint,
    );
    canvas.drawLine(
      const Offset(GameConstants.worldWidth - 4, GameConstants.pachinkoTop),
      const Offset(GameConstants.worldWidth - 4, GameConstants.worldHeight - 10),
      railPaint,
    );
  }

  void _drawSeparator(Canvas canvas) {
    final sepRect = const Rect.fromLTWH(0, GameConstants.arenaHeight, GameConstants.worldWidth, GameConstants.separatorHeight);
    
    // Gradient metallic bar
    final gradPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF2C274E), Color(0xFF4B4480), Color(0xFF2C274E)],
      ).createShader(sepRect);
    canvas.drawRect(sepRect, gradPaint);

    // Drop Zone Slots
    final slotPaint = Paint()..color = Colors.black.withOpacity(0.5);
    for (double x = 40; x < GameConstants.worldWidth - 30; x += 60) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, GameConstants.arenaHeight + 5, 36, 14), const Radius.circular(7)),
        slotPaint,
      );
    }
  }

  void _drawCombatArena(Canvas canvas) {
    // 1. Draw Hero
    _drawHero(canvas, controller.hero);

    // 2. Draw Enemies
    for (final enemy in controller.enemies) {
      _drawEnemy(canvas, enemy);
    }

    // 3. Draw Projectiles
    for (final proj in controller.projectiles) {
      _drawProjectile(canvas, proj);
    }
  }

  void _drawHero(Canvas canvas, HeroEntity hero) {
    final pos = hero.position;

    // Hero Shadow
    final shadowPaint = Paint()..color = Colors.black.withOpacity(0.35);
    canvas.drawOval(Rect.fromCenter(center: pos + const Offset(0, 22), width: 38, height: 14), shadowPaint);

    // Hero Body / Aura
    final bodyPaint = Paint()
      ..color = (hero.hitFlashTimer > 0) ? Colors.white : hero.model.primaryColor;
    canvas.drawCircle(pos, 20.0, bodyPaint);

    // Hero Inner Ring / Icon
    final ringPaint = Paint()
      ..color = hero.model.secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawCircle(pos, 16.0, ringPaint);

    // Attack Swing Effect
    if (hero.attackAnimationTimer > 0) {
      final slashPaint = Paint()
        ..color = Colors.amberAccent.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: pos, radius: 30),
        -0.8,
        1.6,
        false,
        slashPaint,
      );
    }

    // Shield Aura
    if (hero.currentShield > 0) {
      final shieldPaint = Paint()
        ..color = Colors.cyanAccent.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawCircle(pos, 25.0, shieldPaint);
    }

    // HP Bar
    _drawHealthBar(
      canvas,
      center: pos + const Offset(0, -32),
      current: hero.currentHp,
      max: hero.maxHp,
      width: 44,
      shield: hero.currentShield,
    );
  }

  void _drawEnemy(Canvas canvas, EnemyEntity enemy) {
    final pos = enemy.position;
    final model = enemy.model;

    // Enemy Shadow
    final shadowPaint = Paint()..color = Colors.black.withOpacity(0.35);
    canvas.drawOval(Rect.fromCenter(center: pos + Offset(0, model.size * 0.5), width: model.size * 1.1, height: 10), shadowPaint);

    // Body
    final bodyPaint = Paint()
      ..color = (enemy.hitFlashTimer > 0) ? Colors.white : model.primaryColor;
    
    if (model.isBoss) {
      // Boss Hexagon / Glowing Frame
      final bossGlowPaint = Paint()
        ..color = Colors.redAccent.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(pos, model.size * 0.65, bossGlowPaint);
    }

    canvas.drawCircle(pos, model.size * 0.5, bodyPaint);

    // Inner detail
    final innerPaint = Paint()
      ..color = model.secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(pos, model.size * 0.35, innerPaint);

    // Boss Crown / Indicator
    if (model.isBoss) {
      final crownPaint = Paint()..color = Colors.amber;
      final path = Path()
        ..moveTo(pos.dx - 12, pos.dy - model.size * 0.6)
        ..lineTo(pos.dx - 16, pos.dy - model.size * 0.9)
        ..lineTo(pos.dx - 6, pos.dy - model.size * 0.75)
        ..lineTo(pos.dx, pos.dy - model.size * 0.95)
        ..lineTo(pos.dx + 6, pos.dy - model.size * 0.75)
        ..lineTo(pos.dx + 16, pos.dy - model.size * 0.9)
        ..lineTo(pos.dx + 12, pos.dy - model.size * 0.6)
        ..close();
      canvas.drawPath(path, crownPaint);
    }

    // Status effect icons / indicators
    if (enemy.burnTimer > 0) {
      final firePaint = Paint()..color = Colors.deepOrangeAccent;
      canvas.drawCircle(pos + const Offset(-8, -12), 4.0, firePaint);
    }
    if (enemy.chillTimer > 0) {
      final icePaint = Paint()..color = Colors.lightBlueAccent;
      canvas.drawCircle(pos + const Offset(8, -12), 4.0, icePaint);
    }

    // HP Bar
    _drawHealthBar(
      canvas,
      center: pos + Offset(0, -model.size * 0.6 - 8),
      current: enemy.currentHp,
      max: enemy.maxHp,
      width: model.isBoss ? 70 : 34,
      isBoss: model.isBoss,
    );
  }

  void _drawProjectile(Canvas canvas, Projectile proj) {
    final glowPaint = Paint()
      ..color = proj.color.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(proj.position, proj.radius * 1.6, glowPaint);

    final corePaint = Paint()..color = proj.color;
    canvas.drawCircle(proj.position, proj.radius, corePaint);
  }

  void _drawHealthBar(
    Canvas canvas, {
    required Offset center,
    required int current,
    required int max,
    required double width,
    int shield = 0,
    bool isBoss = false,
  }) {
    const height = 5.0;
    final bgRect = Rect.fromCenter(center: center, width: width, height: height);

    // Background
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(3)),
      Paint()..color = Colors.black.withOpacity(0.6),
    );

    // HP Fill
    final hpPct = (current / max).clamp(0.0, 1.0);
    if (hpPct > 0) {
      final hpRect = Rect.fromLTWH(bgRect.left, bgRect.top, width * hpPct, height);
      canvas.drawRRect(
        RRect.fromRectAndRadius(hpRect, const Radius.circular(3)),
        Paint()..color = isBoss ? Colors.purpleAccent : GameConstants.hpGreen,
      );
    }

    // Shield overlay
    if (shield > 0) {
      final shieldPct = (shield / max).clamp(0.0, 1.0);
      final shieldRect = Rect.fromLTWH(bgRect.left, bgRect.top, width * shieldPct, height);
      canvas.drawRRect(
        RRect.fromRectAndRadius(shieldRect, const Radius.circular(3)),
        Paint()..color = Colors.cyanAccent.withOpacity(0.8),
      );
    }
  }

  // -------------------------------------------------------------
  // Pachinko Renderer
  // -------------------------------------------------------------
  void _drawPachinkoBoard(Canvas canvas) {
    // 1. Draw Pegs
    for (final peg in controller.pegs) {
      _drawPeg(canvas, peg);
    }

    // 2. Draw Multiplier Gates
    for (final gate in controller.gates) {
      _drawGate(canvas, gate);
    }

    // 3. Draw Sliding Cup
    _drawCup(canvas, controller.cup);

    // 4. Draw Balls
    for (final ball in controller.balls) {
      _drawBall(canvas, ball);
    }
  }

  void _drawPeg(Canvas canvas, Peg peg) {
    // Peg Glow on hit
    if (peg.hitFlashTimer > 0) {
      final glowPaint = Paint()
        ..color = Colors.white.withOpacity(0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(peg.position, peg.radius * 1.5, glowPaint);
    }

    // Peg Body
    final pegPaint = Paint()
      ..color = (peg.hitFlashTimer > 0) ? Colors.white : const Color(0xFF7E57C2);
    canvas.drawCircle(peg.position, peg.radius, pegPaint);

    // Peg Center Dot
    final centerPaint = Paint()..color = const Color(0xFFEDE7F6);
    canvas.drawCircle(peg.position, peg.radius * 0.45, centerPaint);
  }

  void _drawGate(Canvas canvas, MultiplierGate gate) {
    final isMultiply = (gate.type == GateType.multiply);
    final color = isMultiply ? GameConstants.gateMultiplyColor : GameConstants.gateAddColor;
    final rrect = RRect.fromRectAndRadius(gate.bounds, const Radius.circular(8));

    // Outer Glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawRRect(rrect, glowPaint);

    // Gate Background
    final bgPaint = Paint()..color = color.withOpacity(0.25);
    canvas.drawRRect(rrect, bgPaint);

    // Gate Border
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(rrect, borderPaint);

    // Gate Text (e.g. +5 or x2)
    final text = isMultiply ? 'x${gate.value}' : '+${gate.value}';
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        shadows: [
          Shadow(color: color, blurRadius: 4),
        ],
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(gate.position.dx - textPainter.width / 2, gate.position.dy - textPainter.height / 2),
    );
  }

  void _drawCup(Canvas canvas, CupCatcher cup) {
    final rrect = RRect.fromRectAndRadius(cup.bounds, const Radius.circular(12));

    // Glow on catch
    if (cup.catchGlowTimer > 0) {
      final glowPaint = Paint()
        ..color = Colors.amberAccent.withOpacity(0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawRRect(rrect, glowPaint);
    }

    // Cup Body Gradient
    final gradPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF3F3B6C), Color(0xFF1E1B38)],
      ).createShader(cup.bounds);
    canvas.drawRRect(rrect, gradPaint);

    // Cup Super Meter Fill (Bottom layer)
    final fillPct = (cup.superCharge / cup.maxSuperCharge).clamp(0.0, 1.0);
    if (fillPct > 0) {
      final fillRect = Rect.fromLTWH(
        cup.bounds.left + 4,
        cup.bounds.bottom - 8,
        (cup.width - 8) * fillPct,
        4,
      );
      final meterPaint = Paint()
        ..color = (fillPct >= 1.0) ? Colors.amberAccent : GameConstants.energyColor;
      canvas.drawRRect(RRect.fromRectAndRadius(fillRect, const Radius.circular(2)), meterPaint);
    }

    // Cup Rim Glow Border
    final borderPaint = Paint()
      ..color = (cup.superCharge >= cup.maxSuperCharge) ? Colors.amberAccent : const Color(0xFF6C3CE9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(rrect, borderPaint);

    // Cup Icon / Catch Basket Label
    final iconSpan = TextSpan(
      text: (cup.superCharge >= cup.maxSuperCharge) ? '⚡ READY ⚡' : 'CUP',
      style: TextStyle(
        color: (cup.superCharge >= cup.maxSuperCharge) ? Colors.amberAccent : Colors.white70,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
    final tp = TextPainter(text: iconSpan, textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset(cup.x - tp.width / 2, cup.y - tp.height / 2 - 2));
  }

  void _drawBall(Canvas canvas, GameBall ball) {
    // Glow
    final glowPaint = Paint()
      ..color = (ball.isSuper ? Colors.amber : ball.color).withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(ball.position, ball.radius * 1.3, glowPaint);

    // Core
    final ballPaint = Paint()..color = ball.isSuper ? const Color(0xFFFFD700) : ball.color;
    canvas.drawCircle(ball.position, ball.radius, ballPaint);
  }

  void _drawParticles(Canvas canvas) {
    for (final p in controller.particles.particles) {
      final paint = Paint()
        ..color = p.color.withOpacity(p.opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p.position, p.currentSize, paint);
    }
  }

  void _drawFloatingTexts(Canvas canvas) {
    for (final ft in controller.floatingTexts) {
      final span = TextSpan(
        text: ft.text,
        style: TextStyle(
          color: ft.color.withOpacity(ft.opacity),
          fontSize: ft.fontSize,
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(color: Colors.black.withOpacity(ft.opacity), offset: const Offset(1, 1), blurRadius: 2),
          ],
        ),
      );
      final tp = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, ft.position);
    }
  }

  @override
  bool shouldRepaint(covariant GameCanvasPainter oldDelegate) => true;
}
