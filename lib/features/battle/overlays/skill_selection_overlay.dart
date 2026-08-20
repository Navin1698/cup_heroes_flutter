import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/theme/ember_theme.dart';
import '../../../models/skill_definition.dart';

class SkillSelectionOverlay extends StatelessWidget {
  final List<SkillDefinition> options;
  final Function(SkillDefinition) onSelect;

  const SkillSelectionOverlay({
    super.key,
    required this.options,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: EmberTheme.crystalCard(
            color: EmberColors.surface,
            borderColor: EmberColors.primary,
            borderRadius: 24,
            glow: true,
            glowColor: EmberColors.primary,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, color: EmberColors.accent, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'LEVEL UP!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.auto_awesome, color: EmberColors.accent, size: 24),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose a crystal power to enhance your hero:',
                style: TextStyle(color: EmberColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 16),

              // 3 Skill Option Cards
              ...options.asMap().entries.map((entry) {
                final index = entry.key;
                final skill = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: InkWell(
                    onTap: () => onSelect(skill),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: EmberTheme.crystalCard(
                        color: EmberColors.surfaceLight,
                        borderColor: skill.accentColor,
                        borderRadius: 16,
                      ),
                      child: Row(
                        children: [
                          // Icon
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: skill.accentColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: skill.accentColor, width: 1.5),
                            ),
                            child: Icon(skill.icon, color: skill.accentColor, size: 26),
                          ),
                          const SizedBox(width: 14),

                          // Text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  skill.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  skill.description,
                                  style: const TextStyle(color: EmberColors.textSecondary, fontSize: 11),
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
