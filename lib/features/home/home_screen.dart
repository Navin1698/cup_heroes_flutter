import 'package:flutter/material.dart';
import '../../core/constants/color_constants.dart';
import '../../core/constants/game_constants.dart';
import '../../core/theme/ember_theme.dart';
import '../../models/hero_definition.dart';
import '../../models/world_definition.dart';
import '../../repositories/save_repository.dart';
import '../battle/battle_screen.dart';
import '../battle/dual_battle_screen.dart';
import '../battle/ball_drop_sandbox_screen.dart';
import '../heroes/hero_screen.dart';
import '../inventory/inventory_screen.dart';
import '../shop/shop_screen.dart';
import '../world_map/world_map_screen.dart';
import 'widgets/crystal_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 2; // Default to Center Battle/Home Hub

  HeroDefinition _selectedHero = HeroDefinition.getAllHeroes().first;
  final WorldDefinition _world = WorldDefinition.getWhisperingMeadow();
  int _gold = 500;
  int _gems = 80;
  int _energy = 20;
  int _playerLevel = 1;
  int _highestStage = 1;

  @override
  void initState() {
    super.initState();
    _loadSaveData();
  }

  Future<void> _loadSaveData() async {
    final data = await SaveRepository.instance.loadSaveData();
    final allHeroes = HeroDefinition.getAllHeroes();
    final heroId = data['selectedHero'] as String;

    setState(() {
      _gold = data['gold'] as int;
      _gems = data['gems'] as int;
      _energy = data['energy'] as int;
      _playerLevel = data['playerLevel'] as int;
      _highestStage = data['highestStage'] as int;
      _selectedHero = allHeroes.firstWhere((h) => h.id == heroId, orElse: () => allHeroes.first);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EmberColors.background,
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          HeroScreen(
            selectedHero: _selectedHero,
            onHeroSelected: (hero) {
              setState(() => _selectedHero = hero);
            },
          ),
          const InventoryScreen(),
          _buildMainAdventureHub(context),
          WorldMapScreen(selectedHero: _selectedHero),
          const ShopScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildMainAdventureHub(BuildContext context) {
    final currentStage = _world.stages.firstWhere(
      (s) => s.stageNumber == _highestStage.clamp(1, _world.stages.length),
      orElse: () => _world.stages.first,
    );

    return Stack(
      children: [
        // 1. Animated Crystal Particles Background
        const CrystalBackground(),

        // 2. Main Content
        SafeArea(
          child: Column(
            children: [
              // Top Currency Bar
              _buildTopHeader(),

              // Central Hero Stage
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: [
                      // Current World & Stage Banner
                      _buildStageBanner(currentStage),

                      const SizedBox(height: 24),

                      // Hero Avatar Pedestal
                      _buildHeroShowcaseStage(),

                      const SizedBox(height: 28),

                      // Big Gradient Play Button (ENTER ADVENTURE)
                      _buildBigAdventureButton(context, currentStage),

                      const SizedBox(height: 20),

                      // Quick Action Cards (World Map & Shop)
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              title: 'World Map',
                              subtitle: '5 Stages',
                              icon: Icons.map,
                              color: EmberColors.secondary,
                              onTap: () => setState(() => _currentTabIndex = 3),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionCard(
                              title: 'Equipment',
                              subtitle: '6 Slots',
                              icon: Icons.shield,
                              color: EmberColors.accent,
                              onTap: () => setState(() => _currentTabIndex = 1),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: EmberColors.surface,
        border: Border(bottom: BorderSide(color: EmberColors.surfaceBorder, width: 1.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Player Level Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: EmberColors.primary.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: EmberColors.primary),
            ),
            child: Row(
              children: [
                const Icon(Icons.military_tech, color: EmberColors.accent, size: 16),
                const SizedBox(width: 4),
                Text('LV. $_playerLevel', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),

          // Energy Pill (⚡ 20/20)
          _buildCurrencyPill(Icons.flash_on, '$_energy/${GameConstants.maxEnergy}', EmberColors.success),

          // Gold Pill (🪙 500)
          _buildCurrencyPill(Icons.monetization_on, '$_gold', EmberColors.accent),

          // Gems Pill (💎 80)
          _buildCurrencyPill(Icons.diamond, '$_gems', EmberColors.secondary),
        ],
      ),
    );
  }

  Widget _buildCurrencyPill(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1326),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: EmberColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStageBanner(StageDefinition stage) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: EmberTheme.crystalCard(
        color: EmberColors.surface,
        borderColor: EmberColors.success,
        borderRadius: 18,
        elevation: 3,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: EmberColors.success.withValues(alpha: 0.2),
              border: Border.all(color: EmberColors.success),
            ),
            child: Icon(stage.icon, color: EmberColors.success, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STAGE ${stage.stageNumber}: ${stage.name.toUpperCase()}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.0),
                ),
                Text(
                  stage.description,
                  style: const TextStyle(color: EmberColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroShowcaseStage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: EmberTheme.crystalCard(
        color: EmberColors.surface,
        borderColor: _selectedHero.primaryColor,
        borderRadius: 24,
        glow: true,
        glowColor: _selectedHero.primaryColor,
      ),
      child: Column(
        children: [
          // Mascot Avatar Pedestal
          CircleAvatar(
            radius: 46,
            backgroundColor: _selectedHero.primaryColor.withValues(alpha: 0.2),
            child: Icon(_selectedHero.icon, color: _selectedHero.primaryColor, size: 52),
          ),
          const SizedBox(height: 12),
          Text(
            _selectedHero.name,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
          Text(
            _selectedHero.title,
            style: TextStyle(color: _selectedHero.primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),

          // Stat Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMiniStatBadge(Icons.favorite, '${_selectedHero.baseHp} HP', EmberColors.success),
              const SizedBox(width: 12),
              _buildMiniStatBadge(Icons.colorize, '${_selectedHero.baseAttack} ATK', EmberColors.secondary),
              const SizedBox(width: 12),
              _buildMiniStatBadge(Icons.shield, '${_selectedHero.baseDefense} DEF', EmberColors.accent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF101328),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBigAdventureButton(BuildContext context, StageDefinition stage) {
    return Column(
      children: [
        // 1. PRIMARY: Cup Heroes Dual-Screen Battle (Plinko + Wave Combat)
        InkWell(
          onTap: () {
            if (_energy >= GameConstants.stageEnergyCost) {
              setState(() => _energy -= GameConstants.stageEnergyCost);
              SaveRepository.instance.saveCurrencies(gold: _gold, gems: _gems, energy: _energy);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DualBattleScreen(hero: _selectedHero, stage: stage),
                ),
              ).then((_) => _loadSaveData());
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Not enough Energy! (Requires 5 Energy)')),
              );
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            height: 62,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9900), Color(0xFFFF2A85), Color(0xFF7928CA)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF2A85).withValues(alpha: 0.5),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_esports, color: Colors.white, size: 32),
                SizedBox(width: 10),
                Text(
                  'CUP HEROES BATTLE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '(⚡ 5)',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 2. Secondary Modes: Action RPG & Plinko Sandbox
        Row(
          children: [
            // Action RPG Mode
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BattleScreen(hero: _selectedHero, stage: stage),
                    ),
                  ).then((_) => _loadSaveData());
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: EmberColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: EmberColors.primary.withValues(alpha: 0.6)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.gamepad, color: EmberColors.secondary, size: 16),
                      SizedBox(width: 6),
                      Text('Action RPG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Plinko Sandbox Mode
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BallDropSandboxScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: EmberColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.6)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bubble_chart, color: Color(0xFF00E5FF), size: 16),
                      SizedBox(width: 6),
                      Text('Plinko Sandbox', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
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
        decoration: EmberTheme.crystalCard(
          color: EmberColors.surface,
          borderColor: color.withValues(alpha: 0.5),
          borderRadius: 16,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                Text(subtitle, style: const TextStyle(color: EmberColors.textSecondary, fontSize: 10)),
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
        color: EmberColors.surface,
        border: Border(top: BorderSide(color: EmberColors.surfaceBorder, width: 1.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
        backgroundColor: EmberColors.surface,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: EmberColors.secondary,
        unselectedItemColor: Colors.white38,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Heroes'),
          BottomNavigationBarItem(icon: Icon(Icons.shield_outlined), activeIcon: Icon(Icons.shield), label: 'Gear'),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_fill, size: 34), label: 'Adventure'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'World'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: 'Shop'),
        ],
      ),
    );
  }
}
