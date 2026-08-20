import 'package:flutter/foundation.dart';
import '../models/talent_model.dart';
import '../core/storage/storage_service.dart';

class TalentState extends ChangeNotifier {
  final List<TalentNode> _allTalents = TalentNode.getAllTalents();
  Map<TalentType, int> _talentLevels = {};

  List<TalentNode> get allTalents => _allTalents;
  Map<TalentType, int> get talentLevels => _talentLevels;

  int getLevel(TalentType type) => _talentLevels[type] ?? 0;

  // Computed Meta Stat Boosts
  int get bonusHp => ((getLevel(TalentType.heroHp)) * 25);
  int get bonusAttack => ((getLevel(TalentType.heroAttack)) * 5);
  double get bonusCritRate => (getLevel(TalentType.critChance) * 0.015);
  double get bonusCupWidthMultiplier => 1.0 + (getLevel(TalentType.cupSize) * 0.02);
  double get bonusBallDropChance => (getLevel(TalentType.ballDropBonus) * 0.03);
  double get bonusSuperChargeMultiplier => 1.0 + (getLevel(TalentType.superChargeRate) * 0.04);
  int get bonusStartingGold => (getLevel(TalentType.startingGold) * 100);

  Future<void> loadTalents() async {
    _talentLevels = await StorageService.loadTalentLevels();
    notifyListeners();
  }

  void upgradeTalent(TalentType type) {
    final current = getLevel(type);
    _talentLevels[type] = current + 1;
    StorageService.saveTalentLevels(_talentLevels);
    notifyListeners();
  }
}
