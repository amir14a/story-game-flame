import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show KeyEventResult;

import '../art/city/city_backdrop.dart';
import '../core/game_config.dart';
import '../core/input/game_input.dart';
import '../story/models/level_config.dart';
import '../story/story_repository.dart';
import 'controls.dart';
import 'game_state.dart';
import 'narrative/dialogue_runner.dart';
import 'story_director.dart';

/// The root Flame game. A [Forge2DGame] so every level runs on the Box2D
/// physics world; the active [world] is swapped out for each [LevelScene].
///
/// Owns the cross-cutting singletons — input, state, the story, the
/// [StoryDirector] and the in-game [DialogueRunner] — and routes keyboard input.
class NeonEchoGame extends Forge2DGame with KeyboardEvents {
  NeonEchoGame() : super(gravity: GameConfig.gravity, zoom: GameConfig.zoom);

  final GameInput input = GameInput();
  final GameState state = GameState();
  final StoryRepository story = StoryRepository();
  final DialogueRunner narrative = DialogueRunner();

  late final StoryDirector director;
  late final Controls controls;

  DistrictTheme backdropTheme = DistrictTheme.rooftops;

  bool _inLevel = false;
  bool _paused = false;
  bool get isPaused => _paused;
  bool get isInLevel => _inLevel;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.backdrop = CityBackdrop();

    // The controls live in the viewport for the whole session and are merely
    // shown/hidden — adding/removing them was the cause of them vanishing.
    controls = Controls()..active = false;
    await camera.viewport.add(controls);

    // Blocking dialogue (meetings / key comms) soft-pauses the action.
    narrative.onBlockingStart = pauseEngine;
    narrative.onBlockingEnd = () {
      if (_inLevel && !_paused) {
        resumeEngine();
      }
    };

    director = StoryDirector(this);
    director.showMainMenu();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_inLevel && !_paused) {
      state.tick(dt);
      narrative.tick(dt);
    }
  }

  // --------------------------------------------------------------- level mode
  void enterLevelMode() {
    _inLevel = true;
    _paused = false;
    controls.active = true;
    resumeEngine();
  }

  /// Cutscene mode: engine runs (for animations / beat timing) but player
  /// controls are hidden and input is cleared.
  void enterCutsceneMode() {
    _inLevel = false;
    _paused = false;
    input.clear();
    controls.active = false;
    resumeEngine();
  }

  void enterOverlayMode() {
    _inLevel = false;
    _paused = false;
    input.clear();
    narrative.reset();
    controls.active = false;
    pauseEngine();
  }

  void togglePause() {
    if (!_inLevel) {
      return;
    }
    _paused = !_paused;
    if (_paused) {
      input.clear();
      controls.active = false;
      pauseEngine();
      overlays.add('pause');
    } else {
      overlays.remove('pause');
      controls.active = true;
      resumeEngine();
    }
  }

  // --------------------------------------------------------------- keyboard
  static final _left = {LogicalKeyboardKey.keyA, LogicalKeyboardKey.arrowLeft};
  static final _right = {
    LogicalKeyboardKey.keyD,
    LogicalKeyboardKey.arrowRight,
  };
  static final _up = {LogicalKeyboardKey.keyW, LogicalKeyboardKey.arrowUp};
  static final _down = {LogicalKeyboardKey.keyS, LogicalKeyboardKey.arrowDown};
  static final _fire = {
    LogicalKeyboardKey.keyJ,
    LogicalKeyboardKey.keyK,
    LogicalKeyboardKey.enter,
  };
  static final _jump = {LogicalKeyboardKey.space};
  static final _advance = {
    LogicalKeyboardKey.space,
    LogicalKeyboardKey.enter,
    LogicalKeyboardKey.keyJ,
    LogicalKeyboardKey.keyK,
  };

  // ---- debug cheat: the Konami code unlocks every episode ----
  static final List<LogicalKeyboardKey> _cheatSequence = [
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.keyB,
    LogicalKeyboardKey.keyA,
  ];
  final List<LogicalKeyboardKey> _cheatBuffer = [];

  void _checkCheat(KeyEvent event) {
    if (!kDebugMode || event is! KeyDownEvent) {
      return;
    }
    _cheatBuffer.add(event.logicalKey);
    if (_cheatBuffer.length > _cheatSequence.length) {
      _cheatBuffer.removeAt(0);
    }
    if (_cheatBuffer.length == _cheatSequence.length) {
      for (var i = 0; i < _cheatSequence.length; i++) {
        if (_cheatBuffer[i] != _cheatSequence[i]) {
          return;
        }
      }
      _cheatBuffer.clear();
      state.unlockAll(story.episodeCount);
      state.showToast('CHEAT UNLOCKED — all episodes available');
    }
  }

  // The debug cutscene test menu is unlocked via a hidden touch gesture on the
  // main menu (see MainMenuOverlay) so it is reachable on touch devices too.

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    _checkCheat(event);

    // While a blocking exchange is up, the action keys advance it.
    if (narrative.isBlocking) {
      if (event is KeyDownEvent && _advance.contains(event.logicalKey)) {
        narrative.advance();
      }
      return KeyEventResult.handled;
    }

    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.escape ||
            event.logicalKey == LogicalKeyboardKey.keyP)) {
      togglePause();
      return KeyEventResult.handled;
    }

    bool any(Set<LogicalKeyboardKey> keys) => keys.any(keysPressed.contains);

    var x = 0.0;
    if (any(_left)) x -= 1;
    if (any(_right)) x += 1;

    input.setKeyboard(
      x: x,
      up: any(_up),
      down: any(_down),
      fire: any(_fire),
      jump: any(_jump),
    );
    return KeyEventResult.handled;
  }
}
