class AudioService {
  static final AudioService instance = AudioService._internal();
  AudioService._internal();

  bool isSoundEnabled = true;
  bool isMusicEnabled = true;

  void toggleSound() => isSoundEnabled = !isSoundEnabled;
  void toggleMusic() => isMusicEnabled = !isMusicEnabled;

  void playAttack() {}
  void playHeavyAttack() {}
  void playHit() {}
  void playCritical() {}
  void playSpecial() {}
  void playUltimate() {}
  void playChest() {}
  void playCoin() {}
  void playGem() {}
  void playLevelUp() {}
  void playPuzzleSuccess() {}
  void playBossAttack() {}
  void playVictory() {}
  void playGameOver() {}
  void playButtonClick() {}
}
