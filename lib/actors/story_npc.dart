import 'dart:ui' hide TextStyle;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show TextStyle;

import '../art/character_art.dart';
import '../art/lighting.dart';
import '../core/palette.dart';
import '../engine/neon_echo_game.dart';
import '../story/models/level_config.dart';
import 'player_actor.dart';

/// A story character standing in the level (Books, Cray, Saint, Millie). When
/// the on-foot player gets close it fires its meeting dialogue once, face to
/// face. Pure presentation + a proximity check — no physics body.
class StoryNpc extends PositionComponent with HasGameReference<NeonEchoGame>, LightEmitter {
  StoryNpc(this.spawn);

  final NpcSpawn spawn;
  double _t = 0;
  bool _met = false;
  int _facing = -1;

  @override
  Future<void> onLoad() async {
    _facing = spawn.facing;
    // Place the figure so its feet rest on the spawn point.
    position = Vector2(spawn.x, spawn.y - CharacterArtist.height / 2);
    anchor = Anchor.topLeft;
    size = Vector2.zero();
    priority = 5;
  }

  String get _name => switch (spawn.kind) {
        NpcKind.books => 'BOOKS',
        NpcKind.cray => 'CRAY',
        NpcKind.saint => 'SAINT',
        NpcKind.millie => 'MILLIE',
      };

  @override
  Color get lightColor => switch (spawn.kind) {
        NpcKind.books => NeonPalette.books,
        NpcKind.cray => NeonPalette.cray,
        NpcKind.saint => NeonPalette.saint,
        NpcKind.millie => NeonPalette.milliePrimary,
      };

  @override
  Vector2 get lightWorldPosition => Vector2(spawn.x, spawn.y - CharacterArtist.height / 2);
  @override
  double get lightRadius => 4.5;

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
    final player = game.world.firstChild<PlayerActor>();
    if (player == null || !player.isMounted) {
      return;
    }
    final p = player.body.position;
    _facing = p.x >= spawn.x ? 1 : -1;
    if (!_met && (p.x - spawn.x).abs() < 1.8 && (p.y - spawn.y).abs() < 3.0) {
      _met = true;
      if (spawn.lines.isNotEmpty) {
        game.narrative.play(spawn.lines, blocking: true);
      }
    }
  }

  late final _label = TextPaint(
    style: TextStyle(color: lightColor, fontSize: 0.4, fontWeight: FontWeight.w800, letterSpacing: 0.06),
  );

  @override
  void render(Canvas canvas) {
    CharacterArtist.drawNpc(canvas, kind: spawn.kind, t: _t, facing: _facing, pose: CharacterPose.idle);
    _label.render(canvas, _name, Vector2(0, -1.5), anchor: Anchor.center);
  }
}
