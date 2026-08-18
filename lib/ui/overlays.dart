import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/overlay_ids.dart';
import '../core/palette.dart';
import '../engine/neon_echo_game.dart';
import '../engine/scenes/cutscene_scene.dart';
import '../story/models/dialogue.dart';
import 'widgets.dart';

/// Builds the overlay widget map registered with the `GameWidget`.
Map<String, Widget Function(BuildContext, NeonEchoGame)> buildOverlays() => {
      OverlayIds.mainMenu: (context, game) => MainMenuOverlay(game: game),
      OverlayIds.episodeSelect: (context, game) => EpisodeSelectOverlay(game: game),
      OverlayIds.cutsceneHud: (context, game) => CutsceneHudOverlay(game: game),
      OverlayIds.hud: (context, game) => HudOverlay(game: game),
      OverlayIds.dialogue: (context, game) => DialogueOverlay(game: game),
      OverlayIds.pause: (context, game) => PauseOverlay(game: game),
      OverlayIds.levelCleared: (context, game) => LevelClearedOverlay(game: game),
      OverlayIds.gameOver: (context, game) => GameOverOverlay(game: game),
      OverlayIds.victory: (context, game) => VictoryOverlay(game: game),
    };

// ===========================================================================
// Main menu
// ===========================================================================
class MainMenuOverlay extends StatelessWidget {
  const MainMenuOverlay({super.key, required this.game});
  final NeonEchoGame game;

  @override
  Widget build(BuildContext context) {
    return NeonScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            neonTag('A CYBERPUNK STORY · VERGE CITY', color: NeonPalette.magenta),
            const SizedBox(height: 14),
            const GlitchTitle('NEON ECHO', fontSize: 76),
            const SizedBox(height: 14),
            const SizedBox(
              width: 600,
              child: Text(
                'James Vance hunts the drowned neon sprawl for his sister Millie — '
                'and the closer he gets, the less she is the person he came to save.',
                textAlign: TextAlign.center,
                style: TextStyle(color: NeonPalette.textDim, fontSize: 15, height: 1.5),
              ),
            ),
            const SizedBox(height: 26),
            KeyboardMenu(actions: [
              MenuAction('NEW GAME', game.director.startNewGame, primary: true),
              MenuAction('EPISODES', game.director.showEpisodeSelect, color: NeonPalette.magenta),
            ]),
            const SizedBox(height: 24),
            const Text(
              'KEYBOARD · A/D or ←/→ move · W/↑ up · SPACE jump · J fire · ESC pause\n'
              'MENUS · ↑/↓ select · ENTER confirm    ·    TOUCH · stick + A / B',
              textAlign: TextAlign.center,
              style: TextStyle(color: NeonPalette.textDim, fontSize: 11, height: 1.6, letterSpacing: 1),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 14),
              neonTag('DEBUG CHEAT · ↑ ↑ ↓ ↓ ← → ← → B A unlocks all episodes', color: NeonPalette.amber),
            ],
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Episode select (keyboard-navigable list)
// ===========================================================================
class EpisodeSelectOverlay extends StatelessWidget {
  const EpisodeSelectOverlay({super.key, required this.game});
  final NeonEchoGame game;

