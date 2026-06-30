import 'package:flutter_test/flutter_test.dart';
import 'package:neon_echo/story/models/dialogue.dart';
import 'package:neon_echo/story/models/episode.dart';
import 'package:neon_echo/story/models/level_config.dart';
import 'package:neon_echo/story/story_repository.dart';

void main() {
  final story = StoryRepository();

  test('the story is exactly five episodes', () {
    expect(story.episodeCount, 5);
    for (var i = 0; i < story.episodes.length; i++) {
      expect(story.episodes[i].number, i + 1);
    }
  });

  test('every episode ends on a cutscene (a cliffhanger or the finale)', () {
    for (final ep in story.episodes) {
      expect(ep.phases.isNotEmpty, isTrue);
      expect(ep.phases.last, isA<CutscenePhase>());
    }
  });

  test('every playable level has a reachable, well-formed config', () {
    for (final ep in story.episodes) {
      for (final phase in ep.phases) {
        if (phase is LevelPhase) {
          final c = phase.config;
          expect(c.mechanics.isNotEmpty, isTrue, reason: '${c.id} has no mechanics');
          expect(c.goal.x, lessThanOrEqualTo(c.worldWidth + 1), reason: '${c.id} goal outside world');
          expect(c.worldWidth, greaterThan(0));
          expect(c.worldHeight, greaterThan(0));
        }
      }
    }
  });

  test('the sister (Aria) is only ever playable in flashbacks', () {
    for (final ep in story.episodes) {
      for (final phase in ep.phases) {
        if (phase is LevelPhase && phase.config.character == Character.millie) {
          expect(phase.config.flashback, isTrue,
              reason: '${phase.config.id} plays Millie outside a flashback');
        }
      }
    }
  });

  test('all seven required mechanics appear across the game', () {
    final seen = <MechanicType>{};
    for (final ep in story.episodes) {
      for (final phase in ep.phases) {
        if (phase is LevelPhase) {
          seen.addAll(phase.config.mechanics);
        }
      }
    }
    expect(seen, containsAll(MechanicType.values));
  });

  test('flashbacks that tell you to chase/meet James actually contain James', () {
    final levels = <String, LevelConfig>{};
    for (final ep in story.episodes) {
      for (final phase in ep.phases) {
        if (phase is LevelPhase) levels[phase.config.id] = phase.config;
      }
    }
    bool jamesPresent(String id) {
      final c = levels[id]!;
      return c.npcs.any((n) => n.kind == NpcKind.james) || c.companion == Character.james;
    }

    // On-foot flashbacks where Millie chases/sits with her brother.
    expect(jamesPresent('ep1_crane_flashback'), isTrue);
    expect(jamesPresent('ep5_counting_stars_flashback'), isTrue);
    // Driving flashback: James rides shotgun.
    expect(levels['ep2_first_light_flashback']!.companion, Character.james);
  });
}
