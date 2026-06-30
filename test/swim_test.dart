import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_echo/actors/player_actor.dart';
import 'package:neon_echo/engine/neon_echo_game.dart';
import 'package:neon_echo/engine/scenes/level_scene.dart';
import 'package:neon_echo/story/models/dialogue.dart';
import 'package:neon_echo/story/models/level_config.dart';
import 'package:neon_echo/ui/overlays.dart';

final _swimLevel = LevelConfig(
  id: 'test_swim',
  character: Character.james,
  theme: DistrictTheme.sunken,
  mechanics: const {MechanicType.swim},
  objective: 'swim test',
  worldWidth: 30,
  worldHeight: 32,
  killY: 40,
  start: const Pt(8, 13),
  goal: const Pt(28, 5),
  waters: const [WaterZone(x: 0, y: 10, width: 30, height: 22)],
  platforms: const [Platform(x: 0, y: 30, width: 30, height: 2)],
);

void main() {
  testWidgets('swimming up settles at the surface instead of bobbing forever',
      (tester) async {
    final game = NeonEchoGame();
    await tester.pumpWidget(
      MaterialApp(home: GameWidget<NeonEchoGame>(game: game, overlayBuilderMap: buildOverlays())),
    );
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    game.world = LevelScene(_swimLevel, episodeLabel: 'TEST');
    game.enterLevelMode();
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    final player = game.world.firstChild<PlayerActor>()!;

    // Hold "up" to rise to the surface, then keep holding and sample the height.
    final samples = <double>[];
    for (var i = 0; i < 200; i++) {
      game.input.setKeyboard(x: 0, up: true, down: false, fire: false, jump: false);
      await tester.pump(const Duration(milliseconds: 16));
      if (i >= 140) samples.add(player.body.position.y);
    }

    final minY = samples.reduce((a, b) => a < b ? a : b);
    final maxY = samples.reduce((a, b) => a > b ? a : b);
    // Surface is y=10; the swimmer should sit just under it and stay there.
    expect(minY, greaterThan(9.0), reason: 'breached the surface (min y=$minY)');
    expect(maxY - minY, lessThan(0.8), reason: 'still bobbing: range ${maxY - minY}');
  });
}
