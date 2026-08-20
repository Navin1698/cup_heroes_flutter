import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/theme/ember_theme.dart';
import '../../../models/world_definition.dart';

class VictoryOverlay extends StatelessWidget {
  final StageDefinition stage;
  final VoidCallback onNextStage;
  final VoidCallback onWorldMap;

  const VictoryOverlay({
    super.key,
    required this.stage,
    required this.onNextStage,
    required this.onWorldMap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: EmberTheme.crystalCard(
            color: EmberColors.surface,
            borderColor: EmberColors.accent,
            borderRadius: 24,
            glow: true,
            glowColor: EmberColors.accent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'VICTORY!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: EmberColors.accent,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Stage ${stage.stageNumber}: ${stage.name}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 16),

              // 3 Stars
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: EmberColors.accent, size: 36),
                  SizedBox(width: 8),
                  Icon(Icons.star, color: EmberColors.accent, size: 44),
                  SizedBox(width: 8),
                  Icon(Icons.star, color: EmberColors.accent, size: 36),
                ],
              ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.elasticOut),

              const SizedBox(height: 20),

              // Rewards Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: EmberColors.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: EmberColors.surfaceBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildRewardItem(Icons.monetization_on, '+${stage.goldReward}', EmberColors.accent),
                    _buildRewardItem(Icons.diamond, '+${stage.gemReward}', EmberColors.secondary),
                    _buildRewardItem(Icons.military_tech, '+${stage.xpReward} XP', EmberColors.success),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Next Stage Action Button
              InkWell(
                onTap: onNextStage,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: EmberTheme.primaryButton(borderRadius: 16),
                  child: const Center(
                    child: Text(
                      'NEXT STAGE',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1.2),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: onWorldMap,
                child: const Text('RETURN TO MAP', style: TextStyle(color: EmberColors.textSecondary, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}
