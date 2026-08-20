import 'sound_synthesizer.dart';

class AudioManager {
  static final AudioManager instance = AudioManager._internal();
  AudioManager._internal();

  final SoundSynthesizer _synth = SoundSynthesizer.instance;

  bool get isSoundEnabled => _synth.isSoundEnabled;
  bool get isHapticEnabled => _synth.isHapticEnabled;

  void toggleSound() => _synth.toggleSound();
  void toggleHaptics() => _synth.toggleHaptics();

  void playBallBounce() => _synth.playPegHit();
  void playGateHit({bool isMultiply = false}) => _synth.playGateTrigger(isMultiply: isMultiply);
  void playBallCaught() => _synth.playBallCatch();
  void playAttack() => _synth.playHeroAttack();
  void playEnemyHit() => _synth.playPegHit();
  void playEnemyDefeated({bool isBoss = false}) => _synth.playEnemyDefeat(isBoss: isBoss);
  void playLevelUp() => _synth.playLevelUp();
  void playVictory() => _synth.playVictory();
  void playDefeat() => _synth.playDefeat();
  void playSuperSkill() => _synth.playSuperSkill();
}
