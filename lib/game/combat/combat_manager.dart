import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/game_constants.dart';
import '../../models/hero_model.dart';
import '../../models/enemy_model.dart';

class FloatingText {
  final String text;
  Offset position;
  final Color color;
  final double fontSize;
  double lifeTime;
  final double maxLifeTime;
  final bool isCrit;

  FloatingText({
    required this.text,
    required this.position,
    required this.color,
    this.fontSize = 14.0,
    this.lifeTime = 0.8,
    this.isCrit = false,
  }) : maxLifeTime = lifeTime;

  void update(double dt) {
    position = Offset(position.dx, position.dy - 35.0 * dt);
    lifeTime = max(0.0, lifeTime - dt);
  }

  double get opacity => (lifeTime / maxLifeTime).clamp(0.0, 1.0);
}

class Projectile {
  Offset position;
  Offset velocity;
  final int damage;
  final bool isCrit;
  final DamageType damageType;
  int pierceCount;
  int chainCount;
  final bool isHeroSource;
  final Color color;
  final double radius;
  bool isExpired = false;
  final Set<String> hitEnemyIds = {};

  Projectile({
    required this.position,
    required this.velocity,
    required this.damage,
    required this.isCrit,
    this.damageType = DamageType.physical,
    this.pierceCount = 0,
    this.chainCount = 0,
    this.isHeroSource = true,
    this.color = Colors.yellow,
    this.radius = 4.5,
  });

  void update(double dt) {
    position += velocity * dt;
    // Boundary check
    if (position.dx < 0 || position.dx > GameConstants.worldWidth || position.dy < 0 || position.dy > GameConstants.arenaHeight) {
      isExpired = true;
    }
  }
}

class EnemyEntity {
  final String instanceId;
  final EnemyModel model;
  Offset position;
  int currentHp;
  int maxHp;
  double attackTimer = 0.0;
  double hitFlashTimer = 0.0;
  
  // Status Effects
  double burnTimer = 0.0;
  int burnDps = 0;
  double chillTimer = 0.0;
  bool isDead = false;

  EnemyEntity({
    required this.instanceId,
    required this.model,
    required this.position,
  })  : currentHp = model.maxHp,
        maxHp = model.maxHp;

  void takeDamage(int amount, bool isCrit) {
    currentHp = max(0, currentHp - amount);
    hitFlashTimer = 0.15;
    if (currentHp <= 0) {
      isDead = true;
    }
  }

  void applyBurn(int dps, double duration) {
    burnDps = max(burnDps, dps);
    burnTimer = max(burnTimer, duration);
  }

  void applyChill(double duration) {
    chillTimer = max(chillTimer, duration);
  }

  void update(double dt, Offset heroPos) {
    if (hitFlashTimer > 0) {
      hitFlashTimer = max(0.0, hitFlashTimer - dt);
    }

    // Process Burn
    if (burnTimer > 0) {
      burnTimer -= dt;
      currentHp = max(0, (currentHp - burnDps * dt).round());
      if (currentHp <= 0) isDead = true;
    }

    // Process Chill
    if (chillTimer > 0) {
      chillTimer -= dt;
    }

    if (isDead) return;

    // Movement toward hero
    final speed = (chillTimer > 0) ? model.moveSpeed * 0.55 : model.moveSpeed;
    final distanceToHero = (position.dx - heroPos.dx).abs();

    if (distanceToHero > model.attackRange) {
      position = Offset(position.dx - speed * dt, position.dy);
    } else {
      attackTimer += dt;
    }
  }
}

class HeroEntity {
  final HeroModel model;
  Offset position;
  int currentHp;
  int maxHp;
  int attackDamage;
  double attackSpeed;
  double attackRange;
  double critRate;
  double critDamageMultiplier;
  
  // Modifiers from perks
  int multiShotCount = 1;
  int pierceCount = 0;
  bool hasChainLightning = false;
  bool hasFireBurn = false;
  bool hasFrostNova = false;
  double lifeStealPercent = 0.0;
  int currentShield = 0;
  int maxShield = 0;
  double attackTimer = 0.0;
  double hitFlashTimer = 0.0;
  double attackAnimationTimer = 0.0;

  HeroEntity({
    required this.model,
    required this.position,
    required this.maxHp,
    required this.attackDamage,
    required this.attackSpeed,
    required this.attackRange,
    this.critRate = 0.08,
    this.critDamageMultiplier = 1.6,
  })  : currentHp = maxHp;

  void takeDamage(int amount) {
    int remaining = amount;
    if (currentShield > 0) {
      if (currentShield >= remaining) {
        currentShield -= remaining;
        remaining = 0;
      } else {
        remaining -= currentShield;
        currentShield = 0;
      }
    }

    if (remaining > 0) {
      currentHp = max(0, currentHp - remaining);
      hitFlashTimer = 0.2;
    }
  }

  void heal(int amount) {
    currentHp = min(maxHp, currentHp + amount);
  }

  void update(double dt) {
    attackTimer += dt;
    if (hitFlashTimer > 0) {
      hitFlashTimer = max(0.0, hitFlashTimer - dt);
    }
    if (attackAnimationTimer > 0) {
      attackAnimationTimer = max(0.0, attackAnimationTimer - dt);
    }
  }
}
