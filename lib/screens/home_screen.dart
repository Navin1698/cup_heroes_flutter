import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/game_constants.dart';
import '../core/theme/game_theme.dart';
import '../core/audio/audio_manager.dart';
import '../models/chapter_model.dart';
import '../state/player_profile_state.dart';
import '../state/hero_state.dart';
import '../state/inventory_state.dart';
import '../state/talent_state.dart';
import 'battle_screen.dart';
import 'chapter_select_screen.dart';
import 'equipment_screen.dart';
import 'talents_screen.dart';
import 'heroes_screen.dart';
import 'shop_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 2; // Default to Battle tab

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlayerProfileState>().loadProfile();
      context.read<HeroState>().loadHeroState();
      context.read<InventoryState>().loadInventory();
      context.read<TalentState>().loadTalents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameConstants.darkBg,
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          const ShopScreen(),
          const EquipmentScreen(),
          _buildMainBattleHub(context),
          const TalentsScreen(),
          const HeroesScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildMainBattleHub(BuildContext context) {
    return SafeArea(
      child: Consumer4<PlayerProfileState, HeroState, InventoryState, TalentState>(
        builder: (context, profile, heroState, inv, talents, child) {
          final allChapters = ChapterModel.getAllChapters();
          final currentChapterIndex = (profile.highestChapter - 1).clamp(0, allChapters.length - 1);
          final currentChapter = allChapters[currentChapterIndex];
          final selectedHero = heroState.selectedHero;

          final totalHp = selectedHero.baseHp + inv.totalBonusHp + talents.bonusHp;
          final totalAtk = selectedHero.baseAttack + inv.totalBonusAttack + talents.bonusAttack;

          return Column(
            children: [
              // Top Player Info Bar
              _buildTopPlayerBar(profile),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      // Chapter Campaign Hero Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: GameTheme.cardDecoration(
                          color: const Color(0xFF1E1B38),
                          borderColor: currentChapter.themeColor,
                          borderWidth: 2.5,
                          borderRadius: 24,
                          glow: true,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: currentChapter.themeColor.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: currentChapter.themeColor),
                                  ),
                                  child: Text(
                                    'CHAPTER ${currentChapter.id}',
                                    style: TextStyle(
                                      color: currentChapter.themeColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const ChapterSelectScreen()),
                                    );
                                  },
                                  child: const Row(
                                    children: [
                                      Text('MAP', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                                      Icon(Icons.chevron_right, color: Colors.white70, size: 18),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              currentChapter.title,
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              currentChapter.subtitle,
                              style: TextStyle(color: currentChapter.themeColor, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentChapter.description,
                              style: const TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                            const SizedBox(height: 20),

                            // Hero Preview Box inside Chapter Banner
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF141226),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFF2C274E)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: selectedHero.primaryColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: selectedHero.primaryColor, width: 2),
                                    ),
                                    child: Icon(selectedHero.icon, color: selectedHero.primaryColor, size: 30),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${selectedHero.name} • ${selectedHero.title}',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.favorite, color: GameConstants.hpGreen, size: 14),
                                            const SizedBox(width: 4),
                                            Text('$totalHp HP', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                            const SizedBox(width: 12),
                                            const Icon(Icons.colorize, color: Colors.orangeAccent, size: 14),
                                            const SizedBox(width: 4),
                                            Text('$totalAtk ATK', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Big Battle Launch Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (profile.consumeEnergy(5)) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BattleScreen(chapter: currentChapter),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Not enough energy! (5 Energy required)')),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6C3CE9),
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.play_arrow, color: Colors.white, size: 28),
                                    SizedBox(width: 8),
                                    Text(
                                      'PLAY BATTLE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      '(⚡ 5)',
                                      style: TextStyle(color: GameConstants.energyColor, fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Quick Navigation Highlights
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickNavCard(
                              title: 'Gear Forge',
                              subtitle: '${inv.backpackItems.length} items',
                              icon: Icons.shield,
                              color: const Color(0xFF3498DB),
                              onTap: () => setState(() => _currentTabIndex = 1),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickNavCard(
                              title: 'Talents',
                              subtitle: 'Permanent buffs',
                              icon: Icons.auto_awesome,
                              color: const Color(0xFFF1C40F),
                              onTap: () => setState(() => _currentTabIndex = 3),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopPlayerBar(PlayerProfileState profile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1B38),
        border: Border(bottom: BorderSide(color: Color(0xFF2C274E), width: 1.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & Title
          const Row(
            children: [
              Icon(Icons.sports_volleyball, color: Colors.amberAccent, size: 24),
              SizedBox(width: 8),
              Text(
                'CUP HEROES',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),

          // Currencies (Energy, Gold, Gems)
          Row(
            children: [
              // Energy
              _buildCurrencyChip(
                icon: Icons.flash_on,
                iconColor: GameConstants.energyColor,
                value: '${profile.energy}/${profile.maxEnergy}',
              ),
              const SizedBox(width: 8),

              // Gold
              _buildCurrencyChip(
                icon: Icons.monetization_on,
                iconColor: GameConstants.goldColor,
                value: '${profile.gold}',
              ),
              const SizedBox(width: 8),

              // Gems
              _buildCurrencyChip(
                icon: Icons.diamond,
                iconColor: GameConstants.gemColor,
                value: '${profile.gems}',
              ),
              const SizedBox(width: 8),

              // Audio Toggle
              InkWell(
                onTap: () {
                  setState(() {
                    AudioManager.instance.toggleSound();
                  });
                },
                child: Icon(
                  AudioManager.instance.isSoundEnabled ? Icons.volume_up : Icons.volume_off,
                  color: Colors.white60,
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyChip({required IconData icon, required Color iconColor, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF141226),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2C274E)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 14),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickNavCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: GameTheme.cardDecoration(
          color: const Color(0xFF1E1B38),
          borderColor: color.withOpacity(0.5),
          borderWidth: 1.5,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1B1833),
        border: Border(top: BorderSide(color: Color(0xFF2C274E), width: 1.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
        backgroundColor: const Color(0xFF1B1833),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: GameConstants.primaryPurple,
        unselectedItemColor: Colors.white38,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.shield), label: 'Equipment'),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_fill, size: 30), label: 'Battle'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'Talents'),
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Heroes'),
        ],
      ),
    );
  }
}
