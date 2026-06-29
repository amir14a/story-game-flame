import 'episodes/episode_five.dart';
import 'episodes/episode_four.dart';
import 'episodes/episode_one.dart';
import 'episodes/episode_three.dart';
import 'episodes/episode_two.dart';
import 'models/episode.dart';

/// Provides the full, ordered list of episodes that make up NEON ECHO.
///
/// This is the single entry point the engine uses to read story content; the
/// engine never imports individual episode files.
class StoryRepository {
  StoryRepository() : episodes = List.unmodifiable(_build());

  final List<Episode> episodes;

  static List<Episode> _build() => [
        buildEpisodeOne(),
        buildEpisodeTwo(),
        buildEpisodeThree(),
        buildEpisodeFour(),
        buildEpisodeFive(),
      ];

  int get episodeCount => episodes.length;

  /// 1-based lookup to match the way episodes are numbered for the player.
  Episode byNumber(int number) => episodes[number - 1];
}
