import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'wave_monster_component.dart';

class HeroProjectileComponent extends PositionComponent {
  final Vector2 direction;
  final double speed;
  final int damage;
  final bool isGold;
  final void Function(WaveMonsterComponent monster, int dmg, bool isGold)? onHitEnemy;

  double _lifeTimer = 0.0;

  HeroProjectileComponent({
    required Vector2 position,
    required this.direction,
    this.speed = 480.0,
    required this.damage,
    this.isGold = false,
    this.onHitEnemy,
  }) : super(position: position, size: Vector2(14, 22), anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    _lifeTimer += dt;

    position += direction * speed * dt;

    // Despawn if out of upper screen
    if (position.y < -30 || position.x < -30 || position.x > 500 || _lifeTimer > 4.0) {
      removeFromParent();
    }
  }

  void hit(WaveMonsterComponent monster) {
    onHitEnemy?.call(monster, damage, isGold);
    monster.takeDamage(damage, isCrit: isGold);
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center = Offset.zero;
    final color = isGold ? const Color(0xFFFFD700) : const Color(0xFF00E5FF);
    final glowColor = isGold ? const Color(0xFFFF8800) : const Color(0xFF0088FF);

    // Glowing Trail
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, 8.0, glowPaint);

    // Energy Bolt
    final boltPaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 6, height: 16),
        const Radius.circular(3),
      ),
      boltPaint,
    );

    final outlinePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 8, height: 18),
        const Radius.circular(4),
      ),
      outlinePaint,
    );
  }
}
