import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/game_constants.dart';
import '../core/theme/game_theme.dart';
import '../models/chapter_model.dart';
import '../state/player_profile_state.dart';
import 'battle_screen.dart';

class ChapterSelectScreen extends StatelessWidget {
  const ChapterSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final allChapters = ChapterModel.getAllChapters();

    return Scaffold(
      backgroundColor: GameConstants.darkBg,
      body: SafeArea(
        child: Consumer<PlayerProfileState>(
          builder: (context, profileState, child) {
            return Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'CAMPAIGN CHAPTERS',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.flash_on, color: GameConstants.energyColor, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${profileState.energy}/${profileState.maxEnergy}',
                            style: const TextStyle(
                              color: GameConstants.energyColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Chapter Cards List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: allChapters.length,
                    itemBuilder: (context, index) {
                      final chapter = allChapters[index];
                      final isUnlocked = chapter.id <= profileState.highestChapter;
                      final isCurrent = chapter.id == profileState.highestChapter;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: GameTheme.cardDecoration(
                          color: const Color(0xFF1E1B38),
                          borderColor: isUnlocked ? chapter.themeColor : const Color(0xFF3F3B6C),
                          borderWidth: isCurrent ? 2.5 : 1.5,
                          glow: isCurrent,
                        ),
                        child: Column(
                          children: [
                            // Banner Header
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isUnlocked ? chapter.themeColor.withOpacity(0.2) : Colors.black26,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                              ),
                              child: Row(
                                children: [
                                  Icon(chapter.icon, color: isUnlocked ? chapter.themeColor : Colors.white38, size: 24),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      chapter.title,
                                      style: TextStyle(
                                        color: isUnlocked ? Colors.white : Colors.white38,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  if (!isUnlocked)
                                    const Icon(Icons.lock, color: Colors.white38, size: 18)
                                  else if (chapter.id < profileState.highestChapter)
                                    const Icon(Icons.check_circle, color: GameConstants.hpGreen, size: 20),
                                ],
                              ),
                            ),

                            // Content Details
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    chapter.subtitle,
                                    style: TextStyle(
                                      color: isUnlocked ? chapter.themeColor : Colors.white38,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    chapter.description,
                                    style: TextStyle(color: isUnlocked ? Colors.white70 : Colors.white24, fontSize: 12),
                                  ),
                                  const SizedBox(height: 14),

                                  // Wave count & rewards
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.waves, color: Colors.amberAccent, size: 16),
                                          const SizedBox(width: 4),
                                          Text('${chapter.totalWaves} Waves', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.monetization_on, color: GameConstants.goldColor, size: 16),
                                          const SizedBox(width: 4),
                                          Text('+${chapter.goldCompletionReward}', style: const TextStyle(color: GameConstants.goldColor, fontSize: 12, fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 10),
                                          const Icon(Icons.diamond, color: GameConstants.gemColor, size: 16),
                                          const SizedBox(width: 4),
                                          Text('+${chapter.gemCompletionReward}', style: const TextStyle(color: GameConstants.gemColor, fontSize: 12, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Battle Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: isUnlocked
                                          ? () {
                                              if (profileState.consumeEnergy(5)) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => BattleScreen(chapter: chapter),
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Not enough energy! (Need 5 Energy)')),
                                                );
                                              }
                                            }
                                          : null,
                                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                                      label: const Text(
                                        'BATTLE (5 ENERGY)',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isUnlocked ? GameConstants.primaryPurple : Colors.grey[800],
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
