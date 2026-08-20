import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants/game_constants.dart';
import '../core/theme/game_theme.dart';
import '../game/game_controller.dart';

class VictoryDefeatDialog extends StatelessWidget {
  final bool isVictory;
  final GameController controller;
  final VoidCallback onContinue;
  final VoidCallback onRetry;

  const VictoryDefeatDialog({
    super.key,
    required this.isVictory,
    required this.controller,
    required this.onContinue,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = isVictory ? Colors.amber : Colors.redAccent;
    final totalGold = controller.goldEarned + (isVictory ? controller.chapter.goldCompletionReward : 0);
    final totalGems = isVictory ? controller.chapter.gemCompletionReward : 0;

    return PopScope(
      canPop: false,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: GameTheme.cardDecoration(
            color: const Color(0xFF1E1B38),
            borderColor: titleColor,
            borderWidth: 3.0,
            borderRadius: 24,
            glow: true,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Header
              Icon(
                isVictory ? Icons.emoji_events : Icons.sentiment_very_dissatisfied,
                color: titleColor,
                size: 64,
              ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
              const SizedBox(height: 12),

              // Title
              Text(
                isVictory ? 'VICTORY!' : 'DEFEAT',
                style: TextStyle(
                  color: titleColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(color: titleColor.withOpacity(0.6), blurRadius: 12),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isVictory
                  ? 'You conquered ${controller.chapter.title}!'
                  : 'Fell at Wave ${controller.currentWave}/${controller.chapter.totalWaves}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Stats Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF141226),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF3F3B6C)),
                ),
                child: Column(
                  children: [
                    _buildStatRow('Waves Cleared', '${controller.currentWave}/${controller.chapter.totalWaves}'),
                    const Divider(color: Color(0xFF2C274E), height: 16),
                    _buildStatRow('Enemies Slain', '${controller.totalKills}'),
                    const Divider(color: Color(0xFF2C274E), height: 16),
                    _buildStatRow('Balls Collected', '${controller.totalBallsCaught}'),
                    const Divider(color: Color(0xFF2C274E), height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Gold Reward', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        Row(
                          children: [
                            const Icon(Icons.monetization_on, color: GameConstants.goldColor, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '+$totalGold',
                              style: const TextStyle(color: GameConstants.goldColor, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (totalGems > 0) ...[
                      const Divider(color: Color(0xFF2C274E), height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Gems Reward', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          Row(
                            children: [
                              const Icon(Icons.diamond, color: GameConstants.gemColor, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '+$totalGems',
                                style: const TextStyle(color: GameConstants.gemColor, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onRetry,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF6C3CE9), width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('RETRY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GameConstants.primaryPurple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                      child: const Text('CONTINUE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
