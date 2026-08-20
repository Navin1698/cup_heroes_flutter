import 'package:flutter/material.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/theme/ember_theme.dart';
import '../../../game/emberbound_game.dart';

class BattleHudOverlay extends StatelessWidget {
  final EmberboundGame game;

  const BattleHudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final player = game.player;
    final hpPct = (player.currentHp / player.maxHp).clamp(0.0, 1.0);
    final ultPct = (player.ultimateCharge / player.maxUltimateCharge).clamp(0.0, 1.0);

    return Positioned(
      top: 10,
      left: 14,
      right: 14,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top-Left: Hero Portrait & Health Gauge
          Row(
            children: [
              // Hero Avatar Box
              Container(
                width: 44,
                height: 44,
                decoration: EmberTheme.crystalCard(
                  color: EmberColors.surface,
                  borderColor: EmberColors.secondary,
                  borderRadius: 12,
                  elevation: 2,
                ),
                child: Icon(game.heroDefinition.icon, color: EmberColors.secondary, size: 24),
              ),
              const SizedBox(width: 8),

              // HP & Ultimate Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HP Bar
                  Container(
                    width: 110,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF100E22),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF2C3258)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: hpPct,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(EmberColors.success),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Ultimate Meter
                  Container(
                    width: 110,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF100E22),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: ultPct,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(EmberColors.accent),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Top-Center: Stage / Wave Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: EmberTheme.crystalCard(
              color: EmberColors.surface.withValues(alpha: 0.85),
              borderColor: EmberColors.primary,
              borderRadius: 12,
              elevation: 2,
            ),
            child: Column(
              children: [
                Text(
                  'STAGE ${game.stageDefinition.stageNumber}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.0),
                ),
                Text(
                  'WAVE ${game.currentWave}/${game.stageDefinition.totalWaves}',
                  style: const TextStyle(color: EmberColors.secondary, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Top-Right: Pause Button
          IconButton(
            onPressed: () => game.pauseGame(),
            icon: const Icon(Icons.pause_circle_filled, color: Colors.white70, size: 32),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
