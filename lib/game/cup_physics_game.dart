import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'components/cups/cup_collector_component.dart';
import 'components/pegboard/ball_physics_component.dart';
import 'components/pegboard/multiplier_gate_component.dart';
import 'components/pegboard/peg_component.dart';

class CupPhysicsGame extends FlameGame with TapDetector {
  final Function(int activeBalls, int totalCollected, int multiplierEvents)? onStatsChanged;
  final Function(int count, bool isGold)? onBallCollectedCallback;

  int totalCollectedBalls = 0;
  int totalMultiplierEvents = 0;

  late CupCollectorComponent heroCup;
  late MultiplierGateComponent topGate;
  late MultiplierGateComponent midGate;

  final List<PegComponent> pegs = [];
  final List<MultiplierGateComponent> gates = [];
  final List<BallPhysicsComponent> activeBalls = [];

  final Random _rng = Random();

  CupPhysicsGame({
    this.onStatsChanged,
    this.onBallCollectedCallback,
  });

  @override
  Color backgroundColor() => const Color(0xFF070A14);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _buildArena();
  }

  void _buildArena() {
    // 1. Multiplier Gates
    topGate = MultiplierGateComponent(
      position: Vector2(190.0, 110.0),
      width: 76.0,
      height: 22.0,
      operation: GateOperation.add,
      value: 5,
      moveAmplitude: 65.0,
      moveSpeed: 1.8,
      onSpawnBall: _handleGateMultiplier,
    );
    gates.add(topGate);
    world.add(topGate);

    midGate = MultiplierGateComponent(
      position: Vector2(190.0, 240.0),
      width: 68.0,
      height: 22.0,
      operation: GateOperation.multiply,
      value: 2,
      moveAmplitude: 75.0,
      moveSpeed: 2.2,
      initialPhase: pi / 2,
      onSpawnBall: _handleGateMultiplier,
    );
    gates.add(midGate);
    world.add(midGate);

    // 2. Staggered Pegboard Obstacles (Plinko Style)
    _generatePegboard();

    // 3. Hero Collection Cup at the bottom
    heroCup = CupCollectorComponent(
      position: Vector2(190.0, 440.0),
      width: 120.0,
      height: 48.0,
      label: 'HERO CUP',
      onBallCollected: (count, isGold) {
        totalCollectedBalls += count;
        onBallCollectedCallback?.call(count, isGold);
        _notifyStats();
      },
    );
    world.add(heroCup);
  }

  void _generatePegboard() {
    // 3 Rows above top gate
    for (int row = 0; row < 3; row++) {
      final y = 40.0 + (row * 24.0);
      final isEven = row % 2 == 0;
      final count = isEven ? 8 : 7;
      final startX = isEven ? 45.0 : 65.0;
      final spacing = 40.0;

      for (int i = 0; i < count; i++) {
        final x = startX + (i * spacing);
        if (x > 30 && x < 350) {
          final peg = PegComponent(
            position: Vector2(x, y),
            radius: 5.5,
            isBumper: row == 1 && (i == 3 || i == 4),
          );
          pegs.add(peg);
          world.add(peg);
        }
      }
    }

    // 4 Rows between top and mid gate
    for (int row = 0; row < 4; row++) {
      final y = 145.0 + (row * 24.0);
      final isEven = row % 2 == 0;
      final count = isEven ? 8 : 7;
      final startX = isEven ? 45.0 : 65.0;
      final spacing = 40.0;

      for (int i = 0; i < count; i++) {
        final x = startX + (i * spacing);
        if (x > 30 && x < 350) {
          final peg = PegComponent(
            position: Vector2(x, y),
            radius: 5.5,
            isBumper: (i % 3 == 0),
          );
          pegs.add(peg);
          world.add(peg);
        }
      }
    }

    // 4 Rows below mid gate
    for (int row = 0; row < 4; row++) {
      final y = 280.0 + (row * 24.0);
      final isEven = row % 2 == 0;
      final count = isEven ? 8 : 7;
      final startX = isEven ? 45.0 : 65.0;
      final spacing = 40.0;

      for (int i = 0; i < count; i++) {
        final x = startX + (i * spacing);
        if (x > 30 && x < 350) {
          final peg = PegComponent(
            position: Vector2(x, y),
            radius: 5.5,
            isBumper: false,
          );
          pegs.add(peg);
          world.add(peg);
        }
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    for (int i = activeBalls.length - 1; i >= 0; i--) {
      final ball = activeBalls[i];
      if (!ball.isMounted || ball.isCollected) {
        activeBalls.removeAt(i);
        _notifyStats();
        continue;
      }
      ball.updatePhysics(dt, pegs, gates, heroCup);
    }
  }

  void _handleGateMultiplier(Vector2 pos, Vector2 vel, bool isGold) {
    totalMultiplierEvents++;
    _spawnBall(pos, vel, isGold);
  }

  void _spawnBall(Vector2 pos, Vector2 vel, bool isGold) {
    if (activeBalls.length > 250) return; // Performance cap

    final ball = BallPhysicsComponent(
      position: pos,
      velocity: vel,
      isGold: isGold,
      onHitGate: (gate, hitPos, hitVel, ballIsGold) {
        totalMultiplierEvents++;
        _notifyStats();

        final spawnCount = gate.operation == GateOperation.add
            ? gate.value
            : max(1, gate.value - 1);

        for (int i = 0; i < spawnCount; i++) {
          final angle = -pi / 2 + (_rng.nextDouble() * pi);
          final speed = 100.0 + _rng.nextDouble() * 120.0;
          final spreadVel = Vector2(cos(angle) * speed, sin(angle).abs() * speed + 50.0);
          final jitterPos = hitPos + Vector2((_rng.nextDouble() - 0.5) * 12.0, 6.0);

          _spawnBall(jitterPos, spreadVel, ballIsGold);
        }
      },
      onCollected: (ball) {
        activeBalls.remove(ball);
        _notifyStats();
      },
    );

    activeBalls.add(ball);
    world.add(ball);
    _notifyStats();
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    final pos = info.eventPosition.global;
    if (pos.y < 180.0) {
      dropBall(at: Vector2(pos.x.clamp(50.0, 330.0), 20.0));
    }
  }

  void dropBall({Vector2? at, bool isGold = false}) {
    final dropX = at?.x ?? (150.0 + _rng.nextDouble() * 80.0);
    final dropY = at?.y ?? 20.0;
    final initialVel = Vector2((_rng.nextDouble() - 0.5) * 30.0, 40.0 + _rng.nextDouble() * 40.0);

    _spawnBall(Vector2(dropX, dropY), initialVel, isGold);
  }

  void dropBurst({int count = 10, bool isGold = false}) {
    for (int i = 0; i < count; i++) {
      Future.delayed(Duration(milliseconds: i * 45), () {
        dropBall(isGold: isGold);
      });
    }
  }

  void updateTopGate({required GateOperation op, required int value, double? widthBonus}) {
    final width = 76.0 * (1.0 + (widthBonus ?? 0.0));
    topGate.updateConfig(op: op, val: value, newWidth: width);
  }

  void updateMidGate({required GateOperation op, required int value, double? widthBonus}) {
    final width = 68.0 * (1.0 + (widthBonus ?? 0.0));
    midGate.updateConfig(op: op, val: value, newWidth: width);
  }

  void clearAllBalls() {
    for (final b in activeBalls) {
      b.removeFromParent();
    }
    activeBalls.clear();
    _notifyStats();
  }

  void _notifyStats() {
    onStatsChanged?.call(activeBalls.length, totalCollectedBalls, totalMultiplierEvents);
  }
}
