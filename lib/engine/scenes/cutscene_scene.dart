import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter/painting.dart'
    show InlineSpan, TextStyle, TextSpan, TextPainter, TextDirection;

import '../../art/character_art.dart';
import '../../art/lighting.dart';
import '../../art/neon.dart';
import '../../core/overlay_ids.dart';
import '../../core/palette.dart';
import '../../story/models/cutscene_config.dart';
import '../../story/models/dialogue.dart';
import '../../story/models/level_config.dart';
import '../neon_echo_game.dart';
import 'terrain.dart';

// ---------------------------------------------------------------------------
// CutsceneCharacter — a lightweight entity that draws a character in the scene
// without any physics body. Supports tweening to a target position.
// ---------------------------------------------------------------------------

class CutsceneCharacter extends Component with HasGameReference<NeonEchoGame> {
  CutsceneCharacter({
    required this.character,
    required Vector2 startPos,
    this.facing = 1,
    this.pose = CharacterPose.idle,
  }) : position = startPos.clone();

  final Character character;
  Vector2 position;
  int facing;
  CharacterPose pose;

  Vector2? _target;
  double _speed = 6.0;
  bool get isMoving => _target != null;

  void moveTo(
    double x,
    double y, {
    double speed = 6.0,
    CharacterPose pose = CharacterPose.run,
  }) {
    _target = Vector2(x, y);
    _speed = speed;
    this.pose = pose;
    // Face the direction of movement
    if ((x - position.x).abs() > 0.1) {
      facing = x > position.x ? 1 : -1;
    }
  }

  void look(int dir) {
    facing = dir;
  }

  /// Immediately completes any in-progress move (used when skipping ahead).
  void snapToTarget() {
    if (_target == null) return;
    position = _target!.clone();
    _target = null;
    pose = CharacterPose.idle;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_target == null) return;
    final dir = _target! - position;
    final dist = dir.length;
    if (dist < 0.15) {
      position = _target!.clone();
      _target = null;
      pose = CharacterPose.idle;
      return;
    }
    dir.normalize();
    position += dir * _speed * dt;
    // Keep facing updated during movement
    if (dir.x.abs() > 0.01) {
      facing = dir.x > 0 ? 1 : -1;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Translate canvas so the character is drawn at its world position.
    // Camera transform is already applied by the world; we just offset.
    canvas.save();
    canvas.translate(position.x, position.y);
    CharacterArtist.draw(
      canvas,
      character: character,
      t: game.currentTime(),
      facing: facing,
      pose: pose,
    );
    canvas.restore();
  }
}

// ---------------------------------------------------------------------------
// CutsceneProp — a decorative, non-interactive object drawn in world space
// (a paper crane, a data shard, a street lamp, distant window lights).
// ---------------------------------------------------------------------------

class CutsceneProp extends Component with HasGameReference<NeonEchoGame> {
  CutsceneProp({required this.kind, required Vector2 pos})
    : position = pos.clone();

  final CutscenePropKind kind;
  final Vector2 position;

