import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/game_constants.dart';

enum GateType {
  add,
  multiply,
}

class MultiplierGate {
  final String id;
  Offset position;
  final double width;
  final double height;
  final GateType type;
  int value;
  final bool isMoving;
  double moveSpeed;
  int moveDirection; // 1 = right, -1 = left
  final double minX;
  final double maxX;

  MultiplierGate({
    required this.id,
    required this.position,
    this.width = 64.0,
    this.height = 20.0,
    required this.type,
    required this.value,
    this.isMoving = false,
    this.moveSpeed = 40.0,
    this.moveDirection = 1,
    this.minX = 40.0,
    this.maxX = 360.0,
  });

  Rect get bounds => Rect.fromCenter(
        center: position,
        width: width,
        height: height,
      );

  void update(double dt) {
    if (!isMoving) return;
    double newX = position.dx + moveDirection * moveSpeed * dt;
    if (newX <= minX + width / 2) {
      newX = minX + width / 2;
      moveDirection = 1;
    } else if (newX >= maxX - width / 2) {
      newX = maxX - width / 2;
      moveDirection = -1;
    }
    position = Offset(newX, position.dy);
  }
}

class Peg {
  final Offset position;
  final double radius;
  double hitFlashTimer = 0.0; // Glow timer when hit

  Peg({
    required this.position,
    this.radius = GameConstants.pegRadius,
  });

  void triggerHit() {
    hitFlashTimer = 0.2;
  }

  void update(double dt) {
    if (hitFlashTimer > 0) {
      hitFlashTimer = max(0.0, hitFlashTimer - dt);
    }
  }
}

class GameBall {
  Offset position;
  Offset velocity;
  final double radius;
  final Color color;
  final bool isSuper;
  final Set<String> passedGateIds = {};
  bool isCaught = false;
  bool isExpired = false;

  GameBall({
    required this.position,
    required this.velocity,
    this.radius = GameConstants.ballRadius,
    this.color = Colors.white,
    this.isSuper = false,
  });

  void updatePhysics(double dt, double bounceMultiplier) {
    // Apply gravity
    velocity = Offset(
      velocity.dx * 0.998, // slight air drag
      (velocity.dy + GameConstants.gravity * dt).clamp(-GameConstants.maxBallVelocity, GameConstants.maxBallVelocity),
    );

    position += velocity * dt;
  }
}

class CupCatcher {
  double x; // Center X
  double y; // Center Y
  double width;
  double height;
  double superCharge = 0.0;
  final double maxSuperCharge = 100.0;
  double catchGlowTimer = 0.0;

  CupCatcher({
    required this.x,
    required this.y,
    this.width = GameConstants.cupWidth,
    this.height = GameConstants.cupHeight,
  });

  Rect get bounds => Rect.fromCenter(
        center: Offset(x, y),
        width: width,
        height: height,
      );

  Rect get catchArea => Rect.fromLTWH(
        x - width * 0.45,
        y - height * 0.5,
        width * 0.9,
        height * 0.6,
      );

  void triggerCatch(double chargeAmount) {
    superCharge = (superCharge + chargeAmount).clamp(0.0, maxSuperCharge);
    catchGlowTimer = 0.15;
  }

  void update(double dt) {
    if (catchGlowTimer > 0) {
      catchGlowTimer = max(0.0, catchGlowTimer - dt);
    }
  }

  void resetSuper() {
    superCharge = 0.0;
  }
}
