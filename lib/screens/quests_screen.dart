import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/game_theme.dart';
import '../models/quest_model.dart';
import '../state/quest_state.dart';
import '../state/player_profile_state.dart';

class QuestsScreen extends StatelessWidget {
  const QuestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16152B),
      body: SafeArea(
        child: Consumer2<QuestState, PlayerProfileState>(
          builder: (context, questState, profileState, child) {
            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'QUESTS & CUP PASS',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${questState.passPoints} PTS',
                            style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Cup Pass Banner
                _buildCupPassBanner(context, questState, profileState),

                const SizedBox(height: 16),

                // Daily Quests Header
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'DAILY MISSIONS',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Quests List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: questState.dailyQuests.length,
                    itemBuilder: (context, index) {
                      final quest = questState.dailyQuests[index];
                      final progress = questState.getProgress(quest.id);
                      final isClaimed = questState.isClaimed(quest.id);
                      final isComplete = progress >= quest.targetValue;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: GameTheme.card3D(
                          color: isClaimed ? const Color(0xFF1B1833) : const Color(0xFF221F40),
                          borderColor: isComplete && !isClaimed ? const Color(0xFF2ECC71) : const Color(0xFF3F3B6C),
                          borderRadius: 16,
                          elevation: isClaimed ? 1 : 3,
                        ),
                        child: Row(
                          children: [
                            // Icon
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF5B36D6).withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF5B36D6)),
                              ),
                              child: Icon(quest.icon, color: Colors.amberAccent, size: 24),
                            ),
                            const SizedBox(width: 14),

                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    quest.title,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    quest.description,
                                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                                  ),
                                  const SizedBox(height: 6),

                                  // Progress Bar
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: (progress / quest.targetValue).clamp(0.0, 1.0),
                                      backgroundColor: const Color(0xFF141226),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isComplete ? const Color(0xFF2ECC71) : const Color(0xFF5B36D6),
                                      ),
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Claim / Status Button
                            if (isClaimed)
                              const Icon(Icons.check_circle, color: Color(0xFF2ECC71), size: 26)
                            else if (isComplete)
                              ElevatedButton(
                                onPressed: () {
                                  if (questState.claimQuest(quest.id)) {
                                    profileState.addGold(quest.goldReward);
                                    if (quest.gemReward > 0) profileState.addGems(quest.gemReward);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Claimed +${quest.goldReward} Gold & +${quest.gemReward} Gems! 🎁')),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2ECC71),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('CLAIM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              )
                            else
                              Text(
                                '$progress/${quest.targetValue}',
                                style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12),
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

  Widget _buildCupPassBanner(BuildContext context, QuestState questState, PlayerProfileState profileState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: GameTheme.card3D(
        color: const Color(0xFF1E1B38),
        borderColor: const Color(0xFFFFD700),
        borderRadius: 20,
        elevation: 4,
        glow: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'CUP PASS SEASON 1',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1.0),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber),
                ),
                child: Text(
                  '${questState.passPoints} PASS PTS',
                  style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tiers Horizontal Track
          SizedBox(
            height: 95,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: questState.passTiers.length,
              itemBuilder: (context, index) {
                final tier = questState.passTiers[index];
                final isUnlocked = questState.passPoints >= tier.requiredPoints;
                final isClaimed = questState.isTierClaimed(tier.tierNumber);

                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isClaimed ? const Color(0xFF16152B) : const Color(0xFF28234D),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isClaimed
                          ? const Color(0xFF3F3B6C)
                          : (isUnlocked ? Colors.amber : const Color(0xFF4B4480)),
                      width: isUnlocked && !isClaimed ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'TIER ${tier.tierNumber}',
                        style: TextStyle(
                          color: isUnlocked ? Colors.amber : Colors.white60,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+${tier.goldReward}G',
                        style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      if (isClaimed)
                        const Text('CLAIMED', style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold))
                      else if (isUnlocked)
                        InkWell(
                          onTap: () {
                            if (questState.claimTier(tier.tierNumber)) {
                              profileState.addGold(tier.goldReward);
                              profileState.addGems(tier.gemReward);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Tier ${tier.tierNumber} Claimed! 🏆')),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2ECC71),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('CLAIM', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        )
                      else
                        Text('${tier.requiredPoints} pts', style: const TextStyle(color: Colors.white38, fontSize: 9)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
