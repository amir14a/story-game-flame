import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_echo/engine/neon_echo_game.dart';
import 'package:neon_echo/ui/overlays.dart';

KeyDownEvent _down(LogicalKeyboardKey key) => KeyDownEvent(
      physicalKey: PhysicalKeyboardKey.keyZ, // physical key is irrelevant to the cheat
      logicalKey: key,
      timeStamp: Duration.zero,
    );

void main() {
  testWidgets('the debug Konami cheat unlocks every episode', (tester) async {
    final game = NeonEchoGame();
    await tester.pumpWidget(
      MaterialApp(home: GameWidget<NeonEchoGame>(game: game, overlayBuilderMap: buildOverlays())),
    );
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(game.state.unlockedEpisode, 1);

    const sequence = [
      LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.arrowRight,
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.arrowRight,
      LogicalKeyboardKey.keyB,
      LogicalKeyboardKey.keyA,
    ];
    for (final key in sequence) {
      game.onKeyEvent(_down(key), const <LogicalKeyboardKey>{});
    }

    expect(game.state.unlockedEpisode, game.story.episodeCount);
  });

  testWidgets('a wrong sequence leaves episodes locked', (tester) async {
    final game = NeonEchoGame();
    await tester.pumpWidget(
      MaterialApp(home: GameWidget<NeonEchoGame>(game: game, overlayBuilderMap: buildOverlays())),
    );
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    for (final key in [LogicalKeyboardKey.keyA, LogicalKeyboardKey.keyB, LogicalKeyboardKey.keyA]) {
      game.onKeyEvent(_down(key), const <LogicalKeyboardKey>{});
    }
    expect(game.state.unlockedEpisode, 1);
  });
}
