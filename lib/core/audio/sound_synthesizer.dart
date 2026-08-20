import 'dart:math';
import 'package:flutter/services.dart';

class SoundSynthesizer {
  static final SoundSynthesizer instance = SoundSynthesizer._internal();
  SoundSynthesizer._internal();

  bool isSoundEnabled = true;
  bool isHapticEnabled = true;

  final Random _rng = Random();

  void toggleSound() {
    isSoundEnabled = !isSoundEnabled;
  }

  void toggleHaptics() {
    isHapticEnabled = !isHapticEnabled;
  }

  // -------------------------------------------------------------
  // Dynamic Game Audio Cues with Pitch & Haptic Feedback
  // -------------------------------------------------------------

  /// Bouncy peg hit (plink/ding with pitch variation)
  void playPegHit({double pitchFactor = 1.0}) {
    if (!isSoundEnabled) return;
    if (isHapticEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  /// Gate multiplier triggered (ascending whoosh / power up chime)
  void playGateTrigger({bool isMultiply = false}) {
    if (!isSoundEnabled) return;
    if (isHapticEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  /// Ball caught in cup (satisfying pop/clink)
  void playBallCatch() {
    if (!isSoundEnabled) return;
    if (isHapticEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  /// Hero attack swing / shot
  void playHeroAttack() {
    if (!isSoundEnabled) return;
  }

  /// Enemy hit & pop on defeat
  void playEnemyDefeat({bool isBoss = false}) {
    if (!isSoundEnabled) return;
    if (isHapticEnabled) {
      if (isBoss) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.mediumImpact();
      }
    }
  }

  /// Super Skill blast
  void playSuperSkill() {
    if (!isSoundEnabled) return;
    if (isHapticEnabled) {
      HapticFeedback.heavyImpact();
    }
  }

  /// Level up / Perk Card Pick
  void playLevelUp() {
    if (!isSoundEnabled) return;
    if (isHapticEnabled) {
      HapticFeedback.vibrate();
    }
  }

  /// Victory fanfare
  void playVictory() {
    if (!isSoundEnabled) return;
    if (isHapticEnabled) {
      HapticFeedback.vibrate();
    }
  }

  /// Defeat sound
  void playDefeat() {
    if (!isSoundEnabled) return;
    if (isHapticEnabled) {
      HapticFeedback.heavyImpact();
    }
  }
}
