import 'package:flutter/material.dart';
import '../core/constants/color_constants.dart';

enum BossPhase {
  phase1,
  phase2,
  phase3Enraged,
}

class BossDefinition {
  final String id;
  final String name;
  final String title;
  final int maxHp;
  final int baseDamage;
  final double moveSpeed;
  final double radius;
  final Color primaryColor;
  final Color secondaryColor;

  const BossDefinition({
    required this.id,
    required this.name,
    required this.title,
    required this.maxHp,
    required this.baseDamage,
    required this.moveSpeed,
    this.radius = 42.0,
    required this.primaryColor,
    required this.secondaryColor,
  });

  static BossDefinition getRootColossus() {
    return const BossDefinition(
      id: 'root_colossus',
      name: 'ROOT COLOSSUS',
      title: 'Ancient Guardian of the Meadow',
      maxHp: 2000,
      baseDamage: 35,
      moveSpeed: 60.0,
      radius: 44.0,
      primaryColor: Color(0xFF5D4037),
      secondaryColor: EmberColors.success,
    );
  }
}
