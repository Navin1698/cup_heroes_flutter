import 'dart:math';
import 'package:flutter/material.dart';

enum ParticleShape {
  circle,
  star,
  spark,
  ring,
}

class GameParticle {
  Offset position;
  Offset velocity;
  final Color color;
  final double startSize;
  final ParticleShape shape;
  double life;
  final double maxLife;

  GameParticle({
    required this.position,
    required this.velocity,
    required this.color,
    this.startSize = 4.0,
    this.shape = ParticleShape.circle,
    this.maxLife = 0.5,
  }) : life = maxLife;

  void update(double dt) {
    position += velocity * dt;
    velocity = Offset(velocity.dx * 0.96, velocity.dy * 0.96 + 80.0 * dt); // drag + slight gravity
    life = max(0.0, life - dt);
  }

  bool get isDead => life <= 0;
  double get progress => (life / maxLife).clamp(0.0, 1.0);
  double get currentSize => startSize * progress;
  double get opacity => progress;
}

class ParticleSystem {
  final List<GameParticle> _particles = [];
  final Random _rng = Random();

  List<GameParticle> get particles => _particles;

  void update(double dt) {
    for (int i = _particles.length - 1; i >= 0; i--) {
      _particles[i].update(dt);
      if (_particles[i].isDead) {
        _particles.removeAt(i);
      }
    }
  }

  void spawnBurst(Offset center, Color color, {int count = 12, double speed = 120.0, ParticleShape shape = ParticleShape.circle}) {
    for (int i = 0; i < count; i++) {
      final angle = _rng.nextDouble() * 2 * pi;
      final currentSpeed = (_rng.nextDouble() * 0.7 + 0.3) * speed;
      _particles.add(GameParticle(
        position: center,
        velocity: Offset(cos(angle) * currentSpeed, sin(angle) * currentSpeed),
        color: color,
        startSize: _rng.nextDouble() * 3.5 + 2.5,
        shape: shape,
        maxLife: _rng.nextDouble() * 0.3 + 0.3,
      ));
    }
  }

  void spawnBallCatchStars(Offset center) {
    for (int i = 0; i < 8; i++) {
      final angle = -pi / 2 + (_rng.nextDouble() - 0.5) * 1.5; // upward spray
      final speed = _rng.nextDouble() * 140.0 + 80.0;
      _particles.add(GameParticle(
        position: center,
        velocity: Offset(cos(angle) * speed, sin(angle) * speed),
        color: const Color(0xFFFFD700),
        startSize: 5.0,
        shape: ParticleShape.star,
        maxLife: 0.4,
      ));
    }
  }

  void spawnSuperExplosion(Offset center) {
    for (int i = 0; i < 30; i++) {
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = _rng.nextDouble() * 260.0 + 100.0;
      _particles.add(GameParticle(
        position: center,
        velocity: Offset(cos(angle) * speed, sin(angle) * speed),
        color: [
          const Color(0xFFFF4757),
          const Color(0xFFFFA502),
          const Color(0xFF2ED573),
          const Color(0xFF29D4FF),
        ][_rng.nextInt(4)],
        startSize: 7.0,
        shape: ParticleShape.star,
        maxLife: 0.65,
      ));
    }
  }
}
