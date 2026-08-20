enum DamageType {
  physical,
  fire,
  ice,
  lightning,
  shadow,
  crystal,
}

enum StatusEffectType {
  burn,
  freeze,
  slow,
  poison,
  shock,
  stun,
  knockback,
}

class StatusEffect {
  final StatusEffectType type;
  double duration;
  final double power;
  int stacks;

  StatusEffect({
    required this.type,
    required this.duration,
    required this.power,
    this.stacks = 1,
  });
}

class DamageInfo {
  final double amount;
  final DamageType type;
  final String source;
  final String target;
  final bool isCritical;
  final double knockbackForce;
  final StatusEffect? statusEffect;

  const DamageInfo({
    required this.amount,
    this.type = DamageType.physical,
    this.source = 'player',
    this.target = 'enemy',
    this.isCritical = false,
    this.knockbackForce = 0.0,
    this.statusEffect,
  });
}
