import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../core/constants/color_constants.dart';
import '../../game/components/pegboard/multiplier_gate_component.dart';
import '../../game/cup_physics_game.dart';
import '../../game/unified_cup_battle_game.dart';
import '../../models/hero_definition.dart';
import '../../models/skill_definition.dart';
import '../../models/world_definition.dart';
import '../../repositories/save_repository.dart';
import 'overlays/skill_selection_overlay.dart';
import 'overlays/victory_overlay.dart';
import 'overlays/game_over_overlay.dart';

class DualBattleScreen extends StatefulWidget {
  final HeroDefinition hero;
  final StageDefinition stage;

  const DualBattleScreen({
    super.key,
    required this.hero,
    required this.stage,
  });

  @override
  State<DualBattleScreen> createState() => _DualBattleScreenState();
}

class _DualBattleScreenState extends State<DualBattleScreen> {
  late final UnifiedCupBattleGame _combatGame;
  late final CupPhysicsGame _plinkoGame;

  BattlePhase _phase = BattlePhase.playing;
  List<SkillDefinition> _draftSkills = [];

  int _playerHp = 100;
  int _maxHp = 100;
  int _wave = 1;
  int _totalWaves = 5;
  int _xp = 0;
  int _xpTarget = 60;
  int _goldEarned = 0;
  int _ballsCollected = 0;

  @override
  void initState() {
    super.initState();

    // 1. Initialize Top Combat Game World
    _combatGame = UnifiedCupBattleGame(
      heroDefinition: widget.hero,
      stageDefinition: widget.stage,
      onPhaseChanged: (phase) {
        if (mounted) setState(() => _phase = phase);
      },
      onSkillDraftRequested: (options) {
        if (mounted) {
          setState(() {
            _draftSkills = options;
            _phase = BattlePhase.skillSelection;
          });
        }
      },
      onStatsUpdated: (hp, maxHp, wave, totalWaves, xp, xpTarget, gold) {
        if (mounted) {
          setState(() {
            _playerHp = hp;
            _maxHp = maxHp;
            _wave = wave;
            _totalWaves = totalWaves;
            _xp = xp;
            _xpTarget = xpTarget;
            _goldEarned = gold;
          });
        }
      },
    );

    // 2. Initialize Bottom Plinko Physics Game
    _plinkoGame = CupPhysicsGame(
      onBallCollectedCallback: (count, isGold) {
        if (mounted) {
          setState(() => _ballsCollected += count);
        }
        // LIVE BRIDGE: Ball collected in Cup -> Hero fires projectile volley!
        _combatGame.fireHeroVolley(count, isGold: isGold);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF070A14),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 1. Top Wave Combat Arena (42% Height)
                SizedBox(
                  height: screenHeight * 0.40,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      GameWidget(game: _combatGame),
                      _buildTopCombatHUD(),
                    ],
                  ),
                ),

                // Separator Bar with Energy Conduit
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        EmberColors.primary.withValues(alpha: 0.8),
                        EmberColors.secondary,
                        EmberColors.accent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: EmberColors.secondary.withValues(alpha: 0.6),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),

                // 2. Bottom Plinko Multiplier Arena (Remaining Height)
                Expanded(
                  child: Stack(
                    children: [
                      GameWidget(game: _plinkoGame),
                      Positioned(
                        bottom: 12,
                        left: 16,
                        right: 16,
                        child: _buildPlinkoControls(),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 3. Roguelike 3-Skill Draft Overlay
            if (_phase == BattlePhase.skillSelection)
              SkillSelectionOverlay(
                options: _draftSkills,
                onSelect: (skill) {
                  _combatGame.selectSkill(skill);
                  if (skill.gateWidthBonusPct > 0 || skill.gateValueBonus > 0) {
                    _plinkoGame.updateTopGate(
                      op: GateOperation.add,
                      value: 5 + _combatGame.gateValueBonus,
                      widthBonus: _combatGame.gateWidthBonus,
                    );
                    _plinkoGame.updateMidGate(
                      op: GateOperation.multiply,
                      value: 2 + _combatGame.gateValueBonus,
                      widthBonus: _combatGame.gateWidthBonus,
                    );
                  }
                },
              ),

            // 4. Victory Overlay
            if (_phase == BattlePhase.victory)
              VictoryOverlay(
                stage: widget.stage,
                onNextStage: () {
                  SaveRepository.instance.saveStageProgress(widget.stage.stageNumber, 3);
                  Navigator.pop(context);
                },
                onWorldMap: () {
                  SaveRepository.instance.saveStageProgress(widget.stage.stageNumber, 3);
                  Navigator.pop(context);
                },
              ),

            // 5. Game Over Overlay
            if (_phase == BattlePhase.defeat)
              GameOverOverlay(
                onRetry: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DualBattleScreen(hero: widget.hero, stage: widget.stage),
                    ),
                  );
                },
                onWorldMap: () => Navigator.pop(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCombatHUD() {
    final hpPct = (_playerHp / max(1, _maxHp)).clamp(0.0, 1.0);
    final xpPct = (_xp / max(1, _xpTarget)).clamp(0.0, 1.0);

    return Positioned(
      top: 8,
      left: 12,
      right: 12,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),

              // Wave Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: EmberColors.primary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: EmberColors.primary),
                ),
                child: Text(
                  'WAVE  / ',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                ),
              ),

              // Gold Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: EmberColors.accent),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on, color: EmberColors.accent, size: 13),
                    const SizedBox(width: 4),
                    Text('', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // HP & XP Bar Row
          Row(
            children: [
              // Hero HP Bar
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: hpPct,
                    minHeight: 8,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      hpPct > 0.3 ? const Color(0xFF00FF88) : const Color(0xFFFF2A85),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Roguelike XP Bar
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: xpPct,
                    minHeight: 8,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlinkoControls() {
    return Row(
      children: [
        // Drop 1 Ball
        Expanded(
          child: _buildDropButton(
            label: 'DROP 1',
            icon: Icons.lens,
            color: const Color(0xFF00E5FF),
            onTap: () {
              final isGold = _combatGame.goldenBallRate > 0 &&
                  (Random().nextDouble() < _combatGame.goldenBallRate);
              _plinkoGame.dropBall(isGold: isGold);
            },
          ),
        ),
        const SizedBox(width: 8),

        // Burst x10 Balls
        Expanded(
          child: _buildDropButton(
            label: 'BURST x10',
            icon: Icons.bubble_chart,
            color: const Color(0xFF00FF88),
            onTap: () {
              _plinkoGame.dropBurst(count: 10);
            },
          ),
        ),
        const SizedBox(width: 8),

        // Golden Mega Volley
        Expanded(
          child: _buildDropButton(
            label: 'GOLD BURST',
            icon: Icons.stars,
            color: const Color(0xFFFFD700),
            onTap: () {
              _plinkoGame.dropBurst(count: 15, isGold: true);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.8), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
