import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/game_constants.dart';
import '../core/theme/game_theme.dart';
import '../state/talent_state.dart';
import '../state/player_profile_state.dart';

class TalentsScreen extends StatelessWidget {
  const TalentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameConstants.darkBg,
      body: SafeArea(
        child: Consumer2<TalentState, PlayerProfileState>(
          builder: (context, talentState, profileState, child) {
            return Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TALENT TREE',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.monetization_on, color: GameConstants.goldColor, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${profileState.gold}',
                            style: const TextStyle(
                              color: GameConstants.goldColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Talent Tree Subheader
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1B38),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF3F3B6C)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.auto_fix_high, color: Colors.amberAccent, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Talents provide permanent passive stat boosts that apply across ALL heroes and runs!',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Talents List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: talentState.allTalents.length,
                    itemBuilder: (context, index) {
                      final talent = talentState.allTalents[index];
                      final currentLvl = talentState.getLevel(talent.type);
                      final isMax = currentLvl >= talent.maxLevel;
                      final cost = talent.getCostForLevel(currentLvl);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: GameTheme.cardDecoration(
                          color: const Color(0xFF1E1B38),
                          borderColor: (currentLvl > 0) ? GameConstants.primaryPurple : const Color(0xFF3F3B6C),
                          borderWidth: 1.5,
                        ),
                        child: Row(
                          children: [
                            // Icon
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: GameConstants.primaryPurple.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: GameConstants.primaryPurple),
                              ),
                              child: Icon(talent.icon, color: Colors.amberAccent, size: 26),
                            ),
                            const SizedBox(width: 14),

                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        talent.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        'Lv.$currentLvl / ${talent.maxLevel}',
                                        style: TextStyle(
                                          color: isMax ? Colors.amber : Colors.white60,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    talent.description,
                                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Upgrade Button
                            if (isMax)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.amber),
                                ),
                                child: const Text(
                                  'MAX',
                                  style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              )
                            else
                              ElevatedButton(
                                onPressed: () {
                                  if (profileState.spendGold(cost)) {
                                    talentState.upgradeTalent(talent.type);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Not enough gold to upgrade talent!')),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6C3CE9),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.monetization_on, color: GameConstants.goldColor, size: 14),
                                    const SizedBox(width: 4),
                                    Text('$cost', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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
