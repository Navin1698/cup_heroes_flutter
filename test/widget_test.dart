import 'package:flutter_test/flutter_test.dart';
import 'package:cup_heroes_flutter/main.dart';
import 'package:cup_heroes_flutter/models/hero_model.dart';
import 'package:cup_heroes_flutter/models/chapter_model.dart';
import 'package:cup_heroes_flutter/models/skill_perk_model.dart';
import 'package:cup_heroes_flutter/game/game_controller.dart';
import 'package:cup_heroes_flutter/models/equipment_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App loads and renders Home Screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CupHeroesApp());
    await tester.pump();

    // Verify Title and Hub Elements
    expect(find.text('CUP HEROES'), findsOneWidget);
    expect(find.text('PLAY BATTLE'), findsOneWidget);
    expect(find.text('Gear Forge'), findsOneWidget);
  });

  test('Game Controller physics and combat simulation test', () {
    final hero = HeroModel.getAllHeroes().first;
    final chapter = ChapterModel.getAllChapters().first;

    final controller = GameController(
      chapter: chapter,
      heroModel: hero,
    );

    expect(controller.currentWave, 1);
    expect(controller.hero.currentHp, 500);
    expect(controller.pegs.isNotEmpty, true);
    expect(controller.gates.isNotEmpty, true);

    // Simulate 20 frames of gameplay
    for (int i = 0; i < 20; i++) {
      controller.update(0.016);
    }

    expect(controller.status, GameStatus.playing);
  });

  test('Perk modifier application test', () {
    final hero = HeroModel.getAllHeroes().first;
    final chapter = ChapterModel.getAllChapters().first;

    final controller = GameController(
      chapter: chapter,
      heroModel: hero,
    );

    final initialAtk = controller.hero.attackDamage;
    final multiPerk = SkillPerkModel.getAllPerks().firstWhere((p) => p.id == PerkId.multiShot);
    controller.selectPerk(multiPerk);

    expect(controller.hero.multiShotCount, 2);

    final dmgPerk = SkillPerkModel.getAllPerks().firstWhere((p) => p.id == PerkId.damageBoost);
    controller.selectPerk(dmgPerk);

    expect(controller.hero.attackDamage, greaterThan(initialAtk));
  });

  test('Equipment scaling and stat test', () {
    final starterGear = EquipmentItem.getStarterGear();
    expect(starterGear.length, 6);

    final weapon = starterGear.first;
    expect(weapon.effectiveAttack, greaterThan(0));

    final upgraded = weapon.copyWith(level: 2);
    expect(upgraded.effectiveAttack, greaterThan(weapon.effectiveAttack));
  });
}
