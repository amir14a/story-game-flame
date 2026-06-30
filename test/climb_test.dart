import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_echo/actors/player_actor.dart';
import 'package:neon_echo/engine/neon_echo_game.dart';
import 'package:neon_echo/engine/scenes/level_scene.dart';
import 'package:neon_echo/story/models/dialogue.dart';
import 'package:neon_echo/story/models/level_config.dart';
import 'package:neon_echo/ui/overlays.dart';

/// A tiny level: a floor, a solid platform overhead, and a ladder that passes
/// up through that platform — the exact shape that used to trap the player.
final _climbLevel = LevelConfig(
  id: 'test_climb',
  character: Character.james,
  theme: DistrictTheme.spire,
  mechanics: {MechanicType.climb},
  objective: 'climb test',
  worldWidth: 20,
  worldHeight: 30,
  start: Pt(5, 20),
  goal: Pt(5, 2),
  platforms: [
    Platform(x: 0, y: 22, width: 20, height: 6), // floor, top at y=22
    Platform(x: 0, y: 10, width: 20, height: 2), // overhead ledge, top at y=10
  ],
  ladders: [
    Ladder(x: 4, y: 8, width: 2.6, height: 16), // tops out above the ledge
  ],
);

void main() {
  testWidgets('the player climbs a ladder up past the platform above it', (tester) async {
    final game = NeonEchoGame();
    await tester.pumpWidget(
      MaterialApp(home: GameWidget<NeonEchoGame>(game: game, overlayBuilderMap: buildOverlays())),
    );
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    game.world = LevelScene(_climbLevel, episodeLabel: 'TEST');
    game.enterLevelMode();
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    final player = game.world.firstChild<PlayerActor>();
    expect(player, isNotNull);
    final startY = player!.body.position.y;

    // Hold "up" and let physics run; the player should rise well past the
    // overhead platform (top y=10) instead of being blocked beneath it.
    for (var i = 0; i < 220; i++) {
      game.input.setKeyboard(x: 0, up: true, down: false, fire: false, jump: false);
      await tester.pump(const Duration(milliseconds: 16));
    }
    final endY = player.body.position.y;

    // Smaller y is higher. Must have climbed up through/above the ledge.
    expect(endY, lessThan(startY - 9), reason: 'startY=$startY endY=$endY');
    expect(endY, lessThan(11), reason: 'player did not get above the overhead platform');
  });
}