  @override
  Widget build(BuildContext context) {
    return NeonScaffold(
      accent: NeonPalette.magenta,
      child: Center(
        child: ListenableBuilder(
          listenable: game.state,
          builder: (context, _) {
            final unlocked = game.state.unlockedEpisode;
            final actions = <MenuAction>[
              for (final ep in game.story.episodes)
                MenuAction(
                  ep.number > unlocked
                      ? 'EP ${ep.number}   ${ep.title}   ·   LOCKED'
                      : 'EP ${ep.number}   ${ep.title}',
                  () => game.director.startEpisode(ep.number),
                  enabled: ep.number <= unlocked,
                  width: 520,
                ),
              MenuAction('◂  BACK TO MENU', game.director.showMainMenu,
                  color: NeonPalette.textDim, width: 520),
            ];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const GlitchTitle('EPISODES', fontSize: 44),
                const SizedBox(height: 10),
                const Text('↑ / ↓ to choose · ENTER to begin',
                    style: TextStyle(color: NeonPalette.textDim, fontSize: 12, letterSpacing: 1.5)),
                const SizedBox(height: 20),
                KeyboardMenu(actions: actions, spacing: 10),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ===========================================================================
// In-game cutscene HUD (title + continue button, no text content — text is
// rendered inside the CutsceneScene world via CutsceneSubtitle).
// ===========================================================================
class CutsceneHudOverlay extends StatefulWidget {
  const CutsceneHudOverlay({super.key, required this.game});
  final NeonEchoGame game;

  @override
  State<CutsceneHudOverlay> createState() => _CutsceneHudOverlayState();
}

class _CutsceneHudOverlayState extends State<CutsceneHudOverlay> {
  final FocusNode _node = FocusNode();

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  CutsceneScene? get _scene {
    final w = widget.game.world;
    return w is CutsceneScene ? w : null;
  }

  void _advance() {
    final scene = _scene;
    if (scene == null) return;
    if (scene.isShowingContinue) {
      widget.game.director.advance();
    } else {
      scene.advanceBeat();
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final advanceKeys = {
      LogicalKeyboardKey.enter,
      LogicalKeyboardKey.numpadEnter,
      LogicalKeyboardKey.space,
      LogicalKeyboardKey.arrowRight,
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.keyJ,
    };
    if (advanceKeys.contains(event.logicalKey)) {
      _advance();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  ({Color accent, Gradient gradient}) _mood(CutsceneMood mood) {
    switch (mood) {
      case CutsceneMood.present:
        return (accent: NeonPalette.cyan, gradient: NeonPalette.nightSky);
      case CutsceneMood.flashback:
        return (
          accent: NeonPalette.magenta,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0A2A), Color(0xFF3A1240), Color(0xFF5A1E66)],
          ),
        );
      case CutsceneMood.cliffhanger:
        return (
          accent: NeonPalette.hollowRed,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF120308), Color(0xFF330A12), Color(0xFF120308)],
          ),
        );
      case CutsceneMood.victory:
        return (
          accent: NeonPalette.amber,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A2A), Color(0xFF3A1E5A), Color(0xFFC9863A)],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scene = _scene;
    if (scene == null) return const SizedBox.shrink();
    final cs = scene.config;
    final mood = _mood(cs.mood);

    return Focus(
      focusNode: _node,
      autofocus: true,
      onKeyEvent: _onKey,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _advance,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            children: [
              // Title + location tag
              Row(
                children: [
                  neonTag(cs.title, color: mood.accent),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(cs.location,
                        style: const TextStyle(color: NeonPalette.textDim, fontSize: 12, letterSpacing: 2)),
                  ),
                ],
              ),
              const Spacer(),
              // Continue / hint bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    scene.isShowingContinue ? 'ENTER / TAP' : 'ENTER / TAP TO CONTINUE',
                    style: const TextStyle(color: NeonPalette.textDim, fontSize: 12, letterSpacing: 2),
                  ),
                  NeonButton(
                    label: scene.isShowingContinue ? cs.continueLabel : 'NEXT ▸',
                    width: 250,
                    primary: scene.isShowingContinue,
                    focused: true,
                    color: mood.accent,
                    onTap: _advance,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// In-game dialogue (subtitles + blocking comm pop-ups)
// ===========================================================================
class DialogueOverlay extends StatelessWidget {
  const DialogueOverlay({super.key, required this.game});
  final NeonEchoGame game;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: game.narrative,
      builder: (context, _) {
        final line = game.narrative.current;
        if (line == null) {
          return const IgnorePointer(child: SizedBox.expand());
        }
        if (game.narrative.isBlocking) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: game.narrative.advance,
            child: Container(
              color: Colors.black.withValues(alpha: 0.4),
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 70, left: 24, right: 24),
                child: _CommCard(line: line),
              ),
            ),
          );
        }
        return IgnorePointer(
          child: SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 96, left: 24, right: 24),
                child: _Subtitle(line: line),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CommCard extends StatelessWidget {
  const _CommCard({required this.line});
  final DialogueLine line;

  @override
  Widget build(BuildContext context) {
    final named = line.speaker.name.isNotEmpty;
    return Container(
      constraints: const BoxConstraints(maxWidth: 720),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      decoration: BoxDecoration(
        color: NeonPalette.voidBlack.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: line.speaker.color.withValues(alpha: 0.9), width: 2),
        boxShadow: [BoxShadow(color: line.speaker.color.withValues(alpha: 0.35), blurRadius: 18)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (named)
            Text('▸ ${line.speaker.name}',
                style: TextStyle(
                    color: line.speaker.color, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.6)),
          if (named) const SizedBox(height: 6),
          Text(line.text,
              style: TextStyle(
                color: NeonPalette.textBright,
                fontSize: 17,
                height: 1.4,
                fontStyle: named ? FontStyle.normal : FontStyle.italic,
              )),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerRight,
            child: Text('ENTER / J / TAP  ▸',
                style: TextStyle(color: NeonPalette.textDim, fontSize: 11, letterSpacing: 1.5)),
          ),
        ],
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle({required this.line});
  final DialogueLine line;

  @override
  Widget build(BuildContext context) {
    final named = line.speaker.name.isNotEmpty;
    return Container(
      constraints: const BoxConstraints(maxWidth: 760),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: NeonPalette.voidBlack.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(children: [
          if (named)
            TextSpan(
                text: '${line.speaker.name}:  ',
                style: TextStyle(
                    color: line.speaker.color, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1)),
          TextSpan(
              text: line.text,
              style: TextStyle(
                color: NeonPalette.textBright,
                fontSize: 14,
                height: 1.4,
                fontStyle: named ? FontStyle.normal : FontStyle.italic,
              )),
        ]),
      ),
    );
  }
}

// ===========================================================================
// HUD (non-interactive)
// ===========================================================================
class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.game});
  final NeonEchoGame game;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ListenableBuilder(
        listenable: game.state,
        builder: (context, _) {
          final s = game.state;
          return SafeArea(
            child: Stack(
              children: [
                Positioned(
                  left: 18,
                  top: 12,
                  right: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          neonTag(s.episodeTitle, color: s.flashback ? NeonPalette.magenta : NeonPalette.cyan),
                          if (s.flashback) ...[
                            const SizedBox(width: 8),
                            neonTag('MEMORY', color: NeonPalette.hotPink),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(s.objective,
                          style: const TextStyle(color: NeonPalette.textBright, fontSize: 13, letterSpacing: 0.5)),
                    ],
                  ),
                ),
                Positioned(
                  left: 18,
                  top: 66,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          for (var i = 0; i < s.maxHealth; i++)
                            Padding(
                              padding: const EdgeInsets.only(right: 3),
                              child: Icon(
                                i < s.health ? Icons.favorite : Icons.favorite_border,
                                color: i < s.health ? NeonPalette.hotPink : NeonPalette.textDim,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                      if (s.breathVisible) ...[
                        const SizedBox(height: 8),
                        _BreathBar(fraction: (s.breath / s.maxBreath).clamp(0, 1)),
                      ],
                    ],
                  ),
                ),
                if (s.toast != null)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 560),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: NeonPalette.voidBlack.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: NeonPalette.signalGreen.withValues(alpha: 0.8)),
                        ),
                        child: Text(s.toast!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: NeonPalette.signalGreen, fontSize: 13, fontStyle: FontStyle.italic)),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BreathBar extends StatelessWidget {
  const _BreathBar({required this.fraction});
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final color = fraction < 0.3 ? NeonPalette.danger : NeonPalette.waterGlow;
    return Row(
      children: [
        const Icon(Icons.air, color: NeonPalette.waterGlow, size: 16),
        const SizedBox(width: 6),
        Container(
          width: 160,
          height: 9,
          decoration: BoxDecoration(
            color: NeonPalette.voidBlack.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: NeonPalette.waterGlow.withValues(alpha: 0.5)),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: fraction,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 8)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// Pause / cleared / game over / victory
// ===========================================================================
class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, required this.game});
  final NeonEchoGame game;

  @override
  Widget build(BuildContext context) {
    return NeonScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const GlitchTitle('PAUSED', fontSize: 52),
            const SizedBox(height: 24),
            KeyboardMenu(actions: [
              MenuAction('RESUME', game.togglePause, primary: true),
              MenuAction('RESTART LEVEL', game.director.retryLevel, color: NeonPalette.amber),
              MenuAction('EPISODES', game.director.showEpisodeSelect, color: NeonPalette.magenta),
              MenuAction('QUIT TO MENU', game.director.showMainMenu, color: NeonPalette.textDim),
            ]),
          ],
        ),
      ),
    );
  }
}

