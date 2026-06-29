import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_echo/engine/neon_echo_game.dart';
import 'package:neon_echo/engine/scenes/level_scene.dart';
import 'package:neon_echo/ui/overlays.dart';

void main() {
  testWidgets('boots, loads the first level and steps physics without crashing',
      (tester) async {
    final game = NeonEchoGame();
    await tester.pumpWidget(
      MaterialApp(
        home: GameWidget<NeonEchoGame>(game: game, overlayBuilderMap: buildOverlays()),
      ),
    );

    // Let the game attach and run onLoad (avoid pumpAndSettle: the backdrop
    // animation repeats forever and would never settle).
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(game.isMounted, isTrue);

    // Walk from the intro cutscene into the first playable level.
    game.director.startEpisode(1);
    await tester.pump(const Duration(milliseconds: 16));
    game.director.advance();

    // Step the physics world for ~1s of frames.
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(game.world, isA<LevelScene>());
    expect(game.state.health, greaterThan(0));
  });
}
