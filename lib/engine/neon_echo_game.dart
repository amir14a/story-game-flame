import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show KeyEventResult;

import '../art/city/city_backdrop.dart';
import '../core/game_config.dart';
import '../core/input/game_input.dart';
import '../story/models/dialogue.dart';
import '../story/models/level_config.dart';
import '../story/story_repository.dart';
import 'controls.dart';
import 'game_state.dart';
import 'story_director.dart';

/// The root Flame game. A [Forge2DGame] so every level runs on the Box2D
/// physics world; the active [world] is swapped out for each [LevelScene].
///
/// It owns the cross-cutting singletons — input, state, the story repository and
/// the [StoryDirector] that walks the screenplay — and routes keyboard input
/// into the shared [GameInput].
class NeonEchoGame extends Forge2DGame with KeyboardEvents {
  NeonEchoGame()
      : super(
          gravity: GameConfig.gravity,
          zoom: GameConfig.zoom,
        );

  final GameInput input = GameInput();
  final GameState state = GameState();
  final StoryRepository story = StoryRepository();

  late final StoryDirector director;
  late final Controls controls;

  /// Theme read by the [CityBackdrop] to pick its atmosphere.
  DistrictTheme backdropTheme = DistrictTheme.rooftops;

  /// The cutscene currently being shown (read by the cutscene overlay).
  Cutscene? currentCutscene;

  bool _inLevel = false;
  bool _paused = false;
  bool get isPaused => _paused;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.backdrop = CityBackdrop();
    controls = Controls();
    director = StoryDirector(this);
    director.showMainMenu();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_inLevel && !_paused) {
      state.tick(dt);
    }
  }

  // --------------------------------------------------------------- level mode
  /// Marks the game as actively simulating a level: shows the controls and
  /// resumes the engine.
  void enterLevelMode() {
    _inLevel = true;
    _paused = false;
    if (!controls.isMounted) {
      camera.viewport.add(controls);
    }
    resumeEngine();
  }

  /// Freezes the world for menus / cutscenes and hides the controls.
  void enterOverlayMode() {
    _inLevel = false;
    _paused = false;
    input.clear();
    if (controls.isMounted) {
      controls.removeFromParent();
    }
    pauseEngine();
  }

  void togglePause() {
    if (!_inLevel) return;
    _paused = !_paused;
    if (_paused) {
      input.clear();
      pauseEngine();
      overlays.add('pause');
    } else {
      overlays.remove('pause');
      resumeEngine();
    }
  }

  // --------------------------------------------------------------- keyboard
  static final _left = {LogicalKeyboardKey.keyA, LogicalKeyboardKey.arrowLeft};
  static final _right = {LogicalKeyboardKey.keyD, LogicalKeyboardKey.arrowRight};
  static final _up = {LogicalKeyboardKey.keyW, LogicalKeyboardKey.arrowUp};
  static final _down = {LogicalKeyboardKey.keyS, LogicalKeyboardKey.arrowDown};
  static final _fire = {
    LogicalKeyboardKey.keyJ,
    LogicalKeyboardKey.keyK,
    LogicalKeyboardKey.enter,
  };
  static final _jump = {LogicalKeyboardKey.space};

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Pause toggle on key-down.
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
