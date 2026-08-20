import 'package:flutter/material.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/theme/ember_theme.dart';

class GameOverOverlay extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onWorldMap;

  const GameOverOverlay({
    super.key,
    required this.onRetry,
    required this.onWorldMap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: EmberTheme.crystalCard(
            color: EmberColors.surface,
            borderColor: EmberColors.danger,
            borderRadius: 24,
            glow: true,
            glowColor: EmberColors.danger,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'DEFEATED',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: EmberColors.danger,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your hero has fallen in battle. Upgrade your gear and try again!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: onRetry,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: EmberColors.danger,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: EmberColors.danger.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'RETRY STAGE',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onWorldMap,
                child: const Text('RETURN TO WORLD MAP', style: TextStyle(color: EmberColors.textSecondary, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
