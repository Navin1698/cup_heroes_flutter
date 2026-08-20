import 'package:flutter/foundation.dart';
import '../models/hero_model.dart';
import '../core/storage/storage_service.dart';

class HeroState extends ChangeNotifier {
  final List<HeroModel> _allHeroes = HeroModel.getAllHeroes();
  String _selectedHeroId = 'hero_knight';
  List<String> _unlockedHeroIds = ['hero_knight'];

  List<HeroModel> get allHeroes => _allHeroes;
  String get selectedHeroId => _selectedHeroId;
  List<String> get unlockedHeroIds => _unlockedHeroIds;

  HeroModel get selectedHero =>
      _allHeroes.firstWhere((h) => h.id == _selectedHeroId, orElse: () => _allHeroes.first);

  bool isUnlocked(String heroId) => _unlockedHeroIds.contains(heroId);

  Future<void> loadHeroState() async {
    _selectedHeroId = await StorageService.loadSelectedHeroId();
    _unlockedHeroIds = await StorageService.loadUnlockedHeroes();
    notifyListeners();
  }

  void selectHero(String heroId) {
    if (isUnlocked(heroId)) {
      _selectedHeroId = heroId;
      StorageService.saveSelectedHeroId(heroId);
      notifyListeners();
    }
  }

  bool unlockHero(String heroId) {
    if (!_unlockedHeroIds.contains(heroId)) {
      _unlockedHeroIds.add(heroId);
      _selectedHeroId = heroId;
      StorageService.saveUnlockedHeroes(_unlockedHeroIds);
      StorageService.saveSelectedHeroId(heroId);
      notifyListeners();
      return true;
    }
    return false;
  }
}