class LevelClearedOverlay extends StatelessWidget {
  const LevelClearedOverlay({super.key, required this.game});
  final NeonEchoGame game;

  @override
  Widget build(BuildContext context) {
    return NeonScaffold(
      accent: NeonPalette.signalGreen,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            neonTag(game.state.flashback ? 'MEMORY COMPLETE' : 'SEQUENCE COMPLETE', color: NeonPalette.signalGreen),
            const SizedBox(height: 16),
            const GlitchTitle('CLEAR',
                fontSize: 64, gradient: LinearGradient(colors: [NeonPalette.signalGreen, NeonPalette.cyan])),
            const SizedBox(height: 14),
            SizedBox(
              width: 540,
              child: Text(game.state.objective,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: NeonPalette.textDim, fontSize: 14, height: 1.5)),
            ),
            const SizedBox(height: 26),
            KeyboardMenu(actions: [
              MenuAction('CONTINUE', game.director.continueAfterLevel, primary: true, color: NeonPalette.signalGreen),
            ]),
          ],
        ),
      ),
    );
  }
}

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key, required this.game});
  final NeonEchoGame game;

  @override
  Widget build(BuildContext context) {
    return NeonScaffold(
      accent: NeonPalette.danger,
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF120308), Color(0xFF2A0810), Color(0xFF120308)],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const GlitchTitle('SIGNAL LOST',
                fontSize: 56, gradient: LinearGradient(colors: [NeonPalette.danger, NeonPalette.hotPink])),
            const SizedBox(height: 14),
            const Text('Verge City does not wait. Try again from the last checkpoint.',
                style: TextStyle(color: NeonPalette.textDim, fontSize: 14)),
            const SizedBox(height: 26),
            KeyboardMenu(actions: [
              MenuAction('RETRY', game.director.retryLevel, primary: true, color: NeonPalette.danger),
              MenuAction('EPISODES', game.director.showEpisodeSelect, color: NeonPalette.magenta),
              MenuAction('QUIT TO MENU', game.director.showMainMenu, color: NeonPalette.textDim),
            ]),
          ],
        ),
      ),
    );
  }
}

