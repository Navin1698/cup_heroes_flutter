import 'package:flutter/material.dart';
import '../../core/constants/color_constants.dart';
import '../../core/theme/ember_theme.dart';
import '../../repositories/save_repository.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _gold = 500;
  int _gems = 80;
  bool _claimedDaily = false;

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    final data = await SaveRepository.instance.loadSaveData();
    setState(() {
      _gold = data['gold'] as int;
      _gems = data['gems'] as int;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EmberColors.background,
      appBar: AppBar(
        backgroundColor: EmberColors.surface,
        title: const Text(
          'CRYSTAL SHOP',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white, letterSpacing: 1.2),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Free Daily Supplies Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: EmberTheme.crystalCard(
                  color: EmberColors.surface,
                  borderColor: EmberColors.success,
                  borderRadius: 20,
                  glow: !_claimedDaily,
                  glowColor: EmberColors.success,
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Color(0xFF1B3B2B),
                      child: Icon(Icons.card_giftcard, color: EmberColors.success, size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DAILY SUPPLIES', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('+250 Gold & +10 Energy', style: TextStyle(color: EmberColors.textSecondary, fontSize: 11)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _claimedDaily
                          ? null
                          : () {
                              setState(() {
                                _gold += 250;
                                _claimedDaily = true;
                              });
                              SaveRepository.instance.saveCurrencies(gold: _gold, gems: _gems, energy: 20);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Claimed daily supply rewards! 🎁')),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: EmberColors.success,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        _claimedDaily ? 'CLAIMED' : 'FREE',
                        style: const TextStyle(color: Color(0xFF101426), fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Mystery Chests Section
              const Text(
                'MYSTERY CHESTS',
                style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _buildChestCard(
                      title: 'Crystal Chest',
                      subtitle: 'Rare+ Gear',
                      costText: '100 Gold',
                      icon: Icons.inventory_2,
                      color: EmberColors.secondary,
                      onTap: () {
                        if (_gold >= 100) {
                          setState(() => _gold -= 100);
                          SaveRepository.instance.saveCurrencies(gold: _gold, gems: _gems, energy: 20);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opened Crystal Chest! Received Rare Blade! ⚔️')),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildChestCard(
                      title: 'Royal Chest',
                      subtitle: 'Epic/Legendary',
                      costText: '30 Gems',
                      icon: Icons.auto_awesome,
                      color: EmberColors.accent,
                      onTap: () {
                        if (_gems >= 30) {
                          setState(() => _gems -= 30);
                          SaveRepository.instance.saveCurrencies(gold: _gold, gems: _gems, energy: 20);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opened Royal Chest! Received Epic Ring! 💍')),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Gem Packs
              const Text(
                'GEM VAULT',
                style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0),
              ),
              const SizedBox(height: 10),

              _buildCurrencyPack('Pouch of Gems', '50 Gems', '+50 Gems', EmberColors.secondary, () {
                setState(() => _gems += 50);
                SaveRepository.instance.saveCurrencies(gold: _gold, gems: _gems, energy: 20);
              }),
              const SizedBox(height: 10),
              _buildCurrencyPack('Chest of Gold', '1,000 Gold', '+1,000 Gold', EmberColors.accent, () {
                setState(() => _gold += 1000);
                SaveRepository.instance.saveCurrencies(gold: _gold, gems: _gems, energy: 20);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChestCard({
    required String title,
    required String subtitle,
    required String costText,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: EmberTheme.crystalCard(
          color: EmberColors.surface,
          borderColor: color,
          borderRadius: 18,
          glow: true,
          glowColor: color,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            Text(subtitle, style: const TextStyle(color: EmberColors.textSecondary, fontSize: 10)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color),
              ),
              child: Text(costText, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyPack(String name, String amount, String btnText, Color color, VoidCallback onBuy) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: EmberTheme.crystalCard(
        color: EmberColors.surface,
        borderRadius: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.diamond, color: color, size: 24),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(amount, style: const TextStyle(color: EmberColors.textSecondary, fontSize: 11)),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: onBuy,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(btnText, style: const TextStyle(color: Color(0xFF101426), fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
