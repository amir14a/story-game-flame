import 'package:flutter/foundation.dart';

import '../core/game_config.dart';
import '../story/models/dialogue.dart';

/// Mutable, observable game progress + live HUD values.
///
/// Extends [ChangeNotifier] so the Flutter HUD overlay can rebuild reactively
/// without the game reaching into widgets.
class GameState extends ChangeNotifier {
  // ---- progression -------------------------------------------------------
  int episodeIndex = 0; // 0-based index into StoryRepository.episodes
  int phaseIndex = 0;

  /// Highest episode number (1-based) the player has unlocked.
  int unlockedEpisode = 1;

  // ---- live level values (HUD) ------------------------------------------
  Character activeCharacter = Character.kade;
  String episodeTitle = '';
  String objective = '';
  bool flashback = false;

  int maxHealth = GameConfig.playerMaxHealth;
  int health = GameConfig.playerMaxHealth;

  bool breathVisible = false;
  double maxBreath = GameConfig.maxBreath;
  double breath = GameConfig.maxBreath;

  /// A transient toast line (e.g. a clue picked up). Cleared after a few sec.
  String? toast;
  double _toastTimer = 0;

  void beginLevel({
    required Character character,
    required String episodeTitle,
    required String objective,
    required bool flashback,
    required bool showBreath,
  }) {
    activeCharacter = character;
    this.episodeTitle = episodeTitle;
    this.objective = objective;
    this.flashback = flashback;
    breathVisible = showBreath;
    maxHealth = GameConfig.playerMaxHealth;
    health = maxHealth;
    maxBreath = GameConfig.maxBreath;
    breath = maxBreath;
    toast = null;
    _toastTimer = 0;
    notifyListeners();
  }

  void damage(int amount) {
    health = (health - amount).clamp(0, maxHealth);
    notifyListeners();
  }

  bool get isDead => health <= 0;

  /// Unlocks every episode (used by the debug-only cheat code).
  void unlockAll(int episodeCount) {
    if (unlockedEpisode >= episodeCount) {
      return;
    }
    unlockedEpisode = episodeCount;
    notifyListeners();
  }

  void setBreath(double value) {
    breath = value.clamp(0, maxBreath);
  }

  void showToast(String message) {
    toast = message;
    _toastTimer = 4.5;
    notifyListeners();
  }

  /// Called every frame from the game loop to advance timers and push HUD
  /// updates while values are changing.
  void tick(double dt) {
    var changed = false;
    if (_toastTimer > 0) {
      _toastTimer -= dt;
      if (_toastTimer <= 0) {
        toast = null;
        changed = true;
      }
    }
    if (breathVisible) {
      changed = true; // breath bar animates continuously
    }
    if (changed) {
      notifyListeners();
    }
  }
}
