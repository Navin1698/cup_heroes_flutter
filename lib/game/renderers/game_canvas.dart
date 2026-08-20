import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/game_constants.dart';
import '../../models/hero_model.dart';
import '../../models/enemy_model.dart';
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

    // 1. Draw Arenas Background
    _drawBackgrounds(canvas);

    // 2. Draw Top Combat Arena
    _drawCombatArena(canvas);

    // 3. Draw Funnel / Separator
    _drawSeparator(canvas);

    // 4. Draw Bottom Pachinko Board & Cup
    _drawPachinkoBoard(canvas);

    // 5. Draw Particles
    _drawParticles(canvas);

    // 6. Draw Floating Combat Texts
    _drawFloatingTexts(canvas);

    canvas.restore();
  }

  void _drawBackgrounds(Canvas canvas) {
    // 1. Top Combat Arena (Stylized Cartoon Stone / Dungeon Floor)
    final arenaRect = const Rect.fromLTWH(0, 0, GameConstants.worldWidth, GameConstants.arenaHeight);
    final arenaGrad = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF28244E), Color(0xFF1E1B38)],
      ).createShader(arenaRect);
    canvas.drawRect(arenaRect, arenaGrad);

    // Arena Floor Tiles (Subtle cartoon pavers)
    final tilePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (double y = 40; y < GameConstants.arenaHeight; y += 45) {
      canvas.drawLine(Offset(0, y), Offset(GameConstants.worldWidth, y), tilePaint);
    }
    for (double x = 40; x < GameConstants.worldWidth; x += 55) {
      canvas.drawLine(Offset(x, 0), Offset(x, GameConstants.arenaHeight), tilePaint);
    }

    // 2. Bottom Pachinko Arena (Translucent Arcade Board with Glass Gloss)
    final pachinkoRect = const Rect.fromLTWH(0, GameConstants.pachinkoTop, GameConstants.worldWidth, GameConstants.pachinkoHeight);
    final pachinkoGrad = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF15132B), Color(0xFF0F0E20)],
      ).createShader(pachinkoRect);
    canvas.drawRect(pachinkoRect, pachinkoGrad);

    // Side Neon Bumpers / Rails
    final leftRail = const Rect.fromLTWH(0, GameConstants.pachinkoTop, 8, GameConstants.pachinkoHeight - 10);
    final rightRail = const Rect.fromLTWH(GameConstants.worldWidth - 8, GameConstants.pachinkoTop, 8, GameConstants.pachinkoHeight - 10);

    final railPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF6C3CE9), Color(0xFF8E44AD), Color(0xFF3498DB)],
      ).createShader(leftRail);

    canvas.drawRRect(RRect.fromRectAndRadius(leftRail, const Radius.circular(4)), railPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(rightRail, const Radius.circular(4)), railPaint);
  }

  void _drawSeparator(Canvas canvas) {
    final sepRect = const Rect.fromLTWH(0, GameConstants.arenaHeight, GameConstants.worldWidth, GameConstants.separatorHeight);
    
    // 3D Metallic Channel Bar
    final barPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF4A4478), Color(0xFF2C274E), Color(0xFF191632)],
      ).createShader(sepRect);
    canvas.drawRect(sepRect, barPaint);

    // Top Highlight & Bottom Shadow
    final topHighlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(0, GameConstants.arenaHeight), Offset(GameConstants.worldWidth, GameConstants.arenaHeight), topHighlight);

    final bottomShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(0, GameConstants.arenaHeight + GameConstants.separatorHeight), Offset(GameConstants.worldWidth, GameConstants.arenaHeight + GameConstants.separatorHeight), bottomShadow);

    // Ball Drop Hopper Openings
    final hopperPaint = Paint()..color = const Color(0xFF0F0E20);
    final hopperBorder = Paint()
      ..color = const Color(0xFF5B36D6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (double x = 35; x < GameConstants.worldWidth - 20; x += 55) {
      final rrect = RRect.fromRectAndRadius(Rect.fromLTWH(x, GameConstants.arenaHeight + 4, 38, 16), const Radius.circular(8));
      canvas.drawRRect(rrect, hopperPaint);
      canvas.drawRRect(rrect, hopperBorder);
    }
  }

  void _drawCombatArena(Canvas canvas) {
    // 1. Draw Hero (The Cup Hero!)
    _drawCupHero(canvas, controller.hero);

    // 2. Draw Enemies
    for (final enemy in controller.enemies) {
      _drawCartoonEnemy(canvas, enemy);
    }

    // 3. Draw Projectiles
    for (final proj in controller.projectiles) {
      _drawProjectile(canvas, proj);
    }
  }

  // -------------------------------------------------------------
  // The Signature "Cup Hero" Character Drawing
  // -------------------------------------------------------------
  void _drawCupHero(Canvas canvas, HeroEntity hero) {
    final pos = hero.position;

    // Drop Shadow
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.4);
    canvas.drawOval(Rect.fromCenter(center: pos + const Offset(0, 24), width: 44, height: 16), shadowPaint);

    // Hit Flash Overlay
    final isHit = hero.hitFlashTimer > 0;

    // 1. Cup Hero Body (A cute white/cream Goblet Cup with eyes)
    final cupBodyRect = Rect.fromCenter(center: pos + const Offset(0, 4), width: 34, height: 32);
    final cupBodyPaint = Paint()
      ..color = isHit ? Colors.white : const Color(0xFFF5F6FA);
    canvas.drawRRect(RRect.fromRectAndRadius(cupBodyRect, const Radius.circular(10)), cupBodyPaint);

    // Cup Base / Stem
    final stemPaint = Paint()..color = isHit ? Colors.white : const Color(0xFFDCDDE1);
    canvas.drawRect(Rect.fromCenter(center: pos + const Offset(0, 18), width: 14, height: 6), stemPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: pos + const Offset(0, 21), width: 26, height: 6), const Radius.circular(3)), stemPaint);

    // 2. Class Helmet / Headwear
    _drawHeroHeadwear(canvas, hero.model.heroClass, pos, hero.model.primaryColor, isHit);

    // 3. Cute Cartoon Eyes on Cup Body
    final eyeWhite = Paint()..color = Colors.black;
    canvas.drawCircle(pos + const Offset(-5, 4), 3.0, eyeWhite);
    canvas.drawCircle(pos + const Offset(5, 4), 3.0, eyeWhite);

    // Eye Sparkles
    final eyeSparkle = Paint()..color = Colors.white;
    canvas.drawCircle(pos + const Offset(-6, 3), 1.2, eyeSparkle);
    canvas.drawCircle(pos + const Offset(4, 3), 1.2, eyeSparkle);

    // 4. Weapon & Shield in Hands
    _drawHeroWeapon(canvas, hero.model.heroClass, pos, hero.attackAnimationTimer > 0);

    // 5. Shield Aura (if active)
    if (hero.currentShield > 0) {
      final shieldAura = Paint()
        ..color = Colors.cyanAccent.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(pos, 28.0, shieldAura);
    }

    // 6. 3D Health Bar with Heart
    _drawStylizedHealthBar(
      canvas,
      center: pos + const Offset(0, -32),
      current: hero.currentHp,
      max: hero.maxHp,
      width: 48,
      shield: hero.currentShield,
    );
  }

  void _drawHeroHeadwear(Canvas canvas, HeroClass heroClass, Offset pos, Color primaryColor, bool isHit) {
    switch (heroClass) {
      case HeroClass.knight:
        // Knight Silver Helmet with Visor & Blue Plume
        final helmPaint = Paint()..color = isHit ? Colors.white : const Color(0xFF718093);
        final visorRect = Rect.fromCenter(center: pos + const Offset(0, -10), width: 34, height: 16);
        canvas.drawRRect(RRect.fromRectAndRadius(visorRect, const Radius.circular(8)), helmPaint);

        // Visor slit
        final slitPaint = Paint()..color = const Color(0xFF2F3640);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: pos + const Offset(0, -9), width: 22, height: 4), const Radius.circular(2)), slitPaint);

        // Blue Knight Crest Plume
        final plumePaint = Paint()..color = primaryColor;
        final plumePath = Path()
          ..moveTo(pos.dx, pos.dy - 18)
          ..quadraticBezierTo(pos.dx - 12, pos.dy - 28, pos.dx, pos.dy - 32)
          ..quadraticBezierTo(pos.dx + 12, pos.dy - 28, pos.dx, pos.dy - 18)
          ..close();
        canvas.drawPath(plumePath, plumePaint);
        break;

      case HeroClass.archer:
        // Green Ranger Hood
        final hoodPaint = Paint()..color = primaryColor;
        final hoodPath = Path()
          ..moveTo(pos.dx - 18, pos.dy - 6)
          ..lineTo(pos.dx, pos.dy - 24)
          ..lineTo(pos.dx + 18, pos.dy - 6)
          ..close();
        canvas.drawPath(hoodPath, hoodPaint);
        break;

      case HeroClass.mage:
        // Wizard Pointy Hat with Gold Buckle
        final hatPaint = Paint()..color = primaryColor;
        final hatPath = Path()
          ..moveTo(pos.dx - 20, pos.dy - 8)
          ..quadraticBezierTo(pos.dx + 6, pos.dy - 24, pos.dx + 12, pos.dy - 34)
          ..lineTo(pos.dx + 20, pos.dy - 8)
          ..close();
        canvas.drawPath(hatPath, hatPaint);
        break;

      case HeroClass.rogue:
        // Ninja Headband with metal plate
        final bandPaint = Paint()..color = const Color(0xFF2F3640);
        canvas.drawRect(Rect.fromCenter(center: pos + const Offset(0, -10), width: 36, height: 8), bandPaint);
        final platePaint = Paint()..color = const Color(0xFFDCDDE1);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: pos + const Offset(0, -10), width: 14, height: 6), const Radius.circular(2)), platePaint);
        break;

      case HeroClass.paladin:
        // Golden Crusader Crown / Halo
        final crownPaint = Paint()..color = Colors.amber;
        canvas.drawCircle(pos + const Offset(0, -22), 10.0, Paint()..color = Colors.amber.withValues(alpha: 0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
        canvas.drawCircle(pos + const Offset(0, -20), 8.0, crownPaint..style = PaintingStyle.stroke..strokeWidth = 3.0);
        break;
    }
  }

  void _drawHeroWeapon(Canvas canvas, HeroClass heroClass, Offset pos, bool isAttacking) {
    if (heroClass == HeroClass.knight || heroClass == HeroClass.paladin) {
      // Sword in Right Hand
      final swordOffset = isAttacking ? const Offset(18, -4) : const Offset(16, 6);
      final bladePaint = Paint()..color = const Color(0xFFDCDDE1)..strokeWidth = 3.5..strokeCap = StrokeCap.round;
      canvas.drawLine(pos + swordOffset, pos + swordOffset + const Offset(14, -14), bladePaint);

      // Sword Crossguard
      final guardPaint = Paint()..color = Colors.amber..strokeWidth = 4.0;
      canvas.drawLine(pos + swordOffset + const Offset(-2, 2), pos + swordOffset + const Offset(4, -4), guardPaint);

      // Shield in Left Hand
      final shieldRect = Rect.fromCenter(center: pos + const Offset(-18, 6), width: 14, height: 20);
      final shieldPaint = Paint()..color = const Color(0xFF3498DB);
      canvas.drawRRect(RRect.fromRectAndRadius(shieldRect, const Radius.circular(6)), shieldPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(shieldRect, const Radius.circular(6)), Paint()..color = Colors.amber..style = PaintingStyle.stroke..strokeWidth = 2.0);

      // Attack Slash Arc
      if (isAttacking) {
        final slashPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Colors.transparent, Colors.white, Colors.amberAccent],
          ).createShader(Rect.fromCircle(center: pos, radius: 36))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.0
          ..strokeCap = StrokeCap.round;
        canvas.drawArc(Rect.fromCircle(center: pos, radius: 34), -0.7, 1.4, false, slashPaint);
      }
    } else {
      // Bow / Wand in Hand
      final weaponPaint = Paint()..color = const Color(0xFFE67E22)..strokeWidth = 3.5..strokeCap = StrokeCap.round;
      canvas.drawArc(Rect.fromCenter(center: pos + const Offset(18, 2), width: 18, height: 26), -1.2, 2.4, false, weaponPaint);
    }
  }

  // -------------------------------------------------------------
  // Cute Cartoon Enemies Drawing
  // -------------------------------------------------------------
  void _drawCartoonEnemy(Canvas canvas, EnemyEntity enemy) {
    final pos = enemy.position;
    final model = enemy.model;
    final isHit = enemy.hitFlashTimer > 0;

    // Drop Shadow
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.35);
    canvas.drawOval(Rect.fromCenter(center: pos + Offset(0, model.size * 0.5), width: model.size * 1.2, height: 12), shadowPaint);

    // Body Paint
    final bodyPaint = Paint()
      ..color = isHit ? Colors.white : model.primaryColor;

    if (model.isBoss) {
      // Boss Red Dragon Glow / Flames
      final bossGlow = Paint()
        ..color = Colors.redAccent.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(pos, model.size * 0.7, bossGlow);
    }

    // Cute Rounded Body
    final bodyRect = Rect.fromCenter(center: pos, width: model.size, height: model.size * 0.95);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, Radius.circular(model.size * 0.4)), bodyPaint);

    // 3D Bottom Shading
    final shadePaint = Paint()
      ..color = model.secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, Radius.circular(model.size * 0.4)), shadePaint);

    // Big Expressive Cartoon Eyes
    final eyePosLeft = pos + Offset(-model.size * 0.2, -model.size * 0.05);
    final eyePosRight = pos + Offset(model.size * 0.15, -model.size * 0.05);
    final eyeRadius = model.size * 0.15;

    // Sclera
    canvas.drawCircle(eyePosLeft, eyeRadius, Paint()..color = Colors.white);
    canvas.drawCircle(eyePosRight, eyeRadius, Paint()..color = Colors.white);

    // Pupils (Angrily looking left at the hero!)
    final pupilRadius = eyeRadius * 0.6;
    canvas.drawCircle(eyePosLeft + Offset(-pupilRadius * 0.4, 0), pupilRadius, Paint()..color = Colors.black);
    canvas.drawCircle(eyePosRight + Offset(-pupilRadius * 0.4, 0), pupilRadius, Paint()..color = Colors.black);

    // Boss Crown & Horns
    if (model.isBoss) {
      final crownPaint = Paint()..color = Colors.amber;
      final crownPath = Path()
        ..moveTo(pos.dx - 16, pos.dy - model.size * 0.55)
        ..lineTo(pos.dx - 22, pos.dy - model.size * 0.9)
        ..lineTo(pos.dx - 8, pos.dy - model.size * 0.7)
        ..lineTo(pos.dx, pos.dy - model.size * 1.0)
        ..lineTo(pos.dx + 8, pos.dy - model.size * 0.7)
        ..lineTo(pos.dx + 22, pos.dy - model.size * 0.9)
        ..lineTo(pos.dx + 16, pos.dy - model.size * 0.55)
        ..close();
      canvas.drawPath(crownPath, crownPaint);
      canvas.drawPath(crownPath, Paint()..color = Colors.orangeAccent..style = PaintingStyle.stroke..strokeWidth = 2.0);
    }

    // Status effect markers
    if (enemy.burnTimer > 0) {
      canvas.drawCircle(pos + const Offset(-10, -16), 5.0, Paint()..color = Colors.deepOrangeAccent..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    }
    if (enemy.chillTimer > 0) {
      canvas.drawCircle(pos + const Offset(10, -16), 5.0, Paint()..color = Colors.cyanAccent..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    }

    // Health Bar
    _drawStylizedHealthBar(
      canvas,
      center: pos + Offset(0, -model.size * 0.6 - 8),
      current: enemy.currentHp,
      max: enemy.maxHp,
      width: model.isBoss ? 74 : 36,
      isBoss: model.isBoss,
    );
  }

  void _drawProjectile(Canvas canvas, Projectile proj) {
    // Glowing Arrow / Magic Energy Bullet
    final glowPaint = Paint()
      ..color = proj.color.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(proj.position, proj.radius * 2.0, glowPaint);

    final corePaint = Paint()..color = Colors.white;
    canvas.drawCircle(proj.position, proj.radius, corePaint);

    // Trail Line
    final angle = atan2(proj.velocity.dy, proj.velocity.dx);
    final trailEnd = proj.position - Offset(cos(angle) * 16, sin(angle) * 16);
    final trailPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.transparent, proj.color],
      ).createShader(Rect.fromPoints(trailEnd, proj.position))
      ..strokeWidth = proj.radius * 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(trailEnd, proj.position, trailPaint);
  }

  void _drawStylizedHealthBar(
    Canvas canvas, {
    required Offset center,
    required int current,
    required int max,
    required double width,
    int shield = 0,
    bool isBoss = false,
  }) {
    const height = 6.0;
    final bgRect = Rect.fromCenter(center: center, width: width, height: height);

    // Dark 3D Background with border
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFF100E22),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFF3F3B6C)..style = PaintingStyle.stroke..strokeWidth = 1.0,
    );

    // HP Fill Gradient
    final hpPct = (current / max).clamp(0.0, 1.0);
    if (hpPct > 0) {
      final hpRect = Rect.fromLTWH(bgRect.left + 1, bgRect.top + 1, (width - 2) * hpPct, height - 2);
      final hpColor = isBoss ? const Color(0xFFE74C3C) : const Color(0xFF2ECC71);
      canvas.drawRRect(
        RRect.fromRectAndRadius(hpRect, const Radius.circular(3)),
        Paint()..color = hpColor,
      );
    }

    // Shield Overlay
    if (shield > 0) {
      final shieldPct = (shield / max).clamp(0.0, 1.0);
      final shieldRect = Rect.fromLTWH(bgRect.left + 1, bgRect.top + 1, (width - 2) * shieldPct, height - 2);
      canvas.drawRRect(
        RRect.fromRectAndRadius(shieldRect, const Radius.circular(3)),
        Paint()..color = Colors.cyanAccent.withValues(alpha: 0.8),
      );
    }
  }

  // -------------------------------------------------------------
  // Pachinko Renderer: Pegs, 3D Multiplier Gates, Balls, The Cup
  // -------------------------------------------------------------
  void _drawPachinkoBoard(Canvas canvas) {
    // 1. Draw Shiny Pegs
    for (final peg in controller.pegs) {
      _drawShinyPeg(canvas, peg);
    }

    // 2. Draw 3D Multiplier Pill Gates
    for (final gate in controller.gates) {
      _draw3DMultiplierGate(canvas, gate);
    }

    // 3. Draw The Stylized Goblet Cup
    _drawTheGobletCup(canvas, controller.cup);

    // 4. Draw Glowing Bouncy Balls
    for (final ball in controller.balls) {
      _drawBouncyBall(canvas, ball);
    }
  }

  void _drawShinyPeg(Canvas canvas, Peg peg) {
    final pos = peg.position;

    // Flash on hit
    if (peg.hitFlashTimer > 0) {
      final glowPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(pos, peg.radius * 2.0, glowPaint);
    }

    // Peg Shadow
    canvas.drawCircle(pos + const Offset(0, 2.5), peg.radius, Paint()..color = Colors.black.withValues(alpha: 0.4));

    // Metallic Rim
    final pegGrad = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE0E0E0), Color(0xFF757575)],
      ).createShader(Rect.fromCircle(center: pos, radius: peg.radius));
    canvas.drawCircle(pos, peg.radius, pegGrad);

    // Inner Rubber Cap (Purple Arcade Style)
    canvas.drawCircle(pos, peg.radius * 0.65, Paint()..color = const Color(0xFF6C3CE9));
    // Specular Highlight
    canvas.drawCircle(pos + const Offset(-1.8, -1.8), peg.radius * 0.25, Paint()..color = Colors.white);
  }

  void _draw3DMultiplierGate(Canvas canvas, MultiplierGate gate) {
    final isMultiply = (gate.type == GateType.multiply);
    final baseColor = isMultiply ? const Color(0xFFFF9F1A) : const Color(0xFF2ECC71);
    final topColor = isMultiply ? const Color(0xFFFFD32A) : const Color(0xFF2BED7E);
    final shadowColor = isMultiply ? const Color(0xFFC0392B) : const Color(0xFF1E8449);

    final rrect = RRect.fromRectAndRadius(gate.bounds, const Radius.circular(12));

    // 3D Drop Shadow
    final shadowBounds = Rect.fromCenter(center: gate.position + const Offset(0, 4), width: gate.width, height: gate.height);
    canvas.drawRRect(RRect.fromRectAndRadius(shadowBounds, const Radius.circular(12)), Paint()..color = shadowColor);

    // Gate Gradient Body
    final gradPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [topColor, baseColor],
      ).createShader(gate.bounds);
    canvas.drawRRect(rrect, gradPaint);

    // Shiny Border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawRRect(rrect, borderPaint);

    // Gate Text (+5 or x2)
    final text = isMultiply ? 'x${gate.value}' : '+${gate.value}';
    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
        shadows: [
          Shadow(color: Colors.black45, offset: Offset(0, 1.5), blurRadius: 2),
        ],
      ),
    );
    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset(gate.position.dx - tp.width / 2, gate.position.dy - tp.height / 2));
  }

  void _drawTheGobletCup(Canvas canvas, CupCatcher cup) {
    final isSuper = cup.superCharge >= cup.maxSuperCharge;
    final cupRect = cup.bounds;

    // Glow Aura on Catch or Super Ready
    if (cup.catchGlowTimer > 0 || isSuper) {
      final glowPaint = Paint()
        ..color = (isSuper ? Colors.amber : Colors.cyanAccent).withValues(alpha: 0.7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
      canvas.drawRRect(RRect.fromRectAndRadius(cupRect, const Radius.circular(16)), glowPaint);
    }

    // 3D Bottom Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cup.x, cup.y + 5), width: cup.width, height: cup.height), const Radius.circular(14)),
      Paint()..color = const Color(0xFF0F0E20),
    );

    // Cup Body (Glossy Arcade Goblet)
    final cupGrad = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isSuper
            ? [const Color(0xFFFFD32A), const Color(0xFFFF9F1A)]
            : [const Color(0xFF5B36D6), const Color(0xFF3F2B96)],
      ).createShader(cupRect);
    canvas.drawRRect(RRect.fromRectAndRadius(cupRect, const Radius.circular(14)), cupGrad);

    // Cup Rim (Golden Catch Zone at the Top)
    final rimRect = Rect.fromLTWH(cupRect.left - 2, cupRect.top - 2, cup.width + 4, 8);
    final rimPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFFD700)],
      ).createShader(rimRect);
    canvas.drawRRect(RRect.fromRectAndRadius(rimRect, const Radius.circular(4)), rimPaint);

    // Inner Energy Fill Gauge
    final fillPct = (cup.superCharge / cup.maxSuperCharge).clamp(0.0, 1.0);
    if (fillPct > 0) {
      final fillRect = Rect.fromLTWH(
        cupRect.left + 6,
        cupRect.bottom - 7,
        (cup.width - 12) * fillPct,
        4,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(fillRect, const Radius.circular(2)),
        Paint()..color = isSuper ? Colors.white : const Color(0xFF2ECC71),
      );
    }

    // Cup Label (CUP or ⚡ SUPER)
    final labelSpan = TextSpan(
      text: isSuper ? '⚡ SUPER ⚡' : 'CUP',
      style: TextStyle(
        color: isSuper ? const Color(0xFF1E1B38) : Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.0,
      ),
    );
    final tp = TextPainter(text: labelSpan, textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset(cup.x - tp.width / 2, cup.y - tp.height / 2));
  }

  void _drawBouncyBall(Canvas canvas, GameBall ball) {
    // Glow Halo
    final glowPaint = Paint()
      ..color = (ball.isSuper ? Colors.amberAccent : Colors.white).withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(ball.position, ball.radius * 1.5, glowPaint);

    // Core Sphere
    final ballGrad = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: ball.isSuper
            ? [Colors.white, const Color(0xFFFFD700), const Color(0xFFE67E22)]
            : [Colors.white, const Color(0xFFE0E0E0), const Color(0xFFBDC3C7)],
      ).createShader(Rect.fromCircle(center: ball.position, radius: ball.radius));
    canvas.drawCircle(ball.position, ball.radius, ballGrad);
  }

  void _drawParticles(Canvas canvas) {
    for (final p in controller.particles.particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p.position, p.currentSize, paint);
    }
  }

  void _drawFloatingTexts(Canvas canvas) {
    for (final ft in controller.floatingTexts) {
      final span = TextSpan(
        text: ft.text,
        style: TextStyle(
          color: ft.color.withValues(alpha: ft.opacity),
          fontSize: ft.fontSize,
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(color: Colors.black.withValues(alpha: ft.opacity), offset: const Offset(1.5, 1.5), blurRadius: 3),
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
