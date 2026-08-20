import 'package:flutter/services.dart';

class HapticService {
  static final HapticService instance = HapticService._internal();
  HapticService._internal();

  bool isHapticsEnabled = true;

  void toggleHaptics() => isHapticsEnabled = !isHapticsEnabled;

  void lightImpact() {
    if (isHapticsEnabled) HapticFeedback.lightImpact();
  }

  void mediumImpact() {
    if (isHapticsEnabled) HapticFeedback.mediumImpact();
  }

  void heavyImpact() {
    if (isHapticsEnabled) HapticFeedback.heavyImpact();
  }

  void selectionClick() {
    if (isHapticsEnabled) HapticFeedback.selectionClick();
  }

  void vibrate() {
    if (isHapticsEnabled) HapticFeedback.vibrate();
  }
}
