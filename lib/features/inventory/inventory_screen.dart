import 'package:flutter/material.dart';
import '../../core/constants/color_constants.dart';
import '../../core/theme/ember_theme.dart';
import '../../models/equipment_definition.dart';
import '../../repositories/save_repository.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final List<EquipmentDefinition> _inventory = EquipmentDefinition.getStarterEquipment();
  EquipmentDefinition? _selectedItem;
  int _playerGold = 500;

  @override
  void initState() {
    super.initState();
    _loadGold();
  }

  Future<void> _loadGold() async {
    final data = await SaveRepository.instance.loadSaveData();
    setState(() {
      _playerGold = data['gold'] as int;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EmberColors.background,
      appBar: AppBar(
        backgroundColor: EmberColors.surface,
        title: const Text(
          'EQUIPMENT & INVENTORY',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white, letterSpacing: 1.2),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: EmberColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: EmberColors.accent),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: EmberColors.accent, size: 16),
                const SizedBox(width: 4),
                Text('$_playerGold', style: const TextStyle(color: EmberColors.accent, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top: 6-Slot Paper Doll Display
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: EmberTheme.crystalCard(
                color: EmberColors.surface,
                borderRadius: 20,
              ),
              child: Column(
                children: [
                  const Text(
                    'EQUIPPED GEAR',
                    style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPaperDollSlot(EquipmentSlot.weapon),
                      _buildPaperDollSlot(EquipmentSlot.helmet),
                      _buildPaperDollSlot(EquipmentSlot.armor),
                      _buildPaperDollSlot(EquipmentSlot.boots),
                      _buildPaperDollSlot(EquipmentSlot.ring),
                      _buildPaperDollSlot(EquipmentSlot.crystalCore),
                    ],
                  ),
                ],
              ),
            ),

            // Backpack Inventory Grid
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: EmberTheme.crystalCard(
                  color: EmberColors.surface,
                  borderRadius: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BACKPACK ITEMS',
                      style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: _inventory.length,
                        itemBuilder: (context, index) {
                          final item = _inventory[index];
                          final isSelected = _selectedItem?.id == item.id;

                          return GestureDetector(
                            onTap: () => setState(() => _selectedItem = item),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? EmberColors.surfaceLight : const Color(0xFF101328),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? EmberColors.secondary : item.rarityColor,
                                  width: isSelected ? 2.5 : 1.5,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: EmberColors.secondary.withValues(alpha: 0.4),
                                      blurRadius: 10,
                                    ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(item.icon, color: item.rarityColor, size: 26),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Lv.${item.level}',
                                    style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Item Upgrade Bottom Sheet
            if (_selectedItem != null) _buildItemUpgradeSheet(_selectedItem!),
          ],
        ),
      ),
    );
  }

  Widget _buildPaperDollSlot(EquipmentSlot slot) {
    final item = _inventory.firstWhere((i) => i.slot == slot, orElse: () => _inventory.first);

    return GestureDetector(
      onTap: () => setState(() => _selectedItem = item),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: EmberColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: item.rarityColor, width: 2.0),
        ),
        child: Center(
          child: Icon(item.icon, color: item.rarityColor, size: 22),
        ),
      ),
    );
  }

  Widget _buildItemUpgradeSheet(EquipmentDefinition item) {
    final canUpgrade = _playerGold >= item.upgradeCostGold;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: EmberColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: EmberColors.surfaceBorder, width: 1.5)),
      ),
      child: Row(
        children: [
          Icon(item.icon, color: item.rarityColor, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                Text(
                  'ATK: +${item.currentAttack} • HP: +${item.currentHp}',
                  style: const TextStyle(color: EmberColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: canUpgrade
                ? () {
                    setState(() {
                      _playerGold -= item.upgradeCostGold;
                      item.level++;
                    });
                    SaveRepository.instance.saveCurrencies(gold: _playerGold, gems: 80, energy: 20);
                  }
                : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: canUpgrade ? EmberColors.accent : const Color(0xFF2B2E42),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'UPGRADE (${item.upgradeCostGold}G)',
                style: TextStyle(
                  color: canUpgrade ? const Color(0xFF151A38) : Colors.white38,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
