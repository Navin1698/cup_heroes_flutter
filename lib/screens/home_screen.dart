import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/game_constants.dart';
import '../core/theme/game_theme.dart';
import '../core/audio/audio_manager.dart';
import '../models/hero_model.dart';
import '../models/chapter_model.dart';
import '../models/equipment_model.dart';
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
import 'quests_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 2; // Default to Center Battle Tab

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
      backgroundColor: const Color(0xFF16152B),
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
              // Top Currency & Profile Bar
              _buildTopHeader(profile),

              // Main Hub Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      // Chapter Info Banner
                      _buildChapterBanner(context, currentChapter),

                      const SizedBox(height: 12),

                      // Central Hero Display + Paper-Doll Equipment Slots
                      _buildHeroPaperDollStage(selectedHero, inv, totalHp, totalAtk),

                      const SizedBox(height: 16),

                      // Large Embossed 3D Play Button
                      _buildBigBattleButton(context, currentChapter, profile),

                      const SizedBox(height: 14),

                      // Quick Jump Cards (Forge, Talents, Quests)
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              title: 'Gear Forge',
                              subtitle: '${inv.backpackItems.length} items',
                              icon: Icons.shield,
                              color: const Color(0xFF3498DB),
                              onTap: () => setState(() => _currentTabIndex = 1),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildQuickActionCard(
                              title: 'Talents',
                              subtitle: 'Passives',
                              icon: Icons.auto_awesome,
                              color: const Color(0xFFF1C40F),
                              onTap: () => setState(() => _currentTabIndex = 3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildQuickActionCard(
                              title: 'Cup Pass',
                              subtitle: 'Quests',
                              icon: Icons.emoji_events,
                              color: const Color(0xFFE74C3C),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const QuestsScreen()),
                                );
                              },
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

  Widget _buildTopHeader(PlayerProfileState profile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1B38),
        border: Border(bottom: BorderSide(color: Color(0xFF2C274E), width: 1.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Player Level Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: GameTheme.card3D(
              color: const Color(0xFF5B36D6),
              borderColor: const Color(0xFF8E44AD),
              borderRadius: 12,
              elevation: 2,
            ),
            child: const Row(
              children: [
                Icon(Icons.military_tech, color: Colors.amber, size: 18),
                SizedBox(width: 4),
                Text('LV. 1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
              ],
            ),
          ),

          // Energy Pill (⚡ 20/20)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: GameTheme.currencyPill(),
            child: Row(
              children: [
                const Icon(Icons.flash_on, color: Color(0xFF2ECC71), size: 16),
                const SizedBox(width: 4),
                Text(
                  '${profile.energy}/${profile.maxEnergy}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),

          // Gold Pill (🪙 500)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: GameTheme.currencyPill(),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 16),
                const SizedBox(width: 4),
                Text(
                  '${profile.gold}',
                  style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),

          // Gems Pill (💎 50)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: GameTheme.currencyPill(),
            child: Row(
              children: [
                const Icon(Icons.diamond, color: Color(0xFF29D4FF), size: 16),
                const SizedBox(width: 4),
                Text(
                  '${profile.gems}',
                  style: const TextStyle(color: Color(0xFF29D4FF), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),

          // Sound Toggle
          InkWell(
            onTap: () {
              setState(() {
                AudioManager.instance.toggleSound();
              });
            },
            child: Icon(
              AudioManager.instance.isSoundEnabled ? Icons.volume_up : Icons.volume_off,
              color: Colors.white70,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterBanner(BuildContext context, ChapterModel chapter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: GameTheme.card3D(
        color: const Color(0xFF221F40),
        borderColor: chapter.themeColor,
        borderRadius: 16,
        elevation: 3,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(chapter.icon, color: chapter.themeColor, size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.title.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.8),
                  ),
                  Text(
                    chapter.subtitle,
                    style: TextStyle(color: chapter.themeColor, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChapterSelectScreen()),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF16152B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF453F7A)),
              ),
              child: const Row(
                children: [
                  Text('MAP', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 11)),
                  Icon(Icons.chevron_right, color: Colors.white70, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroPaperDollStage(HeroModel hero, InventoryState inv, int totalHp, int totalAtk) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: GameTheme.card3D(
        color: const Color(0xFF1E1B38),
        borderColor: const Color(0xFF3F3B6C),
        borderRadius: 20,
        elevation: 4,
      ),
      child: Column(
        children: [
          // Paper Doll Grid: Left 3 Slots, Center Pedestal Hero, Right 3 Slots
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Slots: Weapon, Helmet, Armor
              Column(
                children: [
                  _buildPaperDollSlot(EquipmentSlot.weapon, inv.getEquippedItemInSlot(EquipmentSlot.weapon)),
                  const SizedBox(height: 8),
                  _buildPaperDollSlot(EquipmentSlot.helmet, inv.getEquippedItemInSlot(EquipmentSlot.helmet)),
                  const SizedBox(height: 8),
                  _buildPaperDollSlot(EquipmentSlot.armor, inv.getEquippedItemInSlot(EquipmentSlot.armor)),
                ],
              ),

              // Center: Pedestal with Cup Hero Mascot
              Expanded(
                child: Column(
                  children: [
                    // Mascot Pedestal
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pedestal Disc
                        Container(
                          width: 110,
                          height: 35,
                          margin: const EdgeInsets.only(top: 80),
                          decoration: BoxDecoration(
                            gradient: const RadialGradient(
                              colors: [Color(0xFF5B36D6), Color(0xFF16152B)],
                            ),
                            borderRadius: BorderRadius.circular(55),
                            border: Border.all(color: hero.primaryColor, width: 2),
                          ),
                        ),

                        // Animated 3D Cup Hero Figure
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F6FA),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: hero.primaryColor, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: hero.primaryColor.withValues(alpha: 0.5),
                                blurRadius: 18,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(hero.icon, color: hero.primaryColor, size: 36),
                              const SizedBox(height: 2),
                              // Eyes
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(width: 5, height: 5, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
                                  const SizedBox(width: 10),
                                  Container(width: 5, height: 5, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${hero.name} • ${hero.title}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),

              // Right Slots: Boots, Ring, Amulet
              Column(
                children: [
                  _buildPaperDollSlot(EquipmentSlot.boots, inv.getEquippedItemInSlot(EquipmentSlot.boots)),
                  const SizedBox(height: 8),
                  _buildPaperDollSlot(EquipmentSlot.ring, inv.getEquippedItemInSlot(EquipmentSlot.ring)),
                  const SizedBox(height: 8),
                  _buildPaperDollSlot(EquipmentSlot.amulet, inv.getEquippedItemInSlot(EquipmentSlot.amulet)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Total Power / Stats Pill Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF141226),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2C274E)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Color(0xFF2ECC71), size: 16),
                    const SizedBox(width: 6),
                    Text('$totalHp HP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                Container(width: 1, height: 16, color: const Color(0xFF2C274E)),
                Row(
                  children: [
                    const Icon(Icons.colorize, color: Color(0xFFFF9F1A), size: 16),
                    const SizedBox(width: 6),
                    Text('$totalAtk ATK', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                Container(width: 1, height: 16, color: const Color(0xFF2C274E)),
                Row(
                  children: [
                    const Icon(Icons.center_focus_strong, color: Color(0xFFFF4757), size: 16),
                    const SizedBox(width: 6),
                    Text('${((0.08 + inv.totalBonusCritRate) * 100).toInt()}% CRIT', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaperDollSlot(EquipmentSlot slot, EquipmentItem? item) {
    final rarityColor = item != null ? GameTheme.getRarityColor(item.rarity) : const Color(0xFF3F3B6C);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: item != null ? const Color(0xFF221F40) : const Color(0xFF141226),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rarityColor, width: item != null ? 2.0 : 1.0),
        boxShadow: [
          if (item != null)
            BoxShadow(
              color: rarityColor.withValues(alpha: 0.3),
              blurRadius: 6,
            ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            item?.icon ?? _getSlotIcon(slot),
            color: item != null ? rarityColor : Colors.white24,
            size: 22,
          ),
          if (item != null)
            Text(
              'Lv.${item.level}',
              style: TextStyle(color: rarityColor, fontSize: 8, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  Widget _buildBigBattleButton(BuildContext context, ChapterModel chapter, PlayerProfileState profile) {
    return InkWell(
      onTap: () {
        if (profile.consumeEnergy(5)) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BattleScreen(chapter: chapter)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Not enough energy! (Need 5 Energy)')),
          );
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: GameTheme.button3D(
          color: const Color(0xFF2ECC71),
          shadowColor: const Color(0xFF1E8449),
          borderColor: const Color(0xFF58D68D),
          borderRadius: 20,
          elevation: 5,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
            SizedBox(width: 8),
            Text(
              'BATTLE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: 2.0,
                shadows: [
                  Shadow(color: Colors.black38, offset: Offset(0, 2), blurRadius: 2),
                ],
              ),
            ),
            SizedBox(width: 10),
            Text(
              '(⚡ 5)',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
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
        padding: const EdgeInsets.all(12),
        decoration: GameTheme.card3D(
          color: const Color(0xFF1E1B38),
          borderColor: color.withValues(alpha: 0.6),
          borderRadius: 16,
          elevation: 3,
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF191632),
        border: Border(top: BorderSide(color: Color(0xFF2C274E), width: 1.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
        backgroundColor: const Color(0xFF191632),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF5B36D6),
        unselectedItemColor: Colors.white38,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.shield_outlined), activeIcon: Icon(Icons.shield), label: 'Gear'),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_fill, size: 30), label: 'Battle'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_outlined), activeIcon: Icon(Icons.auto_awesome), label: 'Talents'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Heroes'),
        ],
      ),
    );
  }

  IconData _getSlotIcon(EquipmentSlot slot) {
    switch (slot) {
      case EquipmentSlot.weapon:
        return Icons.colorize;
      case EquipmentSlot.helmet:
        return Icons.smart_toy;
      case EquipmentSlot.armor:
        return Icons.shield;
      case EquipmentSlot.boots:
        return Icons.do_not_step;
      case EquipmentSlot.ring:
        return Icons.album;
      case EquipmentSlot.amulet:
        return Icons.diamond;
    }
  }
}
