import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quest_model.dart';

class QuestState extends ChangeNotifier {
  final List<QuestModel> _dailyQuests = QuestModel.getDailyQuests();
  final List<CupPassTier> _passTiers = CupPassTier.getTiers();

  Map<String, int> _questProgress = {};
  Set<String> _claimedQuestIds = {};
  int _passPoints = 0;
  Set<int> _claimedPassTierNumbers = {};

  List<QuestModel> get dailyQuests => _dailyQuests;
  List<CupPassTier> get passTiers => _passTiers;
  int get passPoints => _passPoints;

  int getProgress(String questId) => _questProgress[questId] ?? 0;
  bool isClaimed(String questId) => _claimedQuestIds.contains(questId);
  bool isTierClaimed(int tier) => _claimedPassTierNumbers.contains(tier);

  Future<void> loadQuests() async {
    final prefs = await SharedPreferences.getInstance();
    _passPoints = prefs.getInt('cup_pass_points') ?? 0;

    final progressJson = prefs.getString('quest_progress_map');
    if (progressJson != null) {
      try {
        final map = jsonDecode(progressJson) as Map<String, dynamic>;
        _questProgress = map.map((k, v) => MapEntry(k, v as int));
      } catch (_) {}
    }

    _claimedQuestIds = (prefs.getStringList('claimed_quests') ?? []).toSet();
    final tiers = prefs.getStringList('claimed_pass_tiers') ?? [];
    _claimedPassTierNumbers = tiers.map((e) => int.tryParse(e) ?? 0).toSet();

    notifyListeners();
  }

  void recordAction(QuestType type, int amount) {
    bool hasChanged = false;
    for (final q in _dailyQuests) {
      if (q.type == type && !isClaimed(q.id)) {
        final current = _questProgress[q.id] ?? 0;
        _questProgress[q.id] = (current + amount).clamp(0, q.targetValue);
        hasChanged = true;
      }
    }
    if (hasChanged) {
      _save();
      notifyListeners();
    }
  }

  bool claimQuest(String questId) {
    final quest = _dailyQuests.firstWhere((q) => q.id == questId, orElse: () => _dailyQuests.first);
    final progress = getProgress(questId);

    if (progress >= quest.targetValue && !isClaimed(questId)) {
      _claimedQuestIds.add(questId);
      _passPoints += quest.passPoints;
      _save();
      notifyListeners();
      return true;
    }
    return false;
  }

  bool claimTier(int tierNumber) {
    final tier = _passTiers.firstWhere((t) => t.tierNumber == tierNumber);
    if (_passPoints >= tier.requiredPoints && !isTierClaimed(tierNumber)) {
      _claimedPassTierNumbers.add(tierNumber);
      _save();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cup_pass_points', _passPoints);
    await prefs.setString('quest_progress_map', jsonEncode(_questProgress));
    await prefs.setStringList('claimed_quests', _claimedQuestIds.toList());
    await prefs.setStringList('claimed_pass_tiers', _claimedPassTierNumbers.map((e) => e.toString()).toList());
  }
}
