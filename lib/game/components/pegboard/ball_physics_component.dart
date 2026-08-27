import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../cups/cup_collector_component.dart';
import 'multiplier_gate_component.dart';
import 'peg_component.dart';

class BallPhysicsComponent extends PositionComponent {
  Vector2 velocity;
  final double radius;
  final bool isGold;
  final void Function(BallPhysicsComponent ball)? onCollected;
  final void Function(MultiplierGateComponent gate, Vector2 pos, Vector2 vel, bool isGold)? onHitGate;

  final Set<MultiplierGateComponent> _passedGates = {};
  bool isCollected = false;
  double _lifeTimer = 0.0;

  BallPhysicsComponent({
    required Vector2 position,
    Vector2? velocity,
    this.radius = 5.5,
    this.isGold = false,
    this.onCollected,
    this.onHitGate,
  })  : velocity = velocity ?? Vector2.zero(),
        super(position: position, size: Vector2.all(radius * 2), anchor: Anchor.center);

  void updatePhysics(double dt, List<PegComponent> pegs, List<MultiplierGateComponent> gates, CupCollectorComponent cup) {
    if (isCollected) return;

    _lifeTimer += dt;
    if (_lifeTimer > 15.0 || position.y > 520.0) {
      isCollected = true;
      removeFromParent();
      return;
    }

    // 1. Gravity acceleration
    velocity.y += 420.0 * dt;

    // 2. Air resistance
    velocity.x *= 0.995;

    // 3. Move
    position += velocity * dt;

    // 4. Wall Collisions (Left wall at x = 15, Right wall at x = 365)
    if (position.x - radius < 15) {
      position.x = 15 + radius;
      velocity.x = -velocity.x * 0.7;
    } else if (position.x + radius > 365) {
      position.x = 365 - radius;
      velocity.x = -velocity.x * 0.7;
    }

    // 5. Funnel Ramps at the bottom (funneling toward cup)
    if (position.y > 380 && position.y < 450) {
      if (position.x < 130) {
        velocity.x += 120.0 * dt;
      } else if (position.x > 250) {
        velocity.x -= 120.0 * dt;
      }
    }

    // 6. Peg Collisions
    for (final peg in pegs) {
      final diff = position - peg.position;
      final minDist = radius + peg.radius;
      final distSq = diff.length2;

      if (distSq < minDist * minDist) {
        final dist = max(0.001, sqrt(distSq));
        final normal = diff / dist;

        // Position correction
        position = peg.position + normal * (minDist + 0.5);

        // Elastic reflection with randomness
        final dot = velocity.dot(normal);
        if (dot < 0) {
          final restitution = peg.isBumper ? 0.9 : 0.65;
          velocity = (velocity - normal * (2 * dot)) * restitution;
          // Add small lateral wobble
          velocity.x += (Random().nextDouble() - 0.5) * 40.0;
        }

        peg.onHit();
      }
    }

    // 7. Gate Collisions
    for (final gate in gates) {
      if (_passedGates.contains(gate)) continue;

      final gateRect = Rect.fromCenter(
        center: Offset(gate.position.x, gate.position.y),
        width: gate.size.x,
        height: gate.size.y,
      );

      if (gateRect.contains(Offset(position.x, position.y))) {
        _passedGates.add(gate);
        gate.triggerHit();
        onHitGate?.call(gate, position.clone(), velocity.clone(), isGold);
      }
    }

    // 8. Cup Collection
    final cupRect = Rect.fromCenter(
      center: Offset(cup.position.x, cup.position.y),
      width: cup.size.x,
      height: cup.size.y,
    );

    if (cupRect.contains(Offset(position.x, position.y))) {
      isCollected = true;
      cup.collectBall(isGold: isGold);
      onCollected?.call(this);
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center = Offset(size.x / 2, size.y / 2);
    final primaryColor = isGold ? const Color(0xFFFFD700) : const Color(0xFF00E5FF);
    final glowColor = isGold ? const Color(0xFFFF9900) : const Color(0xFF0088FF);

    // 1. Neon Glow
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(center, radius * 1.6, glowPaint);

    // 2. Ball Core
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          primaryColor,
          glowColor,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, corePaint);

    // 3. Specular Highlight
    final glintPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawCircle(center + Offset(-radius * 0.35, -radius * 0.35), radius * 0.25, glintPaint);
  }
}
