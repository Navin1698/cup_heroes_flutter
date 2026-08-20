import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../core/constants/game_constants.dart';
import '../core/theme/game_theme.dart';
import '../models/chapter_model.dart';
import '../state/player_profile_state.dart';
import '../state/hero_state.dart';
import '../state/inventory_state.dart';
import '../state/talent_state.dart';
import '../game/game_controller.dart';
import '../game/renderers/game_canvas.dart';
import 'perk_selection_dialog.dart';
import 'victory_defeat_dialog.dart';

class BattleScreen extends StatefulWidget {
  final ChapterModel chapter;

  const BattleScreen({super.key, required this.chapter});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final GameController _controller;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();

    final heroState = context.read<HeroState>();
    final inventoryState = context.read<InventoryState>();
    final talentState = context.read<TalentState>();

    _controller = GameController(
      chapter: widget.chapter,
      heroModel: heroState.selectedHero,
      bonusHp: inventoryState.totalBonusHp + talentState.bonusHp,
      bonusAttack: inventoryState.totalBonusAttack + talentState.bonusAttack,
      bonusCritRate: inventoryState.totalBonusCritRate + talentState.bonusCritRate,
      bonusAttackSpeed: inventoryState.totalBonusAttackSpeed,
      talentCupMultiplier: talentState.bonusCupWidthMultiplier,
      talentBallDropChance: talentState.bonusBallDropChance,
      talentSuperChargeRate: talentState.bonusSuperChargeMultiplier,
    );

    _ticker = createTicker((elapsed) {
      if (_lastElapsed != Duration.zero) {
        final dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
        // Clamp frame time to prevent lag spikes
        final clampedDt = dt.clamp(0.001, 0.05);
        _controller.update(clampedDt);
      }
      _lastElapsed = elapsed;
    });

    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleGameCompletion(bool isVictory) {
    final profile = context.read<PlayerProfileState>();
    final totalGold = _controller.goldEarned + (isVictory ? _controller.chapter.goldCompletionReward : 0);
    final totalGems = isVictory ? _controller.chapter.gemCompletionReward : 0;

    profile.addGold(totalGold);
    if (totalGems > 0) profile.addGems(totalGems);
    if (isVictory) profile.completeChapter(_controller.chapter.id);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: GameConstants.darkBg,
        body: SafeArea(
          child: Consumer<GameController>(
            builder: (context, controller, child) {
              return Stack(
                children: [
                  Column(
                    children: [
                      // Top Battle HUD
                      _buildTopHud(controller),

                      // EXP Progress Bar
                      _buildExpBar(controller),

                      // Main Game Viewport (Canvas + Touch Drag)
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return GestureDetector(
                              onHorizontalDragUpdate: (details) {
                                final localX = details.localPosition.dx;
                                final normalizedX = (localX / constraints.maxWidth) * GameConstants.worldWidth;
                                controller.updateCupPosition(normalizedX);
                              },
                              onTapDown: (details) {
                                final localX = details.localPosition.dx;
                                final normalizedX = (localX / constraints.maxWidth) * GameConstants.worldWidth;
                                controller.updateCupPosition(normalizedX);
                              },
                              child: Container(
                                width: constraints.maxWidth,
                                height: constraints.maxHeight,
                                color: Colors.transparent,
                                child: CustomPaint(
                                  size: Size(constraints.maxWidth, constraints.maxHeight),
                                  painter: GameCanvasPainter(controller: controller),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Bottom Control Bar
                      _buildBottomControlBar(controller),
                    ],
                  ),

                  // Overlay: Perk Selection Modal
                  if (controller.status == GameStatus.perkDrafting)
                    PerkSelectionDialog(
                      options: controller.currentPerkDraftOptions,
                      onSelect: (perk) => controller.selectPerk(perk),
                    ),

                  // Overlay: Pause Menu
                  if (controller.status == GameStatus.paused)
                    _buildPauseModal(controller),

                  // Overlay: Victory Dialog
                  if (controller.status == GameStatus.victory)
                    VictoryDefeatDialog(
                      isVictory: true,
                      controller: controller,
                      onContinue: () {
                        _handleGameCompletion(true);
                        Navigator.pop(context);
                      },
                      onRetry: () {
                        _handleGameCompletion(true);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => BattleScreen(chapter: widget.chapter)),
                        );
                      },
                    ),

                  // Overlay: Defeat Dialog
                  if (controller.status == GameStatus.defeat)
                    VictoryDefeatDialog(
                      isVictory: false,
                      controller: controller,
                      onContinue: () {
                        _handleGameCompletion(false);
                        Navigator.pop(context);
                      },
                      onRetry: () {
                        _handleGameCompletion(false);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => BattleScreen(chapter: widget.chapter)),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopHud(GameController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFF1B1833),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Pause Button
          IconButton(
            icon: const Icon(Icons.pause_circle_filled, color: Colors.white70, size: 30),
            onPressed: () => controller.togglePause(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),

          // Wave Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2C274E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4B4480)),
            ),
            child: Row(
              children: [
                const Icon(Icons.waves, color: Colors.amberAccent, size: 16),
                const SizedBox(width: 6),
                Text(
                  'WAVE ${controller.currentWave}/${controller.chapter.totalWaves}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),

          // Gold Earned & Speed Toggle
          Row(
            children: [
              Row(
                children: [
                  const Icon(Icons.monetization_on, color: GameConstants.goldColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${controller.goldEarned}',
                    style: const TextStyle(color: GameConstants.goldColor, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () => controller.toggleSpeed(),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: controller.gameSpeed == 2.0 ? GameConstants.primaryPurple : const Color(0xFF2C274E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${controller.gameSpeed.toInt()}X',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpBar(GameController controller) {
    final expPct = (controller.currentExp / controller.expToNextLevel).clamp(0.0, 1.0);
    return Container(
      height: 18,
      color: const Color(0xFF131127),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            'LV.${controller.currentRunLevel}',
            style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 10),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: expPct,
                backgroundColor: const Color(0xFF221F40),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControlBar(GameController controller) {
    final isReady = controller.isSuperReady;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1B1833),
        border: Border(top: BorderSide(color: Color(0xFF2C274E), width: 1.5)),
      ),
      child: Row(
        children: [
          // Drag instruction
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DRAG CUP TO CATCH BALLS',
                  style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
                Text(
                  'Catching energy balls fuels your Hero Super Skill!',
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),

          // Super Skill Button
          InkWell(
            onTap: isReady ? () => controller.triggerSuperAbility() : null,
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isReady ? Colors.amber : const Color(0xFF2C274E),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (isReady)
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.6),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.bolt,
                    color: isReady ? Colors.black : Colors.white38,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isReady ? 'SUPER SKILL!' : '${controller.cup.superCharge.toInt()}%',
                    style: TextStyle(
                      color: isReady ? Colors.black : Colors.white54,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPauseModal(GameController controller) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: GameTheme.cardDecoration(
            color: const Color(0xFF1E1B38),
            borderColor: GameConstants.primaryPurple,
            borderWidth: 2,
            borderRadius: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GAME PAUSED',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => controller.togglePause(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GameConstants.primaryPurple,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('RESUME', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('QUIT BATTLE', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
