import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SaveRepository {
  static final SaveRepository instance = SaveRepository._internal();
  SaveRepository._internal();

  static const String _kGold = 'eb_gold';
  static const String _kGems = 'eb_gems';
  static const String _kEnergy = 'eb_energy';
  static const String _kPlayerLevel = 'eb_player_level';
  static const String _kPlayerXp = 'eb_player_xp';
  static const String _kHighestStage = 'eb_highest_stage';
  static const String _kStageStars = 'eb_stage_stars';
  static const String _kSelectedHero = 'eb_selected_hero';
  static const String _kUnlockedHeroes = 'eb_unlocked_heroes';
  static const String _kHeroShards = 'eb_hero_shards';

  Future<Map<String, dynamic>> loadSaveData() async {
    final prefs = await SharedPreferences.getInstance();

    final gold = prefs.getInt(_kGold) ?? 500;
    final gems = prefs.getInt(_kGems) ?? 80;
    final energy = prefs.getInt(_kEnergy) ?? 20;
    final playerLevel = prefs.getInt(_kPlayerLevel) ?? 1;
    final playerXp = prefs.getInt(_kPlayerXp) ?? 0;
    final highestStage = prefs.getInt(_kHighestStage) ?? 1;
    final selectedHero = prefs.getString(_kSelectedHero) ?? 'arin';
    final unlockedHeroes = prefs.getStringList(_kUnlockedHeroes) ?? ['arin'];

    Map<String, int> stageStars = {};
    final starsRaw = prefs.getString(_kStageStars);
    if (starsRaw != null) {
      try {
        final decoded = jsonDecode(starsRaw) as Map<String, dynamic>;
        stageStars = decoded.map((k, v) => MapEntry(k, v as int));
      } catch (_) {}
    }

    Map<String, int> heroShards = {};
    final shardsRaw = prefs.getString(_kHeroShards);
    if (shardsRaw != null) {
      try {
        final decoded = jsonDecode(shardsRaw) as Map<String, dynamic>;
        heroShards = decoded.map((k, v) => MapEntry(k, v as int));
      } catch (_) {}
    }

    return {
      'gold': gold,
      'gems': gems,
      'energy': energy,
      'playerLevel': playerLevel,
      'playerXp': playerXp,
      'highestStage': highestStage,
      'selectedHero': selectedHero,
      'unlockedHeroes': unlockedHeroes,
      'stageStars': stageStars,
      'heroShards': heroShards,
    };
  }

  Future<void> saveCurrencies({required int gold, required int gems, required int energy}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kGold, gold);
    await prefs.setInt(_kGems, gems);
    await prefs.setInt(_kEnergy, energy);
  }

  Future<void> saveStageProgress(int stageNumber, int stars) async {
    final prefs = await SharedPreferences.getInstance();
    final highest = prefs.getInt(_kHighestStage) ?? 1;
    if (stageNumber >= highest) {
      await prefs.setInt(_kHighestStage, stageNumber + 1);
    }

    final starsRaw = prefs.getString(_kStageStars);
    Map<String, int> map = {};
    if (starsRaw != null) {
      try {
        map = (jsonDecode(starsRaw) as Map<String, dynamic>).map((k, v) => MapEntry(k, v as int));
      } catch (_) {}
    }
    final existing = map[stageNumber.toString()] ?? 0;
    if (stars > existing) {
      map[stageNumber.toString()] = stars;
      await prefs.setString(_kStageStars, jsonEncode(map));
    }
  }

  Future<void> saveSelectedHero(String heroId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSelectedHero, heroId);
  }

  Future<void> unlockHero(String heroId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kUnlockedHeroes) ?? ['arin'];
    if (!list.contains(heroId)) {
      list.add(heroId);
      await prefs.setStringList(_kUnlockedHeroes, list);
    }
  }
}
