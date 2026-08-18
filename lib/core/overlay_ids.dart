/// String identifiers for the Flutter overlays registered with the
/// `GameWidget`. Kept dependency-free so both the engine and the UI layer can
/// reference them without importing each other.
abstract final class OverlayIds {
  static const String mainMenu = 'main_menu';
  static const String episodeSelect = 'episode_select';
  static const String cutsceneTestMenu = 'cutscene_test_menu';
  static const String cutsceneHud = 'cutscene_hud';
  static const String hud = 'hud';
  static const String dialogue = 'dialogue';
  static const String pause = 'pause';
  static const String levelCleared = 'level_cleared';
  static const String gameOver = 'game_over';
  static const String victory = 'victory';
}
