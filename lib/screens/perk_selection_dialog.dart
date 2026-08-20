import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants/game_constants.dart';
import '../core/theme/game_theme.dart';
import '../models/skill_perk_model.dart';

class PerkSelectionDialog extends StatelessWidget {
  final List<SkillPerkModel> options;
  final Function(SkillPerkModel) onSelect;

  const PerkSelectionDialog({
    super.key,
    required this.options,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(18),
          decoration: GameTheme.card3D(
            color: const Color(0xFF1E1B38),
            borderColor: const Color(0xFF5B36D6),
            borderRadius: 24,
            elevation: 8,
            glow: true,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Title Banner
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Color(0xFFFFD700), size: 26),
                  const SizedBox(width: 8),
                  const Text(
                    'CHOOSE A PERK!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(color: Color(0xFF5B36D6), blurRadius: 12),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.star, color: Color(0xFFFFD700), size: 26),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Power up your Cup Hero for this battle!',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 16),

              // 3 Vertical Perk Cards Row / Column
              ...options.asMap().entries.map((entry) {
                final index = entry.key;
                final perk = entry.value;
                final rarityColor = GameTheme.getRarityColor(perk.tier);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: InkWell(
                    onTap: () => onSelect(perk),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: GameTheme.card3D(
                        color: const Color(0xFF28234D),
                        borderColor: rarityColor,
                        borderRadius: 16,
                        elevation: 3,
                      ),
                      child: Row(
                        children: [
                          // 3D Icon Box
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  perk.accentColor.withValues(alpha: 0.3),
                                  const Color(0xFF141226),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: perk.accentColor, width: 2),
                            ),
                            child: Icon(perk.icon, color: perk.accentColor, size: 28),
                          ),
                          const SizedBox(width: 14),

                          // Text Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        perk.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: rarityColor.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: rarityColor, width: 1),
                                      ),
                                      child: Text(
                                        GameTheme.getRarityName(perk.tier).toUpperCase(),
                                        style: TextStyle(
                                          color: rarityColor,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  perk.description,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    height: 1.25,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.2, end: 0);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
