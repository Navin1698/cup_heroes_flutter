import 'dart:math';
import 'package:flame/components.dart';
import '../../models/damage_info.dart';
import '../emberbound_game.dart';
import '../components/enemy_component.dart';
import '../components/boss_component.dart';

class CombatSystem {
  final EmberboundGame game;

  CombatSystem(this.game);

  void executePlayerMeleeAttack(Vector2 attackCenter, double radius, DamageInfo info) {
    // 1. Check Normal Enemies
    final enemies = game.world.children.whereType<EnemyComponent>().toList();
    for (final enemy in enemies) {
      if (enemy.isDead) continue;
      final dist = (enemy.position - attackCenter).length;
      if (dist <= radius + enemy.definition.radius) {
        enemy.takeDamage(info);
        _applySynergies(enemy.position, info);
      }
    }

    // 2. Check Boss
    final bosses = game.world.children.whereType<BossComponent>().toList();
    for (final boss in bosses) {
      if (boss.isDead) continue;
      final dist = (boss.position - attackCenter).length;
      if (dist <= radius + boss.definition.radius) {
        boss.takeDamage(info);
      }
    }
  }

  void executeRadialNova(Vector2 center, double radius, DamageInfo info) {
    final enemies = game.world.children.whereType<EnemyComponent>().toList();
    for (final enemy in enemies) {
      if (enemy.isDead) continue;
      final dist = (enemy.position - center).length;
      if (dist <= radius) {
        enemy.takeDamage(info);
      }
    }

    final bosses = game.world.children.whereType<BossComponent>().toList();
    for (final boss in bosses) {
      if (boss.isDead) continue;
      final dist = (boss.position - center).length;
      if (dist <= radius) {
        boss.takeDamage(info);
      }
    }
  }

  void executeLinearBeam(Vector2 origin, Vector2 direction, double length, double width, DamageInfo info) {
    final enemies = game.world.children.whereType<EnemyComponent>().toList();
    for (final enemy in enemies) {
      if (enemy.isDead) continue;
      final toEnemy = enemy.position - origin;
      final proj = toEnemy.dot(direction);
      if (proj > 0 && proj <= length) {
        final perpDist = (toEnemy - (direction * proj)).length;
        if (perpDist <= width / 2 + enemy.definition.radius) {
          enemy.takeDamage(info);
        }
      }
    }

    final bosses = game.world.children.whereType<BossComponent>().toList();
    for (final boss in bosses) {
      if (boss.isDead) continue;
      final toBoss = boss.position - origin;
      final proj = toBoss.dot(direction);
      if (proj > 0 && proj <= length) {
        final perpDist = (toBoss - (direction * proj)).length;
        if (perpDist <= width / 2 + boss.definition.radius) {
          boss.takeDamage(info);
        }
      }
    }
  }

  void _applySynergies(Vector2 hitPos, DamageInfo originalInfo) {
    final player = game.player;

    // Chain Strike
    if (player.hasChainStrike) {
      final enemies = game.world.children.whereType<EnemyComponent>().where((e) => !e.isDead).toList();
      for (final target in enemies.take(2)) {
        target.takeDamage(
          DamageInfo(
            amount: (originalInfo.amount * 0.5).roundToDouble(),
            type: DamageType.lightning,
            source: 'chain_strike',
          ),
        );
      }
    }

    // Explosive Hit
    if (player.hasExplosiveHit) {
      final rng = Random();
      if (rng.nextDouble() < 0.25) {
        executeRadialNova(
          hitPos,
          60.0,
          DamageInfo(
            amount: (player.attackDamage * 0.75).roundToDouble(),
            type: DamageType.fire,
            source: 'explosion',
          ),
        );
      }
    }
  }
}
