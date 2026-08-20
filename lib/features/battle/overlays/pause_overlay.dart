import 'package:flutter/material.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/theme/ember_theme.dart';

class PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  const PauseOverlay({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onQuit,
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
            borderColor: EmberColors.primary,
            borderRadius: 22,
            glow: true,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GAME PAUSED',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2),
              ),
              const SizedBox(height: 24),
              _buildButton('RESUME', EmberColors.success, onResume),
              const SizedBox(height: 12),
              _buildButton('RESTART', EmberColors.secondary, onRestart),
              const SizedBox(height: 12),
              _buildButton('QUIT TO MAP', EmberColors.danger, onQuit),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.0),
          ),
        ),
      ),
    );
  }
}
