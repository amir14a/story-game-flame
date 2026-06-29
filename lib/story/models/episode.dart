import 'dialogue.dart';
import 'level_config.dart';

/// One step inside an episode: either a scripted [CutscenePhase] or a playable
/// [LevelPhase]. The [StoryDirector] walks an episode's phases in order.
sealed class StoryPhase {
  const StoryPhase();
}

/// A non-interactive story beat (intro / flashback intro / cliffhanger / win).
class CutscenePhase extends StoryPhase {
  const CutscenePhase(this.cutscene);
  final Cutscene cutscene;
}

/// A playable level built from a [LevelConfig].
class LevelPhase extends StoryPhase {
  const LevelPhase(this.config);
  final LevelConfig config;
}

/// One of the five episodes: an ordered list of phases plus presentation data.
class Episode {
  const Episode({
    required this.number,
    required this.title,
    required this.tagline,
    required this.theme,
    required this.phases,
  });

  final int number;
  final String title;

  /// Short descriptor shown on the episode-select card (district · mechanics).
  final String tagline;

  final DistrictTheme theme;
  final List<StoryPhase> phases;
}
