import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../core/constants/color_constants.dart';
import '../../game/emberbound_game.dart';
import '../../models/hero_definition.dart';
import '../../models/skill_definition.dart';
import '../../models/world_definition.dart';
import '../../repositories/save_repository.dart';
import 'overlays/action_buttons_overlay.dart';
import 'overlays/battle_hud_overlay.dart';
import 'overlays/game_over_overlay.dart';
import 'overlays/joystick_overlay.dart';
import 'overlays/pause_overlay.dart';
import 'overlays/skill_selection_overlay.dart';
import 'overlays/victory_overlay.dart';

class BattleScreen extends StatefulWidget {
  final HeroDefinition hero;
  final StageDefinition stage;

  const BattleScreen({
    super.key,
    required this.hero,
    required this.stage,
  });

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  late final EmberboundGame _game;
  GamePlayState _currentState = GamePlayState.playing;
  List<SkillDefinition> _currentSkillOptions = [];

  @override
  void initState() {
    super.initState();
    _game = EmberboundGame(
      heroDefinition: widget.hero,
      stageDefinition: widget.stage,
      onStateChanged: (state) {
        if (mounted) setState(() => _currentState = state);
      },
      onSkillDraftRequested: (options) {
        if (mounted) {
          setState(() {
            _currentSkillOptions = options;
            _currentState = GamePlayState.skillSelection;
          });
        }
      },
      onGameCompleted: () {
        SaveRepository.instance.saveStageProgress(widget.stage.stageNumber, 3);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EmberColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Core Flame Game World Engine
            GameWidget(game: _game),

            // 2. HUD Overlay (Top HP, Waves, Pause)
            BattleHudOverlay(game: _game),

            // 3. Virtual Touch Joystick (Bottom Left)
            if (_currentState == GamePlayState.playing)
              JoystickOverlay(
                onDirectionChanged: (direction) => _game.setJoystickDirection(direction),
              ),

            // 4. Action Buttons (Bottom Right: Attack, Heavy, Nova, Ult, Dash)
            if (_currentState == GamePlayState.playing)
              ActionButtonsOverlay(game: _game),

            // 5. Roguelike 3-Skill Draft Modal
            if (_currentState == GamePlayState.skillSelection)
              SkillSelectionOverlay(
                options: _currentSkillOptions,
                onSelect: (skill) => _game.selectSkill(skill),
              ),

            // 6. Pause Modal
            if (_currentState == GamePlayState.paused)
              PauseOverlay(
                onResume: () => _game.resumeGame(),
                onRestart: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => BattleScreen(hero: widget.hero, stage: widget.stage)),
                  );
                },
                onQuit: () => Navigator.pop(context),
              ),

            // 7. Victory Modal
            if (_currentState == GamePlayState.victory)
              VictoryOverlay(
                stage: widget.stage,
                onNextStage: () {
                  final nextStageNum = widget.stage.stageNumber + 1;
                  final meadow = WorldDefinition.getWhisperingMeadow();
                  final nextStage = meadow.stages.firstWhere(
                    (s) => s.stageNumber == nextStageNum,
                    orElse: () => meadow.stages.last,
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => BattleScreen(hero: widget.hero, stage: nextStage)),
                  );
                },
                onWorldMap: () => Navigator.pop(context),
              ),

            // 8. Game Over Modal
            if (_currentState == GamePlayState.gameOver)
              GameOverOverlay(
                onRetry: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => BattleScreen(hero: widget.hero, stage: widget.stage)),
                  );
                },
                onWorldMap: () => Navigator.pop(context),
              ),
          ],
        ),
      ),
    );
  }
}
