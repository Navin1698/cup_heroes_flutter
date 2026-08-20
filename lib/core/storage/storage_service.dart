import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/equipment_model.dart';
import '../../models/talent_model.dart';

class StorageService {
  static const String keyGold = 'player_gold';
  static const String keyGems = 'player_gems';
  static const String keyEnergy = 'player_energy';
  static const String keyHighestChapter = 'highest_chapter';
  static const String keySelectedHero = 'selected_hero_id';
  static const String keyUnlockedHeroes = 'unlocked_heroes';
  static const String keyEquippedGear = 'equipped_gear_v1';
  static const String keyInventoryGear = 'inventory_gear_v1';
  static const String keyTalentLevels = 'talent_levels_v1';
  static const String keySoundEnabled = 'setting_sound';
  static const String keyHapticEnabled = 'setting_haptic';

  static Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // Currencies
  static Future<int> loadGold() async {
    final prefs = await _prefs;
    return prefs.getInt(keyGold) ?? 200;
  }

  static Future<void> saveGold(int gold) async {
    final prefs = await _prefs;
    await prefs.setInt(keyGold, gold);
  }

  static Future<int> loadGems() async {
    final prefs = await _prefs;
    return prefs.getInt(keyGems) ?? 50;
  }

  static Future<void> saveGems(int gems) async {
    final prefs = await _prefs;
    await prefs.setInt(keyGems, gems);
  }

  static Future<int> loadHighestChapter() async {
    final prefs = await _prefs;
    return prefs.getInt(keyHighestChapter) ?? 1;
  }

  static Future<void> saveHighestChapter(int chapter) async {
    final prefs = await _prefs;
    await prefs.setInt(keyHighestChapter, chapter);
  }

  // Heroes
  static Future<String> loadSelectedHeroId() async {
    final prefs = await _prefs;
    return prefs.getString(keySelectedHero) ?? 'hero_knight';
  }

  static Future<void> saveSelectedHeroId(String heroId) async {
    final prefs = await _prefs;
    await prefs.setString(keySelectedHero, heroId);
  }

  static Future<List<String>> loadUnlockedHeroes() async {
    final prefs = await _prefs;
    return prefs.getStringList(keyUnlockedHeroes) ?? ['hero_knight'];
  }

  static Future<void> saveUnlockedHeroes(List<String> heroIds) async {
    final prefs = await _prefs;
    await prefs.setStringList(keyUnlockedHeroes, heroIds);
  }

  // Equipment & Inventory
  static Future<List<EquipmentItem>> loadEquippedGear() async {
    final prefs = await _prefs;
    final jsonStr = prefs.getString(keyEquippedGear);
    if (jsonStr == null) {
      return EquipmentItem.getStarterGear();
    }
    try {
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => EquipmentItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return EquipmentItem.getStarterGear();
    }
  }

  static Future<void> saveEquippedGear(List<EquipmentItem> items) async {
    final prefs = await _prefs;
    final jsonStr = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(keyEquippedGear, jsonStr);
  }

  static Future<List<EquipmentItem>> loadInventoryGear() async {
    final prefs = await _prefs;
    final jsonStr = prefs.getString(keyInventoryGear);
    if (jsonStr == null) {
      return [];
    }
    try {
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => EquipmentItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveInventoryGear(List<EquipmentItem> items) async {
    final prefs = await _prefs;
    final jsonStr = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(keyInventoryGear, jsonStr);
  }

  // Talents
  static Future<Map<TalentType, int>> loadTalentLevels() async {
    final prefs = await _prefs;
    final jsonStr = prefs.getString(keyTalentLevels);
    final Map<TalentType, int> result = {};
    for (final t in TalentType.values) {
      result[t] = 0;
    }
    if (jsonStr != null) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        map.forEach((k, v) {
          final type = TalentType.values.firstWhere((e) => e.name == k, orElse: () => TalentType.heroHp);
          result[type] = v as int;
        });
      } catch (_) {}
    }
    return result;
  }

  static Future<void> saveTalentLevels(Map<TalentType, int> levels) async {
    final prefs = await _prefs;
    final map = <String, int>{};
    levels.forEach((k, v) {
      map[k.name] = v;
    });
    await prefs.setString(keyTalentLevels, jsonEncode(map));
  }
}
