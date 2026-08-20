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

  // Animation pulse
  double scaleFactor = 1.0;

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
        width: width * scaleFactor,
        height: height * scaleFactor,
      );

  void triggerHit() {
    scaleFactor = 1.25;
  }

  void update(double dt) {
    if (scaleFactor > 1.0) {
      scaleFactor = max(1.0, scaleFactor - dt * 2.0);
    }

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
  double hitFlashTimer = 0.0;
  double scaleX = 1.0;
  double scaleY = 1.0;

  Peg({
    required this.position,
    this.radius = GameConstants.pegRadius,
  });

  void triggerHit() {
    hitFlashTimer = 0.15;
    scaleX = 1.35;
    scaleY = 0.75; // Squash
  }

  void update(double dt) {
    if (hitFlashTimer > 0) {
      hitFlashTimer = max(0.0, hitFlashTimer - dt);
    }
    // Elastic spring back to 1.0
    scaleX += (1.0 - scaleX) * min(1.0, dt * 15.0);
    scaleY += (1.0 - scaleY) * min(1.0, dt * 15.0);
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
      velocity.dx * 0.998,
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

  // Juicy Squash & Stretch
  double scaleX = 1.0;
  double scaleY = 1.0;
  int ballsCaughtInBurst = 0;
  double burstTimer = 0.0;

  CupCatcher({
    required this.x,
    required this.y,
    this.width = GameConstants.cupWidth,
    this.height = GameConstants.cupHeight,
  });

  Rect get bounds => Rect.fromCenter(
        center: Offset(x, y),
        width: width * scaleX,
        height: height * scaleY,
      );

  Rect get catchArea => Rect.fromLTWH(
        x - width * 0.45,
        y - height * 0.55,
        width * 0.9,
        height * 0.65,
      );

  void triggerCatch(double chargeAmount) {
    superCharge = (superCharge + chargeAmount).clamp(0.0, maxSuperCharge);
    catchGlowTimer = 0.18;
    scaleX = 1.18; // Stretch width on catch
    scaleY = 0.82; // Squash height
    ballsCaughtInBurst++;
    burstTimer = 0.5;
  }

  void update(double dt) {
    if (catchGlowTimer > 0) {
      catchGlowTimer = max(0.0, catchGlowTimer - dt);
    }
    // Smooth spring back to normal size
    scaleX += (1.0 - scaleX) * min(1.0, dt * 14.0);
    scaleY += (1.0 - scaleY) * min(1.0, dt * 14.0);

    if (burstTimer > 0) {
      burstTimer -= dt;
      if (burstTimer <= 0) {
        ballsCaughtInBurst = 0;
      }
    }
  }

  void resetSuper() {
    superCharge = 0.0;
  }
}