class VictoryOverlay extends StatelessWidget {
  const VictoryOverlay({super.key, required this.game});
  final NeonEchoGame game;

  @override
  Widget build(BuildContext context) {
    return NeonScaffold(
      accent: NeonPalette.amber,
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0A0A2A), Color(0xFF3A1E5A), Color(0xFFC9863A)],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            neonTag('DAWN OVER VERGE CITY', color: NeonPalette.amber),
            const SizedBox(height: 16),
            const GlitchTitle('THE LIGHTS COME UP LIKE STARS',
                fontSize: 38,
                gradient: LinearGradient(colors: [NeonPalette.amber, NeonPalette.hotPink, NeonPalette.cyan])),
            const SizedBox(height: 18),
            const SizedBox(
              width: 620,
              child: Text(
                'James found Millie — thinner, scarred, changed, but hers. He stops '
                'trying to carry her, and just sits beside her as the city wakes.\n\n'
                'Thank you for playing NEON ECHO.',
                textAlign: TextAlign.center,
                style: TextStyle(color: NeonPalette.textBright, fontSize: 15, height: 1.6),
              ),
            ),
            const SizedBox(height: 28),
            KeyboardMenu(actions: [
              MenuAction('PLAY AGAIN', game.director.startNewGame, primary: true, color: NeonPalette.amber),
              MenuAction('EPISODES', game.director.showEpisodeSelect, color: NeonPalette.magenta),
              MenuAction('MAIN MENU', game.director.showMainMenu, color: NeonPalette.textDim),
            ]),
          ],
        ),
      ),
    );
  }
}
