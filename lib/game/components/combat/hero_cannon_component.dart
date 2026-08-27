import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../models/hero_definition.dart';
import 'hero_projectile_component.dart';
import 'wave_monster_component.dart';

class HeroCannonComponent extends PositionComponent {
  final HeroDefinition hero;
  final void Function(HeroProjectileComponent proj)? onSpawnProjectile;

  double _attackAnimTimer = 0.0;
  final Random _rng = Random();

  HeroCannonComponent({
    required this.hero,
    required Vector2 position,
    this.onSpawnProjectile,
  }) : super(position: position, size: Vector2(52, 52), anchor: Anchor.center);

  void fireProjectiles(int count, {bool isGold = false, List<WaveMonsterComponent>? targets}) {
    _attackAnimTimer = 0.2;

    for (int i = 0; i < count; i++) {
      Future.delayed(Duration(milliseconds: i * 35), () {
        if (!isMounted) return;

        // Aim towards nearest monster if available, otherwise straight up
        Vector2 targetDir = Vector2(0, -1);
        if (targets != null && targets.isNotEmpty) {
          final closest = targets.first;
          final diff = (closest.position - position).normalized();
          targetDir = diff;
        }

        // Add spread
        final spreadAngle = (_rng.nextDouble() - 0.5) * 0.35;
        final rad = atan2(targetDir.y, targetDir.x) + spreadAngle;
        final finalDir = Vector2(cos(rad), sin(rad));

        final proj = HeroProjectileComponent(
          position: position.clone() + Vector2(0, -15),
          direction: finalDir,
          speed: 480.0,
          damage: (hero.baseAttack * (isGold ? 2.5 : 1.0)).round(),
          isGold: isGold,
        );

        onSpawnProjectile?.call(proj);
      });
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_attackAnimTimer > 0) {
      _attackAnimTimer -= dt;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final isAttacking = _attackAnimTimer > 0;
    final recoilY = isAttacking ? 4.0 : 0.0;

    // 1. Hero Pedestal Ring
    canvas.drawCircle(
      const Offset(0, 18),
      22.0,
      Paint()..color = Colors.black.withValues(alpha: 0.4),
    );

    final basePaint = Paint()
      ..color = hero.primaryColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(const Offset(0, 18), 20.0, basePaint);

    // 2. Hero Tunic & Cape
    final capePaint = Paint()..color = hero.primaryColor;
    final capePath = Path()
      ..moveTo(-12, 4 + recoilY)
      ..lineTo(12, 4 + recoilY)
      ..lineTo(16, 22 + recoilY)
      ..lineTo(-16, 22 + recoilY)
      ..close();
    canvas.drawPath(capePath, capePaint);

    // 3. Hero Armor & Cup Crest
    final armorPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, 4 + recoilY), width: 26, height: 26),
        const Radius.circular(8),
      ),
      armorPaint,
    );

    // Cup Crest Emblem (Golden Trophy on chest)
    final crestPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(Offset(0, 2 + recoilY), 4.5, crestPaint);

    // 4. Hero Head & Helmet
    final helmetPaint = Paint()..color = const Color(0xFF334155);
    canvas.drawCircle(Offset(0, -10 + recoilY), 10.0, helmetPaint);

    final visorPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawRect(Rect.fromCenter(center: Offset(0, -10 + recoilY), width: 12, height: 4), visorPaint);

    // 5. Glowing Weapon Glow
    final weaponGlow = Paint()
      ..color = isAttacking ? const Color(0xFFFFD700) : hero.primaryColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(16, -2 + recoilY), 8.0, weaponGlow);
  }
}
