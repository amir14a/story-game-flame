import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_echo/actors/vehicles.dart';
import 'package:neon_echo/engine/neon_echo_game.dart';
import 'package:neon_echo/engine/scenes/level_scene.dart';
import 'package:neon_echo/story/models/episode.dart';
import 'package:neon_echo/story/models/level_config.dart';
import 'package:neon_echo/ui/overlays.dart';

void main() {
  testWidgets('the wheel-joint vehicle loads and drives forward without crashing',
      (tester) async {
    final game = NeonEchoGame();
    await tester.pumpWidget(
      MaterialApp(home: GameWidget<NeonEchoGame>(game: game, overlayBuilderMap: buildOverlays())),
    );
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    // Find a driving level in the story and load it directly.
    LevelConfig? drive;
    for (final ep in game.story.episodes) {
      for (final phase in ep.phases) {
        if (phase is LevelPhase && phase.config.vehicle == VehicleKind.car) {
          drive = phase.config;
          break;
        }
      }
      if (drive != null) break;
    }
    expect(drive, isNotNull);

    game.world = LevelScene(drive!, episodeLabel: 'TEST');
    game.enterLevelMode();
    for (var i = 0; i < 16; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    final car = game.world.firstChild<VehicleActor>();
    expect(car, isNotNull, reason: 'no vehicle spawned');
    final startX = car!.body.position.x;

    // Throttle right for ~1s.
    for (var i = 0; i < 60; i++) {
      game.input.setKeyboard(x: 1, up: false, down: false, fire: false, jump: false);
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(car.body.position.x, greaterThan(startX + 6), reason: 'car did not drive forward');
    expect(car.body.angle.abs(), lessThan(1.0), reason: 'car flipped on flat-ish road');
  });
}
