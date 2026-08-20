import 'package:flutter/foundation.dart';
import '../core/storage/storage_service.dart';

class PlayerProfileState extends ChangeNotifier {
  int _gold = 200;
  int _gems = 50;
  int _highestChapter = 1;
  int _energy = 20;
  final int _maxEnergy = 20;

  int get gold => _gold;
  int get gems => _gems;
  int get highestChapter => _highestChapter;
  int get energy => _energy;
  int get maxEnergy => _maxEnergy;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<void> loadProfile() async {
    _gold = await StorageService.loadGold();
    _gems = await StorageService.loadGems();
    _highestChapter = await StorageService.loadHighestChapter();
    _isLoaded = true;
    notifyListeners();
  }

  void addGold(int amount) {
    _gold += amount;
    StorageService.saveGold(_gold);
    notifyListeners();
  }

  bool spendGold(int amount) {
    if (_gold >= amount) {
      _gold -= amount;
      StorageService.saveGold(_gold);
      notifyListeners();
      return true;
    }
    return false;
  }

  void addGems(int amount) {
    _gems += amount;
    StorageService.saveGems(_gems);
    notifyListeners();
  }

  bool spendGems(int amount) {
    if (_gems >= amount) {
      _gems -= amount;
      StorageService.saveGems(_gems);
      notifyListeners();
      return true;
    }
    return false;
  }

  bool consumeEnergy(int amount) {
    if (_energy >= amount) {
      _energy -= amount;
      notifyListeners();
      return true;
    }
    return false;
  }

  void restoreEnergy(int amount) {
    _energy = (_energy + amount).clamp(0, _maxEnergy);
    notifyListeners();
  }

  void completeChapter(int chapterId) {
    if (chapterId >= _highestChapter) {
      _highestChapter = chapterId + 1;
      StorageService.saveHighestChapter(_highestChapter);
      notifyListeners();
    }
  }
}
