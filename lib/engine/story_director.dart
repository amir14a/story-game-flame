import '../core/overlay_ids.dart';
import '../story/models/episode.dart';
import '../story/models/level_config.dart';
import 'neon_echo_game.dart';
import 'scenes/level_scene.dart';

/// Drives the screenplay. Given the current episode/phase in [GameState], it
/// presents the right thing — a cutscene overlay or a playable [LevelScene] —
/// and advances when a phase reports completion. This is the only place that
/// knows the order of beats, keeping both the engine and the UI dumb.
class StoryDirector {
  StoryDirector(this.game);

  final NeonEchoGame game;

  static const List<String> _allStoryOverlays = [
    OverlayIds.mainMenu,
    OverlayIds.episodeSelect,
    OverlayIds.cutscene,
    OverlayIds.hud,
    OverlayIds.levelCleared,
    OverlayIds.gameOver,
    OverlayIds.victory,
  ];

  Episode get _episode => game.story.episodes[game.state.episodeIndex];
  StoryPhase get _phase => _episode.phases[game.state.phaseIndex];

  // ---------------------------------------------------------------- menus
  void showMainMenu() {
    game.enterOverlayMode();
    _setOverlay(OverlayIds.mainMenu);
  }

  void showEpisodeSelect() {
    game.enterOverlayMode();
    _setOverlay(OverlayIds.episodeSelect);
  }

  void startNewGame() => startEpisode(1);

  /// Begins an episode from its first phase ([number] is 1-based).
  void startEpisode(int number) {
    game.state.episodeIndex = (number - 1).clamp(0, game.story.episodeCount - 1);
    game.state.phaseIndex = 0;
    _present();
  }

  // ------------------------------------------------------------ presenting
  void _present() {
    final phase = _phase;
    switch (phase) {
      case CutscenePhase():
        game.enterOverlayMode();
        game.currentCutscene = phase.cutscene;
        _setOverlay(OverlayIds.cutscene);
      case LevelPhase():
        _loadLevel(phase.config);
    }
  }

  void _loadLevel(LevelConfig config) {
    game.currentCutscene = null;
    _setOverlay(OverlayIds.hud);
    game.world = LevelScene(config, episodeLabel: 'EPISODE ${_episode.number} · ${_episode.title}');
    game.enterLevelMode();
  }

  // --------------------------------------------------------------- advance
  /// Called by the cutscene overlay's continue button, and after a level clear.
  void advance() {
    game.state.phaseIndex++;
    if (game.state.phaseIndex >= _episode.phases.length) {
      _endEpisode();
      return;
    }
    _present();
  }

  void _endEpisode() {
    final nextIndex = game.state.episodeIndex + 1;
    if (nextIndex >= game.story.episodeCount) {
      // The whole story is finished.
      game.enterOverlayMode();
      _setOverlay(OverlayIds.victory);
      return;
    }
    game.state.unlockedEpisode = (nextIndex + 1).clamp(1, game.story.episodeCount);
    game.state.episodeIndex = nextIndex;
    game.state.phaseIndex = 0;
    _present();
  }

  // ----------------------------------------------- level outcome callbacks
  void onLevelCleared() {
    game.enterOverlayMode();
    _setOverlay(OverlayIds.levelCleared);
  }

  void continueAfterLevel() => advance();

  void onPlayerDied() {
    game.enterOverlayMode();
    _setOverlay(OverlayIds.gameOver);
  }

  /// Rebuilds the current level from scratch.
  void retryLevel() => _present();

  // ----------------------------------------------------------------- util
  void _setOverlay(String id) {
    for (final name in _allStoryOverlays) {
      game.overlays.remove(name);
    }
    game.overlays.remove(OverlayIds.pause);
    game.overlays.add(id);
  }
}
