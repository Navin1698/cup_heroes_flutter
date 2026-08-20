import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/game_constants.dart';
import '../core/theme/game_theme.dart';
import '../models/hero_model.dart';
import '../state/hero_state.dart';
import '../state/player_profile_state.dart';

class HeroesScreen extends StatelessWidget {
  const HeroesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameConstants.darkBg,
      body: SafeArea(
        child: Consumer2<HeroState, PlayerProfileState>(
          builder: (context, heroState, profileState, child) {
            final selectedHero = heroState.selectedHero;

            return Column(
              children: [
                // Top Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'HEROES ROSTER',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.diamond, color: GameConstants.gemColor, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${profileState.gems}',
                            style: const TextStyle(
                              color: GameConstants.gemColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Selected Hero Showcase Card
                _buildHeroShowcase(context, selectedHero, heroState, profileState),

                const SizedBox(height: 16),

                // Hero Roster Grid Header
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'AVAILABLE CHAMPIONS',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Hero Roster Horizontal / Grid List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: heroState.allHeroes.length,
                    itemBuilder: (context, index) {
                      final hero = heroState.allHeroes[index];
                      final isUnlocked = heroState.isUnlocked(hero.id);
                      final isSelected = heroState.selectedHeroId == hero.id;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            if (isUnlocked) {
                              heroState.selectHero(hero.id);
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: GameTheme.cardDecoration(
                              color: isSelected ? const Color(0xFF2E265C) : const Color(0xFF1E1B38),
                              borderColor: isSelected ? hero.primaryColor : const Color(0xFF3F3B6C),
                              borderWidth: isSelected ? 2.5 : 1.5,
                              glow: isSelected,
                            ),
                            child: Row(
                              children: [
                                // Hero Avatar
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: hero.primaryColor.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: hero.primaryColor, width: 2),
                                  ),
                                  child: Icon(hero.icon, color: hero.primaryColor, size: 30),
                                ),
                                const SizedBox(width: 14),

                                // Hero Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            hero.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '• ${hero.title}',
                                            style: TextStyle(
                                              color: hero.primaryColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.favorite, color: GameConstants.hpGreen, size: 14),
                                          const SizedBox(width: 4),
                                          Text('${hero.baseHp}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                          const SizedBox(width: 12),
                                          const Icon(Icons.colorize, color: Colors.orangeAccent, size: 14),
                                          const SizedBox(width: 4),
                                          Text('${hero.baseAttack}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                          const SizedBox(width: 12),
                                          const Icon(Icons.speed, color: Colors.cyanAccent, size: 14),
                                          const SizedBox(width: 4),
                                          Text('${hero.attackSpeed}x', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Status / Unlock Button
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: GameConstants.hpGreen.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: GameConstants.hpGreen),
                                    ),
                                    child: const Text(
                                      'ACTIVE',
                                      style: TextStyle(color: GameConstants.hpGreen, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  )
                                else if (isUnlocked)
                                  ElevatedButton(
                                    onPressed: () => heroState.selectHero(hero.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF3F3B6C),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: const Text('SELECT', style: TextStyle(color: Colors.white, fontSize: 11)),
                                  )
                                else
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      if (profileState.spendGems(hero.unlockCostGems)) {
                                        heroState.unlockHero(hero.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('${hero.name} Unlocked!')),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Not enough gems!')),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.diamond, size: 14, color: GameConstants.gemColor),
                                    label: Text('${hero.unlockCostGems}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6C3CE9),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                              ],
                            ),
                          ),
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

  Widget _buildHeroShowcase(
    BuildContext context,
    HeroModel hero,
    HeroState heroState,
    PlayerProfileState profileState,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: GameTheme.cardDecoration(
        color: const Color(0xFF1E1B38),
        borderColor: hero.primaryColor,
        borderWidth: 2.0,
        borderRadius: 20,
        glow: true,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Large Hero Avatar
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: hero.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: hero.primaryColor, width: 2.5),
                ),
                child: Icon(hero.icon, color: hero.primaryColor, size: 40),
              ),
              const SizedBox(width: 16),

              // Title and skill
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hero.name,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      hero.title.toUpperCase(),
                      style: TextStyle(color: hero.primaryColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hero.description,
                      style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Primary Signature Ability Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF141226),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2C274E)),
            ),
            child: Row(
              children: [
                const Icon(Icons.flash_on, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Signature Skill: ${hero.primarySkillName}',
                        style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Text(
                        hero.primarySkillDesc,
                        style: const TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
