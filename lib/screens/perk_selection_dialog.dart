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
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: GameTheme.cardDecoration(
            color: const Color(0xFF1E1B38),
            borderColor: GameConstants.primaryPurple,
            borderWidth: 3.0,
            borderRadius: 24.0,
            glow: true,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title Banner
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'LEVEL UP!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(color: GameConstants.primaryPurple.withOpacity(0.8), blurRadius: 10),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.star, color: Colors.amber, size: 28),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose a Perk to power up your hero',
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // 3 Perk Cards
              ...options.asMap().entries.map((entry) {
                final index = entry.key;
                final perk = entry.value;
                final rarityColor = GameTheme.getRarityColor(perk.tier);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: InkWell(
                    onTap: () => onSelect(perk),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: GameTheme.cardDecoration(
                        color: const Color(0xFF28234D),
                        borderColor: rarityColor,
                        borderWidth: 2.0,
                        borderRadius: 16,
                      ),
                      child: Row(
                        children: [
                          // Icon Container
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: perk.accentColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: perk.accentColor, width: 1.5),
                            ),
                            child: Icon(perk.icon, color: perk.accentColor, size: 26),
                          ),
                          const SizedBox(width: 14),

                          // Details
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
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: rarityColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: rarityColor, width: 1),
                                      ),
                                      child: Text(
                                        GameTheme.getRarityName(perk.tier).toUpperCase(),
                                        style: TextStyle(
                                          color: rarityColor,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  perk.description,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: (index * 120).ms).slideY(begin: 0.2, end: 0);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