  double _t = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.save();
    canvas.translate(position.x, position.y);
    switch (kind) {
      case CutscenePropKind.paperCrane:
        _drawPaperCrane(canvas, _t);
      case CutscenePropKind.dataShard:
        _drawDataShard(canvas, _t);
      case CutscenePropKind.streetLamp:
        _drawStreetLamp(canvas, _t);
      case CutscenePropKind.windowLights:
        _drawWindowLights(canvas, _t);
    }
    canvas.restore();
  }

  static void _drawPaperCrane(Canvas canvas, double t) {
    final bob = 0.05 * math.sin(t * 1.6);
    final c = Offset(0, bob);
    final body = Path()
      ..moveTo(c.dx, c.dy - 0.12)
      ..lineTo(c.dx + 0.22, c.dy + 0.06)
      ..lineTo(c.dx, c.dy + 0.16)
      ..lineTo(c.dx - 0.22, c.dy + 0.06)
      ..close();
    Neon.glowPath(
      canvas,
      body,
      NeonPalette.textBright,
      0.03,
      filled: true,
      fillAlpha: 0.3,
    );
    // wings
    Neon.glowLine(
      canvas,
      c,
      Offset(c.dx + 0.3, c.dy - 0.22),
      NeonPalette.cyan,
      0.025,
    );
    Neon.glowLine(
      canvas,
      c,
      Offset(c.dx - 0.3, c.dy - 0.22),
      NeonPalette.cyan,
      0.025,
    );
    // neck + tail
    Neon.glowLine(
      canvas,
      c,
      Offset(c.dx + 0.24, c.dy - 0.28),
      NeonPalette.textBright,
      0.02,
    );
    Neon.glowLine(
      canvas,
      c,
      Offset(c.dx - 0.3, c.dy + 0.02),
      NeonPalette.textBright,
      0.02,
    );
  }

  static void _drawDataShard(Canvas canvas, double t) {
    final pulse = 0.5 + 0.5 * math.sin(t * 3);
    final shard = Path()
      ..moveTo(0, -0.2)
      ..lineTo(0.12, 0)
      ..lineTo(0, 0.24)
      ..lineTo(-0.12, 0)
      ..close();
    Neon.glowPath(
      canvas,
      shard,
      NeonPalette.signalGreen,
      0.02,
      filled: true,
      fillAlpha: 0.2 + 0.2 * pulse,
    );
    Neon.halo(
      canvas,
      Offset.zero,
      0.4,
      NeonPalette.signalGreen,
      alpha: 0.15 + 0.15 * pulse,
    );
  }

  static void _drawStreetLamp(Canvas canvas, double t) {
    Neon.glowLine(
      canvas,
      const Offset(0, 0),
      const Offset(0, -2.2),
      NeonPalette.hollowSteel,
      0.05,
    );
    Neon.glowCircle(
      canvas,
      const Offset(0, -2.2),
      0.14,
      NeonPalette.amber,
      0.03,
      filled: true,
      fillAlpha: 0.4,
    );
    Neon.halo(
      canvas,
      const Offset(0, -2.2),
      1.4,
      NeonPalette.amber,
      alpha: 0.18,
    );
  }

  static void _drawWindowLights(Canvas canvas, double t) {
    for (var i = 0; i < 5; i++) {
      final flicker = 0.5 + 0.5 * math.sin(t * 0.8 + i * 1.7);
      final x = (i - 2) * 0.5;
      final y = -0.3 * (i.isEven ? 1 : -1);
      Neon.glowRRect(
        canvas,
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y), width: 0.3, height: 0.24),
          const Radius.circular(0.02),
        ),
        NeonPalette.amber,
        0.015,
        filled: true,
        fillAlpha: 0.15 + 0.2 * flicker,
      );
    }
  }
}

// ---------------------------------------------------------------------------
// CutsceneSubtitle — renders the current dialogue/narration text as a
// semi-transparent subtitle at the bottom of the screen.
// ---------------------------------------------------------------------------

class CutsceneSubtitle extends Component with HasGameReference<NeonEchoGame> {
  CutsceneSubtitle({this.line, this.narration});

  DialogueLine? line;
  String? narration;

  void showLine(DialogueLine l) {
    line = l;
    narration = null;
  }

  void showNarration(String text) {
    narration = text;
    line = null;
  }

  void clear() {
    line = null;
    narration = null;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (line == null && narration == null) return;

    final size = game.size;
    final w = size.x;
    final h = size.y;

    // Subtitle background — the HUD overlay no longer has a bottom bar (just
    // a small skip button up top), so this sits near the bottom edge.
    final bgRect = Rect.fromLTWH(w * 0.08, h - 96, w * 0.84, 56);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(6)),
      Paint()..color = NeonPalette.voidBlack.withValues(alpha: 0.72),
    );

    final tp = TextPainter(textDirection: TextDirection.ltr);

    if (narration != null) {
      tp.text = TextSpan(
        text: narration,
        style: TextStyle(
          color: NeonPalette.textDim,
          fontSize: 14,
          height: 1.5,
          fontStyle: FontStyle.italic,
        ),
      );
    } else if (line != null) {
      final named = line!.speaker.name.isNotEmpty;
      final children = <InlineSpan>[];
      if (named) {
        children.add(
          TextSpan(
            text: '${line!.speaker.name}:  ',
            style: TextStyle(
              color: line!.speaker.color,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        );
      }
      children.add(
        TextSpan(
          text: line!.text,
          style: TextStyle(
            color: NeonPalette.textBright,
            fontSize: 14,
            height: 1.4,
            fontStyle: named ? FontStyle.normal : FontStyle.italic,
          ),
        ),
      );
      tp.text = TextSpan(children: children);
    }

    tp.layout(maxWidth: bgRect.width - 32);
    tp.paint(canvas, Offset(bgRect.left + 16, bgRect.top + 8));
  }
}

