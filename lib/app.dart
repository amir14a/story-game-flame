import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'core/palette.dart';
import 'engine/neon_echo_game.dart';
import 'ui/overlays.dart';

/// Hosts the Flame [NeonEchoGame] inside a dark, chrome-free [MaterialApp] and
/// wires up the Flutter overlay screens (menu, cutscenes, HUD, endings).
class NeonEchoApp extends StatefulWidget {
  const NeonEchoApp({super.key});

  @override
  State<NeonEchoApp> createState() => _NeonEchoAppState();
}

class _NeonEchoAppState extends State<NeonEchoApp> {
  // Created once and kept stable across rebuilds.
  late final NeonEchoGame _game = NeonEchoGame();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neon Echo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: NeonPalette.voidBlack,
        fontFamily: 'monospace',
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: NeonPalette.voidBlack,
        body: GameWidget<NeonEchoGame>(
          game: _game,
          overlayBuilderMap: buildOverlays(),
        ),
      ),
    );
  }
}
