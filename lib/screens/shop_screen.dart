import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/game_constants.dart';
import '../core/theme/game_theme.dart';
import '../models/equipment_model.dart';
import '../state/player_profile_state.dart';
import '../state/inventory_state.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  void _openChest(
    BuildContext context, {
    required ItemRarity guaranteedRarity,
    required InventoryState invState,
  }) {
    final rng = Random();
    final slots = EquipmentSlot.values;
    final slot = slots[rng.nextInt(slots.length)];

    final itemNames = {
      EquipmentSlot.weapon: ['Shadow Blade', 'Dragon Cleaver', 'Storm Bow', 'Arcane Wand'],
      EquipmentSlot.helmet: ['Iron Helm', 'Ranger Hood', 'Crown of Embers', 'Titan Crest'],
      EquipmentSlot.armor: ['Plate Mail', 'Shadow Cloak', 'Phoenix Robe', 'Dragon Scale'],
      EquipmentSlot.boots: ['Swift Treads', 'Wind Walkers', 'Heavy Sabatons', 'Feathered Boots'],
      EquipmentSlot.ring: ['Ruby Signet', 'Topaz Ring', 'Band of Power', 'Ring of Agility'],
      EquipmentSlot.amulet: ['Heart Talisman', 'Amulet of Speed', 'Eye of Odin', 'Star Pendant'],
    };

    final icons = {
      EquipmentSlot.weapon: Icons.colorize,
      EquipmentSlot.helmet: Icons.smart_toy,
      EquipmentSlot.armor: Icons.shield,
      EquipmentSlot.boots: Icons.do_not_step,
      EquipmentSlot.ring: Icons.album,
      EquipmentSlot.amulet: Icons.diamond,
    };

    final nameList = itemNames[slot]!;
    final name = nameList[rng.nextInt(nameList.length)];

    final newItem = EquipmentItem(
      id: 'gear_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      slot: slot,
      rarity: guaranteedRarity,
      level: 1,
      bonusHp: slot == EquipmentSlot.armor || slot == EquipmentSlot.helmet ? 150 : 40,
      bonusAttack: slot == EquipmentSlot.weapon || slot == EquipmentSlot.ring ? 35 : 15,
      bonusCritRate: slot == EquipmentSlot.ring ? 0.08 : 0.02,
      bonusAttackSpeed: slot == EquipmentSlot.boots ? 0.06 : 0.0,
      icon: icons[slot]!,
      specialEffect: 'Forged from magical loot',
    );

    invState.addItemToBackpack(newItem);

    final rarityColor = GameTheme.getRarityColor(newItem.rarity);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1B38),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: rarityColor, width: 2),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('CHEST UNLOCKED! ✨', style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: rarityColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: rarityColor, width: 2.5),
                ),
                child: Icon(newItem.icon, color: rarityColor, size: 38),
              ),
              const SizedBox(height: 12),
              Text(newItem.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                '${GameTheme.getRarityName(newItem.rarity)} • Lv.1',
                style: TextStyle(color: rarityColor, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Added to your backpack!',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GameConstants.primaryPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('AWESOME!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameConstants.darkBg,
      body: SafeArea(
        child: Consumer2<PlayerProfileState, InventoryState>(
          builder: (context, profileState, invState, child) {
            return Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'MERCHANT & CHESTS',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.monetization_on, color: GameConstants.goldColor, size: 18),
                          const SizedBox(width: 4),
                          Text('${profileState.gold}', style: const TextStyle(color: GameConstants.goldColor, fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(width: 12),
                          const Icon(Icons.diamond, color: GameConstants.gemColor, size: 18),
                          const SizedBox(width: 4),
                          Text('${profileState.gems}', style: const TextStyle(color: GameConstants.gemColor, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Shop Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      // Section 1: Loot Chests
                      const Text('MYSTIC CHESTS', style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          // Wooden / Common Chest
                          Expanded(
                            child: _buildChestCard(
                              context,
                              title: 'Wooden Chest',
                              subtitle: 'Common or Rare Gear',
                              icon: Icons.all_inbox,
                              color: const Color(0xFF8D6E63),
                              costText: '300 GOLD',
                              costIcon: Icons.monetization_on,
                              costColor: GameConstants.goldColor,
                              onOpen: () {
                                if (profileState.spendGold(300)) {
                                  final rarity = Random().nextBool() ? ItemRarity.common : ItemRarity.uncommon;
                                  _openChest(context, guaranteedRarity: rarity, invState: invState);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not enough gold!')));
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Epic Royal Chest
                          Expanded(
                            child: _buildChestCard(
                              context,
                              title: 'Royal Chest',
                              subtitle: 'Rare or Epic Gear',
                              icon: Icons.auto_awesome_motion,
                              color: const Color(0xFFFFA502),
                              costText: '60 GEMS',
                              costIcon: Icons.diamond,
                              costColor: GameConstants.gemColor,
                              onOpen: () {
                                if (profileState.spendGems(60)) {
                                  final r = Random().nextDouble();
                                  final rarity = (r < 0.6) ? ItemRarity.rare : ((r < 0.9) ? ItemRarity.epic : ItemRarity.legendary);
                                  _openChest(context, guaranteedRarity: rarity, invState: invState);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not enough gems!')));
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Section 2: Daily Free Rewards
                      const Text('DAILY REWARDS', style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: GameTheme.cardDecoration(
                          color: const Color(0xFF1E1B38),
                          borderColor: const Color(0xFF3F3B6C),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.card_giftcard, color: Colors.greenAccent, size: 30),
                                SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Free Daily Supply', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                    Text('+200 Gold & +10 Energy', style: TextStyle(color: Colors.white60, fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                profileState.addGold(200);
                                profileState.restoreEnergy(10);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Claimed +200 Gold & +10 Energy! 🎁')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF27AE60),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('CLAIM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Section 3: Currency Bundles
                      const Text('CURRENCY VAULT', style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                      const SizedBox(height: 10),

                      _buildCurrencyRow(
                        title: 'Bag of 1,000 Gold',
                        cost: '20 GEMS',
                        icon: Icons.monetization_on,
                        iconColor: GameConstants.goldColor,
                        onBuy: () {
                          if (profileState.spendGems(20)) {
                            profileState.addGold(1000);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('+1,000 Gold Added!')));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not enough gems!')));
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildCurrencyRow(
                        title: 'Refill Full Energy (20)',
                        cost: '10 GEMS',
                        icon: Icons.flash_on,
                        iconColor: GameConstants.energyColor,
                        onBuy: () {
                          if (profileState.spendGems(10)) {
                            profileState.restoreEnergy(20);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Energy Fully Restored!')));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not enough gems!')));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildChestCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String costText,
    required IconData costIcon,
    required Color costColor,
    required VoidCallback onOpen,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: GameTheme.cardDecoration(
        color: const Color(0xFF1E1B38),
        borderColor: color,
        borderWidth: 2,
        borderRadius: 18,
        glow: true,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 44),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 11), textAlign: TextAlign.center),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onOpen,
            icon: Icon(costIcon, color: costColor, size: 14),
            label: Text(costText, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C274E),
              side: BorderSide(color: color),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyRow({
    required String title,
    required String cost,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onBuy,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: GameTheme.cardDecoration(
        color: const Color(0xFF1E1B38),
        borderColor: const Color(0xFF3F3B6C),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          ElevatedButton(
            onPressed: onBuy,
            style: ElevatedButton.styleFrom(
              backgroundColor: GameConstants.primaryPurple,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(cost, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
