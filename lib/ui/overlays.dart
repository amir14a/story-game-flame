import 'package:flutter/material.dart';

import '../core/overlay_ids.dart';
import '../core/palette.dart';
import '../engine/neon_echo_game.dart';
import '../story/models/dialogue.dart';
import '../story/models/episode.dart';
import 'widgets.dart';

/// Builds the overlay widget map registered with the `GameWidget`.
Map<String, Widget Function(BuildContext, NeonEchoGame)> buildOverlays() => {
      OverlayIds.mainMenu: (context, game) => MainMenuOverlay(game: game),
      OverlayIds.episodeSelect: (context, game) => EpisodeSelectOverlay(game: game),
      OverlayIds.cutscene: (context, game) => CutsceneOverlay(game: game),
      OverlayIds.hud: (context, game) => HudOverlay(game: game),
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
            neonTag('A CYBERPUNK STORY · NYX CITY', color: NeonPalette.magenta),
            const SizedBox(height: 14),
            const GlitchTitle('NEON ECHO', fontSize: 78),
            const SizedBox(height: 16),
            const SizedBox(
              width: 560,
              child: Text(
                'A brother hunts the neon-drowned sprawl for his missing sister, '
                'across five episodes — and back through everything they were.',
                textAlign: TextAlign.center,
                style: TextStyle(color: NeonPalette.textDim, fontSize: 15, height: 1.5),
              ),
            ),
            const SizedBox(height: 30),
            NeonButton(label: 'NEW GAME', primary: true, onTap: game.director.startNewGame),
            const SizedBox(height: 14),
            NeonButton(label: 'EPISODES', color: NeonPalette.magenta, onTap: game.director.showEpisodeSelect),
            const SizedBox(height: 26),
            const Text(
              'KEYBOARD  ·  A/D or ←/→ move  ·  W/↑ up  ·  SPACE jump  ·  J fire  ·  ESC pause\n'
              'TOUCH  ·  left stick + A (jump) + B (fire)',
              textAlign: TextAlign.center,
              style: TextStyle(color: NeonPalette.textDim, fontSize: 11, height: 1.6, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Episode select
// ===========================================================================
class EpisodeSelectOverlay extends StatelessWidget {
  const EpisodeSelectOverlay({super.key, required this.game});
  final NeonEchoGame game;

  @override
  Widget build(BuildContext context) {
    final episodes = game.story.episodes;
    final unlocked = game.state.unlockedEpisode;
    return NeonScaffold(
      accent: NeonPalette.magenta,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const GlitchTitle('EPISODES', fontSize: 40),
                const Spacer(),
                NeonButton(label: '◂ MENU', width: 150, onTap: game.director.showMainMenu),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    for (final ep in episodes)
                      _EpisodeCard(
                        episode: ep,
                        locked: ep.number > unlocked,
                        onTap: () => game.director.startEpisode(ep.number),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EpisodeCard extends StatelessWidget {
  const _EpisodeCard({required this.episode, required this.locked, required this.onTap});
  final Episode episode;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = locked ? NeonPalette.textDim : NeonPalette.cyan;
    return GestureDetector(
      onTap: locked ? null : onTap,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: NeonPalette.voidBlack.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.8), width: 1.6),
          boxShadow: [if (!locked) BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 16)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('EP ${episode.number}',
                    style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.w900)),
                const Spacer(),
                if (locked)
                  const Icon(Icons.lock_outline, color: NeonPalette.textDim, size: 22)
                else
                  const Icon(Icons.play_circle_outline, color: NeonPalette.cyan, size: 24),
              ],
            ),
            const SizedBox(height: 6),
            Text(episode.title,
                style: const TextStyle(color: NeonPalette.textBright, fontSize: 19, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(episode.tagline,
                style: const TextStyle(color: NeonPalette.textDim, fontSize: 12, letterSpacing: 1.4)),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Cutscene
// ===========================================================================
class CutsceneOverlay extends StatefulWidget {
  const CutsceneOverlay({super.key, required this.game});
  final NeonEchoGame game;

  @override
  State<CutsceneOverlay> createState() => _CutsceneOverlayState();
}

class _CutsceneOverlayState extends State<CutsceneOverlay> {
  int _revealed = 1;

  Cutscene get _cs => widget.game.currentCutscene!;

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

  void _advance() {
    final lines = _cs.lines;
    if (_revealed < lines.length) {
      setState(() => _revealed++);
    } else {
      widget.game.director.advance();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = _cs;
    final mood = _mood(cs.mood);
    final allRevealed = _revealed >= cs.lines.length;
    final shown = cs.lines.take(_revealed.clamp(0, cs.lines.length)).toList();

    return NeonScaffold(
      accent: mood.accent,
      gradient: mood.gradient,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _advance,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 24, 40, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  reverse: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final n in cs.narration)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(n,
                              style: const TextStyle(
                                  color: NeonPalette.textDim,
                                  fontSize: 15,
                                  height: 1.5,
                                  fontStyle: FontStyle.italic)),
                        ),
                      const SizedBox(height: 4),
                      for (var i = 0; i < shown.length; i++)
                        _DialogueBlock(line: shown[i], typing: i == shown.length - 1),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(allRevealed ? '' : 'TAP TO CONTINUE',
                      style: const TextStyle(color: NeonPalette.textDim, fontSize: 12, letterSpacing: 2)),
                  NeonButton(
                    label: allRevealed ? cs.continueLabel : 'NEXT ▸',
                    width: 240,
                    primary: allRevealed,
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

class _DialogueBlock extends StatelessWidget {
  const _DialogueBlock({required this.line, required this.typing});
  final DialogueLine line;
  final bool typing;

  @override
  Widget build(BuildContext context) {
    final isNarration = line.speaker.name.isEmpty;
    final textStyle = TextStyle(
      color: isNarration ? NeonPalette.textDim : NeonPalette.textBright,
      fontSize: isNarration ? 15 : 17,
      height: 1.45,
      fontStyle: isNarration || line.speaker.italic ? FontStyle.italic : FontStyle.normal,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isNarration)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(line.speaker.name,
                  style: TextStyle(
                      color: line.speaker.color, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
            ),
          typing ? TypingText(line.text, style: textStyle) : Text(line.text, style: textStyle),
        ],
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
                // top-left: episode + objective
                Positioned(
                  left: 18,
                  top: 12,
                  right: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          neonTag(s.episodeTitle,
                              color: s.flashback ? NeonPalette.magenta : NeonPalette.cyan),
                          if (s.flashback) ...[
                            const SizedBox(width: 8),
                            neonTag('MEMORY', color: NeonPalette.hotPink),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(s.objective,
                          style: const TextStyle(
                              color: NeonPalette.textBright, fontSize: 13, letterSpacing: 0.5)),
                    ],
                  ),
                ),
                // top-left under objective: health + breath
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
                // bottom-center: toast
                if (s.toast != null)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 520),
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
// Pause / Game over / Level cleared / Victory
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
            const SizedBox(height: 28),
            NeonButton(label: 'RESUME', primary: true, onTap: game.togglePause),
            const SizedBox(height: 12),
            NeonButton(label: 'RESTART LEVEL', color: NeonPalette.amber, onTap: game.director.retryLevel),
            const SizedBox(height: 12),
            NeonButton(label: 'EPISODES', color: NeonPalette.magenta, onTap: game.director.showEpisodeSelect),
            const SizedBox(height: 12),
            NeonButton(label: 'QUIT TO MENU', color: NeonPalette.textDim, onTap: game.director.showMainMenu),
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
            neonTag(game.state.flashback ? 'MEMORY COMPLETE' : 'SEQUENCE COMPLETE',
                color: NeonPalette.signalGreen),
            const SizedBox(height: 16),
            const GlitchTitle('CLEAR', fontSize: 64, gradient: LinearGradient(colors: [NeonPalette.signalGreen, NeonPalette.cyan])),
            const SizedBox(height: 14),
            SizedBox(
              width: 520,
              child: Text(game.state.objective,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: NeonPalette.textDim, fontSize: 14, height: 1.5)),
            ),
            const SizedBox(height: 28),
            NeonButton(label: 'CONTINUE', primary: true, color: NeonPalette.signalGreen, onTap: game.director.continueAfterLevel),
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
            const GlitchTitle('SIGNAL LOST', fontSize: 56, gradient: LinearGradient(colors: [NeonPalette.danger, NeonPalette.hotPink])),
            const SizedBox(height: 14),
            const Text("Nyx City doesn't wait. Try again.",
                style: TextStyle(color: NeonPalette.textDim, fontSize: 14)),
            const SizedBox(height: 28),
            NeonButton(label: 'RETRY', primary: true, color: NeonPalette.danger, onTap: game.director.retryLevel),
            const SizedBox(height: 12),
            NeonButton(label: 'EPISODES', color: NeonPalette.magenta, onTap: game.director.showEpisodeSelect),
            const SizedBox(height: 12),
            NeonButton(label: 'QUIT TO MENU', color: NeonPalette.textDim, onTap: game.director.showMainMenu),
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
            neonTag('DAWN OVER NYX CITY', color: NeonPalette.amber),
            const SizedBox(height: 16),
            const GlitchTitle('THE HOLLOW HAS FALLEN',
                fontSize: 44, gradient: LinearGradient(colors: [NeonPalette.amber, NeonPalette.hotPink, NeonPalette.cyan])),
            const SizedBox(height: 18),
            const SizedBox(
              width: 600,
              child: Text(
                'Kade and Aria stand at the top of the world, side by side. The '
                'upload is done. The truth is everywhere now. Two kids from Lowtown '
                'kept their promise.\n\nThank you for playing NEON ECHO.',
                textAlign: TextAlign.center,
                style: TextStyle(color: NeonPalette.textBright, fontSize: 15, height: 1.6),
              ),
            ),
            const SizedBox(height: 30),
            NeonButton(label: 'PLAY AGAIN', primary: true, color: NeonPalette.amber, onTap: game.director.startNewGame),
            const SizedBox(height: 12),
            NeonButton(label: 'EPISODES', color: NeonPalette.magenta, onTap: game.director.showEpisodeSelect),
            const SizedBox(height: 12),
            NeonButton(label: 'MAIN MENU', color: NeonPalette.textDim, onTap: game.director.showMainMenu),
          ],
        ),
      ),
    );
  }
}
