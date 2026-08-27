import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../game/components/pegboard/multiplier_gate_component.dart';
import '../../game/cup_physics_game.dart';

class BallDropSandboxScreen extends StatefulWidget {
  const BallDropSandboxScreen({super.key});

  @override
  State<BallDropSandboxScreen> createState() => _BallDropSandboxScreenState();
}

class _BallDropSandboxScreenState extends State<BallDropSandboxScreen> {
  late CupPhysicsGame _game;

  final ValueNotifier<int> _activeBallsNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> _totalCollectedNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> _multiplierHitsNotifier = ValueNotifier<int>(0);

  int _topGateValue = 5;
  GateOperation _topGateOp = GateOperation.add;

  int _midGateValue = 2;
  GateOperation _midGateOp = GateOperation.multiply;

  @override
  void initState() {
    super.initState();
    _game = CupPhysicsGame(
      onStatsChanged: (active, collected, multHits) {
        _activeBallsNotifier.value = active;
        _totalCollectedNotifier.value = collected;
        _multiplierHitsNotifier.value = multHits;
      },
    );
  }

  @override
  void dispose() {
    _activeBallsNotifier.dispose();
    _totalCollectedNotifier.dispose();
    _multiplierHitsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070A14),
      body: Stack(
        children: [
          // 1. Flame Game Widget
          GameWidget(game: _game),

          // 2. Top HUD Bar
          SafeArea(
            child: Column(
              children: [
                _buildTopHUD(),
                const SizedBox(height: 8),
                _buildGateConfigToolbar(),
              ],
            ),
          ),

          // 3. Bottom Action Controls
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: _buildBottomControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHUD() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1024).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),

          // Active Balls Badge
          ValueListenableBuilder<int>(
            valueListenable: _activeBallsNotifier,
            builder: (_, val, __) => _buildStatPill('ACTIVE', '⚪ ', const Color(0xFF00E5FF)),
          ),

          // Total Collected Badge
          ValueListenableBuilder<int>(
            valueListenable: _totalCollectedNotifier,
            builder: (_, val, __) => _buildStatPill('COLLECTED', '🏆 ', const Color(0xFFFF9900)),
          ),

          // Multiplier Hits Badge
          ValueListenableBuilder<int>(
            valueListenable: _multiplierHitsNotifier,
            builder: (_, val, __) => _buildStatPill('GATES HIT', '⚡ ', const Color(0xFFFF2A85)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.6)),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGateConfigToolbar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1024).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Top Gate Cycle
          InkWell(
            onTap: _cycleTopGate,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                children: [
                  const Text('Top Gate: ', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  Text(
                    _topGateOp == GateOperation.add ? '+' : 'x',
                    style: const TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const Icon(Icons.sync, color: Colors.white38, size: 14),
                ],
              ),
            ),
          ),

          // Mid Gate Cycle
          InkWell(
            onTap: _cycleMidGate,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                children: [
                  const Text('Mid Gate: ', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  Text(
                    _midGateOp == GateOperation.add ? '+' : 'x',
                    style: const TextStyle(color: Color(0xFFFF9900), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const Icon(Icons.sync, color: Colors.white38, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _cycleTopGate() {
    setState(() {
      if (_topGateOp == GateOperation.add && _topGateValue == 5) {
        _topGateValue = 10;
      } else if (_topGateOp == GateOperation.add && _topGateValue == 10) {
        _topGateOp = GateOperation.multiply;
        _topGateValue = 2;
      } else {
        _topGateOp = GateOperation.add;
        _topGateValue = 5;
      }
      _game.updateTopGate(op: _topGateOp, value: _topGateValue);
    });
  }

  void _cycleMidGate() {
    setState(() {
      if (_midGateOp == GateOperation.multiply && _midGateValue == 2) {
        _midGateValue = 3;
      } else if (_midGateOp == GateOperation.multiply && _midGateValue == 3) {
        _midGateValue = 5;
      } else {
        _midGateOp = GateOperation.multiply;
        _midGateValue = 2;
      }
      _game.updateMidGate(op: _midGateOp, value: _midGateValue);
    });
  }

  Widget _buildBottomControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            // Drop Single Ball
            Expanded(
              child: _buildActionButton(
                label: 'Drop 1',
                icon: Icons.lens,
                color: const Color(0xFF00E5FF),
                onTap: () => _game.dropBall(),
              ),
            ),
            const SizedBox(width: 8),

            // Drop 10 Balls Burst
            Expanded(
              child: _buildActionButton(
                label: 'Burst x10',
                icon: Icons.bubble_chart,
                color: const Color(0xFF00FF88),
                onTap: () => _game.dropBurst(count: 10),
              ),
            ),
            const SizedBox(width: 8),

            // Boss Ball Drop (Gold)
            Expanded(
              child: _buildActionButton(
                label: 'Gold Burst',
                icon: Icons.stars,
                color: const Color(0xFFFFD700),
                onTap: () {
                  _game.dropBurst(count: 15, isGold: true);
                },
              ),
            ),
            const SizedBox(width: 8),

            // Clear Button
            IconButton.filled(
              onPressed: () => _game.clearAllBalls(),
              icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48).withValues(alpha: 0.85),
                padding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.8), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
