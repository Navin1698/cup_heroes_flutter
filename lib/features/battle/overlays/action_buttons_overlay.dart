import 'package:flutter/material.dart';
import '../../../core/constants/color_constants.dart';
import '../../../game/emberbound_game.dart';

class ActionButtonsOverlay extends StatelessWidget {
  final EmberboundGame game;

  const ActionButtonsOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final player = game.player;

    return Positioned(
      bottom: 35,
      right: 25,
      child: SizedBox(
        width: 170,
        height: 170,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Center Main Basic Attack Button
            Positioned(
              right: 10,
              bottom: 10,
              child: _buildActionButton(
                size: 72,
                icon: Icons.colorize,
                label: 'ATTACK',
                color: EmberColors.secondary,
                onTap: () => game.onBasicAttackPressed(),
              ),
            ),

            // Top: Heavy Attack Button
            Positioned(
              right: 20,
              top: 0,
              child: _buildActionButton(
                size: 46,
                icon: Icons.gavel,
                label: 'HEAVY',
                color: EmberColors.accent,
                onTap: () => game.onHeavyAttackPressed(),
              ),
            ),

            // Left: Special Ability (Crystal Nova)
            Positioned(
              left: 10,
              bottom: 25,
              child: _buildActionButton(
                size: 48,
                icon: Icons.bubble_chart,
                label: 'NOVA',
                color: EmberColors.primary,
                onTap: () => game.onSpecialPressed(),
              ),
            ),

            // Top Left: Ultimate (Celestial Burst)
            Positioned(
              left: 35,
              top: 15,
              child: _buildActionButton(
                size: 52,
                icon: Icons.auto_awesome,
                label: 'ULT',
                color: player.canUltimate ? EmberColors.accent : const Color(0xFF3F4255),
                glow: player.canUltimate,
                onTap: () => game.onUltimatePressed(),
              ),
            ),

            // Far Right / Dash
            Positioned(
              right: 90,
              bottom: 0,
              child: _buildActionButton(
                size: 44,
                icon: Icons.directions_run,
                label: 'DASH',
                color: EmberColors.success,
                onTap: () => game.onDashPressed(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required double size,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool glow = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              color.withValues(alpha: 0.7),
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2.0),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: glow ? 0.8 : 0.4),
              blurRadius: glow ? 16 : 8,
              spreadRadius: glow ? 2 : 0,
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.45),
      ),
    );
  }
}
