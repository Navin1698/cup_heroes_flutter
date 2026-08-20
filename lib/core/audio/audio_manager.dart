import 'package:flutter/services.dart';

class AudioManager {
  static final AudioManager instance = AudioManager._internal();
  AudioManager._internal();

  bool isSoundEnabled = true;
  bool isHapticEnabled = true;

  void toggleSound() {
    isSoundEnabled = !isSoundEnabled;
  }

  void toggleHaptics() {
    isHapticEnabled = !isHapticEnabled;
  }

  // Haptic feedback triggers
  void triggerLightHaptic() {
    if (isHapticEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  void triggerMediumHaptic() {
    if (isHapticEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  void triggerHeavyHaptic() {
    if (isHapticEnabled) {
      HapticFeedback.heavyImpact();
    }
  }

  void triggerSuccessHaptic() {
    if (isHapticEnabled) {
      HapticFeedback.vibrate();
    }
  }

  // Sound triggers (can be expanded with sound samples or synthesized tones)
  void playBallBounce() {
    if (!isSoundEnabled) return;
    // Light feedback
  }

  void playGateHit() {
    if (!isSoundEnabled) return;
    triggerLightHaptic();
  }

  void playBallCaught() {
    if (!isSoundEnabled) return;
    triggerLightHaptic();
  }

  void playAttack() {
    if (!isSoundEnabled) return;
  }

  void playEnemyHit() {
    if (!isSoundEnabled) return;
  }

  void playEnemyDefeated() {
    if (!isSoundEnabled) return;
    triggerMediumHaptic();
  }

  void playLevelUp() {
    if (!isSoundEnabled) return;
    triggerSuccessHaptic();
  }

  void playVictory() {
    if (!isSoundEnabled) return;
    triggerSuccessHaptic();
  }

  void playDefeat() {
    if (!isSoundEnabled) return;
    triggerHeavyHaptic();
  }
}
