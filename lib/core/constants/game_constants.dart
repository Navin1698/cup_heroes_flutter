class GameConstants {
  static const String gameTitle = 'EMBERBOUND';
  static const String tagline = 'BUILD YOUR HERO. CONQUER THE REALMS.';

  // Virtual Game Canvas & Camera Dimensions (Flame units)
  static const double gameWorldWidth = 1200.0;
  static const double gameWorldHeight = 1600.0;
  static const double viewportWidth = 400.0;
  static const double viewportHeight = 800.0;

  // Player defaults
  static const double playerBaseSpeed = 220.0;
  static const double playerDashSpeed = 550.0;
  static const double playerDashDuration = 0.25;
  static const double playerDashCooldown = 1.5;

  // Combat defaults
  static const double baseCritChance = 0.05; // 5%
  static const double baseCritMultiplier = 1.5; // 1.5x

  // Energy & Economy
  static const int maxEnergy = 20;
  static const int stageEnergyCost = 5;
}
