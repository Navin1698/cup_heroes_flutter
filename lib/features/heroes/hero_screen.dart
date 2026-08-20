import 'package:flutter/material.dart';
import '../../core/constants/color_constants.dart';
import '../../core/theme/ember_theme.dart';
import '../../models/hero_definition.dart';
import '../../repositories/save_repository.dart';

class HeroScreen extends StatefulWidget {
  final HeroDefinition selectedHero;
  final Function(HeroDefinition) onHeroSelected;

  const HeroScreen({
    super.key,
    required this.selectedHero,
    required this.onHeroSelected,
  });

  @override
  State<HeroScreen> createState() => _HeroScreenState();
}

class _HeroScreenState extends State<HeroScreen> {
  final List<HeroDefinition> _allHeroes = HeroDefinition.getAllHeroes();
  late HeroDefinition _currentHero;
  List<String> _unlockedHeroIds = ['arin'];
  Map<String, int> _heroShards = {};

  @override
  void initState() {
    super.initState();
    _currentHero = widget.selectedHero;
    _loadHeroData();
  }

  Future<void> _loadHeroData() async {
    final data = await SaveRepository.instance.loadSaveData();
    setState(() {
      _unlockedHeroIds = (data['unlockedHeroes'] as List<dynamic>).map((e) => e.toString()).toList();
      _heroShards = data['heroShards'] as Map<String, int>;
    });
  }

  int _calculatePower(HeroDefinition hero) {
    return (hero.baseHp * 0.4 + hero.baseAttack * 3.5 + hero.baseDefense * 2.5 + hero.baseCritChance * 200).round();
  }

  @override
  Widget build(BuildContext context) {
    final isUnlocked = _unlockedHeroIds.contains(_currentHero.id);
    final isSelected = widget.selectedHero.id == _currentHero.id;
    final power = _calculatePower(_currentHero);
    final shards = _heroShards[_currentHero.id] ?? 0;

    return Scaffold(
      backgroundColor: EmberColors.background,
      appBar: AppBar(
        backgroundColor: EmberColors.surface,
        title: const Text(
          'HERO ROSTER',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white, letterSpacing: 1.2),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Horizontal Hero Selection Avatars
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _allHeroes.length,
                itemBuilder: (context, index) {
                  final hero = _allHeroes[index];
                  final isHeroSelected = _currentHero.id == hero.id;
                  final unlocked = _unlockedHeroIds.contains(hero.id);

                  return GestureDetector(
                    onTap: () => setState(() => _currentHero = hero),
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: EmberTheme.crystalCard(
                        color: isHeroSelected ? EmberColors.surfaceLight : EmberColors.surface,
                        borderColor: isHeroSelected ? hero.primaryColor : EmberColors.surfaceBorder,
                        borderRadius: 16,
                        glow: isHeroSelected,
                        glowColor: hero.primaryColor,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(hero.icon, color: unlocked ? hero.primaryColor : Colors.white24, size: 28),
                          const SizedBox(height: 4),
                          Text(
                            hero.name,
                            style: TextStyle(
                              color: unlocked ? Colors.white : Colors.white38,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Hero Showcase Card
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  children: [
                    // Main Showcase Box
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: EmberTheme.crystalCard(
                        color: EmberColors.surface,
                        borderColor: _currentHero.primaryColor,
                        borderRadius: 24,
                        glow: true,
                        glowColor: _currentHero.primaryColor,
                      ),
                      child: Column(
                        children: [
                          // Avatar and Titles
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: _currentHero.primaryColor.withValues(alpha: 0.2),
                            child: Icon(_currentHero.icon, color: _currentHero.primaryColor, size: 44),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _currentHero.name,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5),
                          ),
                          Text(
                            _currentHero.title,
                            style: TextStyle(color: _currentHero.primaryColor, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _currentHero.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: EmberColors.textSecondary, fontSize: 11),
                          ),
                          const SizedBox(height: 14),

                          // Power Score Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: EmberColors.surfaceLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: EmberColors.accent),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.flash_on, color: EmberColors.accent, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'POWER $power',
                                  style: const TextStyle(color: EmberColors.accent, fontWeight: FontWeight.w900, fontSize: 13),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Stats Grid
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem('HP', '${_currentHero.baseHp}', EmberColors.success),
                              _buildStatItem('ATK', '${_currentHero.baseAttack}', EmberColors.secondary),
                              _buildStatItem('DEF', '${_currentHero.baseDefense}', EmberColors.accent),
                              _buildStatItem('CRIT', '${(_currentHero.baseCritChance * 100).toInt()}%', EmberColors.danger),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Unique Abilities Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: EmberTheme.crystalCard(
                        color: EmberColors.surface,
                        borderRadius: 18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HERO ABILITIES',
                            style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                          ),
                          const SizedBox(height: 10),
                          _buildAbilityRow(
                            'Special: ${_currentHero.specialAbilityName}',
                            _currentHero.specialAbilityDesc,
                            _currentHero.primaryColor,
                          ),
                          const SizedBox(height: 10),
                          _buildAbilityRow(
                            'Ultimate: ${_currentHero.ultimateAbilityName}',
                            _currentHero.ultimateAbilityDesc,
                            EmberColors.accent,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Action Button (Select Hero / Unlock with Shards)
                    if (isUnlocked)
                      InkWell(
                        onTap: isSelected
                            ? null
                            : () {
                                widget.onHeroSelected(_currentHero);
                                SaveRepository.instance.saveSelectedHero(_currentHero.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Selected ${_currentHero.name}!')),
                                );
                              },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: isSelected
                              ? BoxDecoration(
                                  color: const Color(0xFF1E2442),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: EmberColors.success),
                                )
                              : EmberTheme.primaryButton(borderRadius: 16),
                          child: Center(
                            child: Text(
                              isSelected ? 'EQUIPPED' : 'SELECT HERO',
                              style: TextStyle(
                                color: isSelected ? EmberColors.success : Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      InkWell(
                        onTap: shards >= _currentHero.shardUnlockCost
                            ? () {
                                SaveRepository.instance.unlockHero(_currentHero.id);
                                _loadHeroData();
                              }
                            : null,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: shards >= _currentHero.shardUnlockCost ? EmberColors.secondary : const Color(0xFF232845),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              'UNLOCK ($shards/${_currentHero.shardUnlockCost} SHARDS)',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: EmberColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAbilityRow(String title, String desc, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 2),
        Text(desc, style: const TextStyle(color: EmberColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}
