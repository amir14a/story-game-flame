import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_echo/actors/player_actor.dart';
import 'package:neon_echo/actors/vehicles.dart';
import 'package:neon_echo/engine/neon_echo_game.dart';
import 'package:neon_echo/engine/scenes/level_scene.dart';
import 'package:neon_echo/engine/scenes/terrain.dart';
import 'package:neon_echo/story/models/episode.dart';
import 'package:neon_echo/story/models/level_config.dart';
import 'package:neon_echo/ui/overlays.dart';

void main() {
  // Guards against the "nothing but the background renders" class of bug: a
  // level whose scene onLoad throws (e.g. a degenerate ground chain) leaves an
  // empty world. Every playable level must build terrain, a goal and an actor.
  testWidgets('every level in the game actually builds (no empty worlds)', (tester) async {
    final game = NeonEchoGame();
    await tester.pumpWidget(
      MaterialApp(home: GameWidget<NeonEchoGame>(game: game, overlayBuilderMap: buildOverlays())),
    );
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    final configs = <LevelConfig>[];
    for (final ep in game.story.episodes) {
      for (final phase in ep.phases) {
        if (phase is LevelPhase) configs.add(phase.config);
      }
    }
    expect(configs, isNotEmpty);

    for (final cfg in configs) {
      game.world = LevelScene(cfg, episodeLabel: 'TEST');
      game.enterLevelMode();
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      final world = game.world;
      expect(world.children.length, greaterThan(2), reason: '${cfg.id} built an (almost) empty world');
      expect(world.firstChild<GoalBody>(), isNotNull, reason: '${cfg.id} has no goal');
      final hasActor = world.firstChild<PlayerActor>() != null || world.firstChild<VehicleActor>() != null;
      expect(hasActor, isTrue, reason: '${cfg.id} spawned no player/vehicle');
    }
  });
}