// ---------------------------------------------------------------------------
// CutsceneScene — a minimal Forge2DWorld that plays scripted beats.
// ---------------------------------------------------------------------------

class CutsceneScene extends Forge2DWorld with HasGameReference<NeonEchoGame> {
  CutsceneScene(this.config);

  final CutsceneConfig config;

  final List<CutsceneCharacter> _characters = [];
  late final CutsceneSubtitle _subtitle;

  final List<CutsceneBeat> _beats = [];
  int _beatIndex = 0;
  double _timer = 0;
  bool _moveStarted = false;
  bool _waitingForInput = false;
  bool _allBeatsDone = false;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    game.backdropTheme = config.theme;

    // Ground platform (simple, not visible — characters float against the backdrop)
    final groundY = config.groundY;
    add(
      PlatformBody(
        rect: Rect.fromLTWH(-2, groundY, config.worldWidth + 4, 2),
        color: const Color(0x00000000),
      ),
    );

    // Props present from the start
    for (final p in config.props) {
      add(CutsceneProp(kind: p.kind, pos: Vector2(p.x, p.y)));
    }

    // Subtitle renderer — lives in the viewport (screen space), not the world,
    // since it positions itself using pixel offsets against game.size.
    _subtitle = CutsceneSubtitle();
    await game.camera.viewport.add(_subtitle);

    // Spawn characters based on the first beats that reference them
    _spawnInitialCharacters();

    // Camera — stop() clears any FollowBehavior left over from a previous
    // LevelScene, otherwise it keeps chasing its old target and fights the
    // static position set below (camera appears to race off and nothing
    // stays on screen).
    final camera = game.camera;
    camera.stop();
    camera.viewfinder.position = Vector2(config.worldWidth / 2, groundY - 2);
    camera.setBounds(
      Rectangle.fromLTRB(0, 0, config.worldWidth, groundY + 10),
      considerViewport: true,
    );

    // Lighting
    add(LightingLayer());

    // Start beat playback
    _beats.addAll(config.beats);
    _beatIndex = 0;

