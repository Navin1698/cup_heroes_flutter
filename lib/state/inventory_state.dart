import 'package:flutter/foundation.dart';
import '../core/constants/game_constants.dart';
import '../models/equipment_model.dart';
import '../core/storage/storage_service.dart';

class InventoryState extends ChangeNotifier {
  List<EquipmentItem> _equippedItems = [];
  List<EquipmentItem> _backpackItems = [];

  List<EquipmentItem> get equippedItems => _equippedItems;
  List<EquipmentItem> get backpackItems => _backpackItems;

  EquipmentItem? getEquippedItemInSlot(EquipmentSlot slot) {
    try {
      return _equippedItems.firstWhere((e) => e.slot == slot);
    } catch (_) {
      return null;
    }
  }

  // Combined Stats from Equipped Gear
  int get totalBonusHp => _equippedItems.fold(0, (sum, item) => sum + item.effectiveHp);
  int get totalBonusAttack => _equippedItems.fold(0, (sum, item) => sum + item.effectiveAttack);
  double get totalBonusCritRate => _equippedItems.fold(0.0, (sum, item) => sum + item.bonusCritRate);
  double get totalBonusAttackSpeed => _equippedItems.fold(0.0, (sum, item) => sum + item.bonusAttackSpeed);

  Future<void> loadInventory() async {
    _equippedItems = await StorageService.loadEquippedGear();
    _backpackItems = await StorageService.loadInventoryGear();
    notifyListeners();
  }

  void equipItem(EquipmentItem item) {
    // Remove if already equipped in slot
    final existingIndex = _equippedItems.indexWhere((e) => e.slot == item.slot);
    if (existingIndex >= 0) {
      final oldItem = _equippedItems[existingIndex];
      _equippedItems.removeAt(existingIndex);
      _backpackItems.add(oldItem);
    }

    _backpackItems.removeWhere((e) => e.id == item.id);
    _equippedItems.add(item);

    _save();
    notifyListeners();
  }

  void unequipItem(EquipmentSlot slot) {
    final index = _equippedItems.indexWhere((e) => e.slot == slot);
    if (index >= 0) {
      final item = _equippedItems.removeAt(index);
      _backpackItems.add(item);
      _save();
      notifyListeners();
    }
  }

  void addItemToBackpack(EquipmentItem item) {
    _backpackItems.add(item);
    _save();
    notifyListeners();
  }

  bool upgradeItem(EquipmentItem item) {
    final newLevel = item.level + 1;
    final updated = item.copyWith(level: newLevel);

    final eqIndex = _equippedItems.indexWhere((e) => e.id == item.id);
    if (eqIndex >= 0) {
      _equippedItems[eqIndex] = updated;
      _save();
      notifyListeners();
      return true;
    }

    final bpIndex = _backpackItems.indexWhere((e) => e.id == item.id);
    if (bpIndex >= 0) {
      _backpackItems[bpIndex] = updated;
      _save();
      notifyListeners();
      return true;
    }

    return false;
  }

  // Fuse 3 items of identical slot & rarity into 1 next-tier item
  bool fuseItems(EquipmentItem baseItem) {
    if (baseItem.rarity == ItemRarity.mythic) return false;

    final matchingItems = _backpackItems
        .where((e) => e.slot == baseItem.slot && e.rarity == baseItem.rarity)
        .toList();

    if (matchingItems.length < 3) return false;

    // Take first 3
    final toRemove = matchingItems.take(3).toList();
    for (final item in toRemove) {
      _backpackItems.removeWhere((e) => e.id == item.id);
    }

    final nextRarityIndex = baseItem.rarity.index + 1;
    final nextRarity = ItemRarity.values[nextRarityIndex];

    final fusedItem = EquipmentItem(
      id: 'item_${DateTime.now().millisecondsSinceEpoch}',
      name: '${baseItem.name.replaceAll(RegExp(r'\+?\d*'), '')} +',
      slot: baseItem.slot,
      rarity: nextRarity,
      level: 1,
      bonusHp: (baseItem.bonusHp * 1.5).round(),
      bonusAttack: (baseItem.bonusAttack * 1.5).round(),
      bonusCritRate: baseItem.bonusCritRate + 0.03,
      bonusAttackSpeed: baseItem.bonusAttackSpeed + 0.03,
      icon: baseItem.icon,
      specialEffect: baseItem.specialEffect,
    );

    _backpackItems.add(fusedItem);
    _save();
    notifyListeners();
    return true;
  }

  Future<void> _save() async {
    await StorageService.saveEquippedGear(_equippedItems);
    await StorageService.saveInventoryGear(_backpackItems);
  }
}
