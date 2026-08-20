import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/game_constants.dart';
import '../core/theme/game_theme.dart';
import '../models/equipment_model.dart';
import '../state/inventory_state.dart';
import '../state/player_profile_state.dart';

class EquipmentScreen extends StatelessWidget {
  const EquipmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameConstants.darkBg,
      body: SafeArea(
        child: Consumer2<InventoryState, PlayerProfileState>(
          builder: (context, invState, profileState, child) {
            return Column(
              children: [
                // Top Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'EQUIPMENT & GEAR',
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

                // Paper-Doll Equipped Slots & Stat Summary
                _buildPaperDollSection(context, invState, profileState),

                const SizedBox(height: 12),

                // Inventory Grid Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BACKPACK INVENTORY (${invState.backpackItems.length})',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const Text(
                        'Merge 3 Same Items to Fuse',
                        style: TextStyle(color: Colors.amberAccent, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Backpack Grid
                Expanded(
                  child: invState.backpackItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 48, color: Colors.white.withOpacity(0.2)),
                              const SizedBox(height: 8),
                              const Text(
                                'No extra gear in backpack.\nOpen chests in the Shop to find rare loot!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white38, fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: invState.backpackItems.length,
                          itemBuilder: (context, index) {
                            final item = invState.backpackItems[index];
                            return _buildItemTile(context, item, isEquipped: false, invState: invState, profileState: profileState);
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

  Widget _buildPaperDollSection(
    BuildContext context,
    InventoryState invState,
    PlayerProfileState profileState,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: GameTheme.cardDecoration(
        color: const Color(0xFF1E1B38),
        borderColor: const Color(0xFF3F3B6C),
        borderWidth: 2,
        borderRadius: 20,
      ),
      child: Column(
        children: [
          // Stat Summary Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF141226),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite, color: GameConstants.hpGreen, size: 16),
                    const SizedBox(width: 4),
                    Text('+${invState.totalBonusHp} HP', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.colorize, color: Colors.orangeAccent, size: 16),
                    const SizedBox(width: 4),
                    Text('+${invState.totalBonusAttack} ATK', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.center_focus_strong, color: Colors.redAccent, size: 16),
                    const SizedBox(width: 4),
                    Text('+${(invState.totalBonusCritRate * 100).toInt()}% CRIT', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 6 Equipment Slots Row (Weapon, Helmet, Armor, Boots, Ring, Amulet)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: EquipmentSlot.values.map((slot) {
              final item = invState.getEquippedItemInSlot(slot);
              return _buildEquipSlot(context, slot, item, invState, profileState);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipSlot(
    BuildContext context,
    EquipmentSlot slot,
    EquipmentItem? item,
    InventoryState invState,
    PlayerProfileState profileState,
  ) {
    final rarityColor = item != null ? GameTheme.getRarityColor(item.rarity) : Colors.white24;

    return InkWell(
      onTap: item != null ? () => _showItemModal(context, item, isEquipped: true, invState: invState, profileState: profileState) : null,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 50,
        height: 58,
        decoration: BoxDecoration(
          color: item != null ? const Color(0xFF28234D) : const Color(0xFF141226),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: rarityColor, width: item != null ? 2.0 : 1.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item?.icon ?? _getSlotPlaceholderIcon(slot),
              color: item != null ? rarityColor : Colors.white24,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              item != null ? 'Lv.${item.level}' : _getSlotName(slot),
              style: TextStyle(
                color: item != null ? Colors.white70 : Colors.white24,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemTile(
    BuildContext context,
    EquipmentItem item, {
    required bool isEquipped,
    required InventoryState invState,
    required PlayerProfileState profileState,
  }) {
    final rarityColor = GameTheme.getRarityColor(item.rarity);

    return InkWell(
      onTap: () => _showItemModal(context, item, isEquipped: isEquipped, invState: invState, profileState: profileState),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1B38),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: rarityColor, width: 2),
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: rarityColor, size: 28),
            const SizedBox(height: 4),
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
            Text(
              'Lv.${item.level}',
              style: TextStyle(color: rarityColor, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showItemModal(
    BuildContext context,
    EquipmentItem item, {
    required bool isEquipped,
    required InventoryState invState,
    required PlayerProfileState profileState,
  }) {
    final rarityColor = GameTheme.getRarityColor(item.rarity);
    final upgradeCost = item.upgradeCostGold;

    // Check merge capability
    final matchingCount = invState.backpackItems.where((e) => e.slot == item.slot && e.rarity == item.rarity).length;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF1E1B38),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Color(0xFF3F3B6C), width: 2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: rarityColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: rarityColor, width: 2),
                    ),
                    child: Icon(item.icon, color: rarityColor, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          '${GameTheme.getRarityName(item.rarity)} • ${_getSlotName(item.slot)} • Lv.${item.level}',
                          style: TextStyle(color: rarityColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Stats List
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF141226),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    if (item.bonusHp > 0)
                      _buildModalStatRow('Health Bonus', '+${item.effectiveHp} HP', GameConstants.hpGreen),
                    if (item.bonusAttack > 0)
                      _buildModalStatRow('Attack Power', '+${item.effectiveAttack} ATK', Colors.orangeAccent),
                    if (item.bonusCritRate > 0)
                      _buildModalStatRow('Critical Chance', '+${(item.bonusCritRate * 100).toInt()}%', Colors.redAccent),
                    if (item.specialEffect.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text('Special: ${item.specialEffect}', style: const TextStyle(color: Colors.amberAccent, fontSize: 12)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  // Equip / Unequip
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (isEquipped) {
                          invState.unequipItem(item.slot);
                        } else {
                          invState.equipItem(item);
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEquipped ? const Color(0xFF3F3B6C) : GameConstants.primaryPurple,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(isEquipped ? 'UNEQUIP' : 'EQUIP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Upgrade Level
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (profileState.spendGold(upgradeCost)) {
                          invState.upgradeItem(item);
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not enough gold to upgrade!')));
                        }
                      },
                      icon: const Icon(Icons.arrow_upward, size: 16, color: GameConstants.goldColor),
                      label: Text('UPGRADE ($upgradeCost G)', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27AE60),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),

              // Fuse 3 items button (if not mythic and has 3 items)
              if (!isEquipped && item.rarity != ItemRarity.mythic && matchingCount >= 3) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (invState.fuseItems(item)) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Items Fused into Higher Rarity! ✨')),
                        );
                      }
                    },
                    icon: const Icon(Icons.auto_awesome, color: Colors.amber),
                    label: Text('FUSE 3 INTO ${GameTheme.getRarityName(ItemRarity.values[item.rarity.index + 1]).toUpperCase()}',
                        style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C274E),
                      side: const BorderSide(color: Colors.amber, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  IconData _getSlotPlaceholderIcon(EquipmentSlot slot) {
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

  String _getSlotName(EquipmentSlot slot) {
    switch (slot) {
      case EquipmentSlot.weapon:
        return 'Weapon';
      case EquipmentSlot.helmet:
        return 'Helmet';
      case EquipmentSlot.armor:
        return 'Armor';
      case EquipmentSlot.boots:
        return 'Boots';
      case EquipmentSlot.ring:
        return 'Ring';
      case EquipmentSlot.amulet:
        return 'Amulet';
    }
  }
}