    // Show cutscene HUD overlay. Removal is owned by StoryDirector so an
    // episode-boundary transition to another cutscene doesn't race (see
    // onRemove).
    game.overlays.add(OverlayIds.cutsceneHud);
  }

  @override
  void onRemove() {
    // NB: do NOT remove the cutscene HUD overlay here. On an episode-boundary
    // cutscene→cutscene transition the incoming scene's onLoad has already
    // re-added it, and removing it from the outgoing scene's onRemove would
    // race and leave the new cutscene with no HUD (the "can't continue" bug).
    // Overlay removal is owned by StoryDirector (_clearAllOverlays/_setOverlay).
    _subtitle.removeFromParent();
    showingContinue.dispose();
    super.onRemove();
  }

  /// Scan the first few beats to find character references and spawn them
  /// at sensible starting positions.
  void _spawnInitialCharacters() {
    final spawned = <Character>{};
    for (final beat in config.beats) {
      if (beat is PlaceCharacterBeat && !spawned.contains(beat.character)) {
        final c = _addCharacter(beat.character, beat.x, beat.y);
        c.facing = beat.facing;
        c.pose = beat.pose;
        spawned.add(beat.character);
      }
      if (beat is MoveCharacterBeat && !spawned.contains(beat.character)) {
        final x = beat.targetX;
        final y = beat.targetY;
        _addCharacter(beat.character, x, y);
        spawned.add(beat.character);
      }
      if (beat is LookAtBeat && !spawned.contains(beat.character)) {
        // Character exists but we don't know position — place at center
        _addCharacter(
          beat.character,
          config.worldWidth / 2,
          config.groundY - 1.7,
        );
        spawned.add(beat.character);
      }
      if (beat is PoseBeat && !spawned.contains(beat.character)) {
        _addCharacter(
          beat.character,
          config.worldWidth / 2,
          config.groundY - 1.7,
        );
        spawned.add(beat.character);
      }
    }
    // If no characters were spawned, add James at center as default
    if (spawned.isEmpty) {
      _addCharacter(
        Character.james,
        config.worldWidth / 2,
        config.groundY - 1.7,
      );
    }
  }

  CutsceneCharacter _addCharacter(Character character, double x, double y) {
    final c = CutsceneCharacter(character: character, startPos: Vector2(x, y));
    _characters.add(c);
    add(c);
    return c;
  }

  CutsceneCharacter? _getCharacter(Character character) {
    for (final c in _characters) {
      if (c.character == character) return c;
    }
    return null;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_allBeatsDone) return;

    // Process current beat
    if (_beatIndex < _beats.length) {
      final beat = _beats[_beatIndex];
      switch (beat) {
        case PlaceCharacterBeat():
          _beatIndex++;
        case PauseBeat():
          _timer += dt;
          if (_timer >= beat.duration) {
            _timer = 0;
            _beatIndex++;
          }
        case DialogueBeat():
          if (!_waitingForInput) {
            _subtitle.showLine(beat.line);
            _waitingForInput = true;
          }
        case NarrationBeat():
          if (!_waitingForInput) {
            _subtitle.showNarration(beat.text);
            _timer = 0;
            _waitingForInput = true;
          }
          if (_waitingForInput) {
            _timer += dt;
            if (_timer >= 3.0) {
              _subtitle.clear();
              _timer = 0;
              _waitingForInput = false;
              _beatIndex++;
            }
          }
        case MoveCharacterBeat():
          final char = _getCharacter(beat.character);
          if (char == null) {
            _beatIndex++;
            break;
          }
          if (!_moveStarted) {
            char.moveTo(
              beat.targetX,
              beat.targetY,
              speed: beat.speed,
              pose: beat.pose,
            );
            _moveStarted = true;
          } else if (!char.isMoving) {
            _moveStarted = false;
            _beatIndex++;
          }
        case LookAtBeat():
          final char = _getCharacter(beat.character);
          if (char != null) {
            char.look(beat.facing);
          }
          _beatIndex++;
        case PoseBeat():
          final char = _getCharacter(beat.character);
          if (char != null) {
            char.pose = beat.pose;
          }
          _beatIndex++;
        case SpawnPropBeat():
          add(CutsceneProp(kind: beat.kind, pos: Vector2(beat.x, beat.y)));
          _beatIndex++;
      }
    } else if (!_allBeatsDone) {
      _allBeatsDone = true;
      _onAllBeatsComplete();
    }
  }

  /// Called by the overlay when the player taps/clicks during a dialogue or
  /// narration beat to advance to the next beat.
  void advanceBeat() {
    if (_beatIndex >= _beats.length || _allBeatsDone) return;
    final beat = _beats[_beatIndex];
    if (beat is DialogueBeat || beat is NarrationBeat) {
      _subtitle.clear();
      _timer = 0;
      _waitingForInput = false;
      _beatIndex++;
    }
  }

  void _onAllBeatsComplete() {
    _subtitle.clear();
    // The HUD is already up (added in onLoad); just flip the flag so the
    // overlay reveals its continue button.
    showingContinue.value = true;
  }

  /// Called by the overlay's skip button — jumps straight past all remaining
  /// beats to the end-of-cutscene continue state, snapping any characters
  /// still mid-move to their targets so nothing is left stranded off-position.
  void skipToEnd() {
    if (_allBeatsDone) return;
    for (final c in _characters) {
      c.snapToTarget();
    }
    _beatIndex = _beats.length;
    _moveStarted = false;
    _waitingForInput = false;
    _allBeatsDone = true;
    _onAllBeatsComplete();
  }

  /// Whether all beats have finished and the "continue" prompt is up. Exposed
  /// as a [ValueNotifier] so the HUD overlay can rebuild the moment the
  /// cutscene ends and reveal the continue button.
  final ValueNotifier<bool> showingContinue = ValueNotifier<bool>(false);
  bool get isShowingContinue => showingContinue.value;
}
