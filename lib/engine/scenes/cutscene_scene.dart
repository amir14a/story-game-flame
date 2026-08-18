import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/painting.dart' show InlineSpan, TextStyle, TextSpan, TextPainter, TextDirection;

import '../../art/character_art.dart';
import '../../art/lighting.dart';
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

  void moveTo(double x, double y, {double speed = 6.0, CharacterPose pose = CharacterPose.run}) {
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

    // Subtitle background
    final bgRect = Rect.fromLTWH(w * 0.08, h - 80, w * 0.84, 56);
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
        children.add(TextSpan(
          text: '${line!.speaker.name}:  ',
          style: TextStyle(
            color: line!.speaker.color,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ));
      }
      children.add(TextSpan(
        text: line!.text,
        style: TextStyle(
          color: NeonPalette.textBright,
          fontSize: 14,
          height: 1.4,
          fontStyle: named ? FontStyle.normal : FontStyle.italic,
        ),
      ));
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
  bool _waitingForInput = false;
  bool _allBeatsDone = false;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    game.backdropTheme = config.theme;

    // Ground platform (simple, not visible — characters float against the backdrop)
    final groundY = 10.0;
    add(PlatformBody(
      rect: Rect.fromLTWH(-2, groundY, config.worldWidth + 4, 2),
      color: const Color(0x00000000),
    ));

    // Subtitle renderer
    _subtitle = CutsceneSubtitle();
    add(_subtitle);

    // Spawn characters based on the first beats that reference them
    _spawnInitialCharacters();

    // Camera
    final camera = game.camera;
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

    // Show cutscene HUD overlay
    _showOverlay(true);
  }

  @override
  void onRemove() {
    _showOverlay(false);
    super.onRemove();
  }

  /// Scan the first few beats to find character references and spawn them
  /// at sensible starting positions.
  void _spawnInitialCharacters() {
    final spawned = <Character>{};
    for (final beat in config.beats) {
      if (beat is MoveCharacterBeat && !spawned.contains(beat.character)) {
        final x = beat.targetX;
        final y = beat.targetY;
        _addCharacter(beat.character, x, y);
        spawned.add(beat.character);
      }
      if (beat is LookAtBeat && !spawned.contains(beat.character)) {
        // Character exists but we don't know position — place at center
        _addCharacter(beat.character, config.worldWidth / 2, 8.3);
        spawned.add(beat.character);
      }
      if (beat is PoseBeat && !spawned.contains(beat.character)) {
        _addCharacter(beat.character, config.worldWidth / 2, 8.3);
        spawned.add(beat.character);
      }
    }
    // If no characters were spawned, add James at center as default
    if (spawned.isEmpty) {
      _addCharacter(Character.james, config.worldWidth / 2, 8.3);
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
          if (!char.isMoving) {
            char.moveTo(beat.targetX, beat.targetY, speed: beat.speed, pose: beat.pose);
          }
          if (!char.isMoving) {
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
    // Show the continue overlay
    _showOverlay(true, showContinue: true);
  }

  void _showOverlay(bool show, {bool showContinue = false}) {
    if (show) {
      game.overlays.add(OverlayIds.cutsceneHud);
    } else {
      game.overlays.remove(OverlayIds.cutsceneHud);
    }
    _showingContinue = showContinue;
  }

  bool _showingContinue = false;
  bool get isShowingContinue => _showingContinue;
}
