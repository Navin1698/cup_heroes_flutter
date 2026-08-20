import 'package:flutter_test/flutter_test.dart';
import 'package:cup_heroes_flutter/main.dart';
import 'package:cup_heroes_flutter/models/hero_definition.dart';
import 'package:cup_heroes_flutter/models/enemy_definition.dart';
import 'package:cup_heroes_flutter/models/skill_definition.dart';
import 'package:cup_heroes_flutter/models/world_definition.dart';

void main() {
  testWidgets('Emberbound Home Screen loads and renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EmberboundApp());
    await tester.pump();

    expect(find.text('ENTER ADVENTURE'), findsOneWidget);
    expect(find.text('ARIN'), findsOneWidget);
  });

  test('Hero Definitions and scaling test', () {
    final heroes = HeroDefinition.getAllHeroes();
    expect(heroes.length, 5);
    expect(heroes.first.name, 'ARIN');
    expect(heroes.first.baseHp, 600);
  });

  test('Enemy Definitions and spawn configurations test', () {
    final enemies = EnemyDefinition.getWhisperingMeadowEnemies();
    expect(enemies.length, 5);
    expect(enemies.first.name, 'Mossling');
  });

  test('Skill Definitions catalog test', () {
    final skills = SkillDefinition.getAllSkills();
    expect(skills.length, greaterThanOrEqualTo(10));
  });

  test('World Definition stages test', () {
    final meadow = WorldDefinition.getWhisperingMeadow();
    expect(meadow.stages.length, 5);
    expect(meadow.stages.last.type, StageType.boss);
  });
}
