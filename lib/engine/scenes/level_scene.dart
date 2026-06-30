import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import '../../actors/enemy.dart';
import '../../actors/pickup.dart';
import '../../actors/player_actor.dart';
import '../../actors/story_npc.dart';
import '../../actors/vehicles.dart';
import '../../art/lighting.dart';
import '../../core/game_config.dart';
import '../../core/palette.dart';
import '../../story/models/level_config.dart';
import '../neon_echo_game.dart';
import 'terrain.dart';

/// A playable level. Each [LevelConfig] becomes one [Forge2DWorld]: the engine
/// reads the declarative config and instantiates terrain bodies, the actor,
/// enemies, pickups and the goal, then wires the camera to follow and bound the
/// world.
class LevelScene extends Forge2DWorld with HasGameReference<NeonEchoGame> {
  LevelScene(this.config, {required this.episodeLabel});

  final LevelConfig config;
  final String episodeLabel;

  late final BodyComponent<NeonEchoGame> player;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    game.backdropTheme = config.theme;
    final edge = _edgeColor(config.theme);

    for (final g in config.grounds) {
      add(GroundBody(
        points: g.points.map((p) => Vector2(p.x, p.y)).toList(growable: false),
        color: edge,
        friction: g.friction,
      ));
    }
    for (final p in config.platforms) {
      add(PlatformBody(
        rect: Rect.fromLTWH(p.x, p.y, p.width, p.height),
        color: edge,
        friction: p.friction,
      ));
    }
    for (final w in config.walls) {
      add(PlatformBody(rect: Rect.fromLTWH(w.x, w.y, w.width, w.height), color: edge));
    }
    for (final l in config.ladders) {
      add(LadderBody(rect: Rect.fromLTWH(l.x, l.y, l.width, l.height)));
    }
    for (final w in config.waters) {
      add(WaterBody(rect: Rect.fromLTWH(w.x, w.y, w.width, w.height)));
    }
    for (final h in config.hazards) {
      final isFallPlane = h.width > config.worldWidth * 0.5;
      add(HazardBody(rect: Rect.fromLTWH(h.x, h.y, h.width, h.height), visible: !isFallPlane));
    }

    add(GoalBody(center: Vector2(config.goal.x, config.goal.y)));

    for (final e in config.enemies) {
      final spawn = e.kind == EnemyKind.drone ? Vector2(e.x, e.y) : Vector2(e.x, e.y - 1.0);
      add(Enemy(kind: e.kind, spawn: spawn, patrolHalf: e.patrol));
    }
    for (final pk in config.pickups) {
      add(Pickup(kind: pk.kind, spawn: Vector2(pk.x, pk.y), note: pk.note));
    }
    for (final npc in config.npcs) {
      add(StoryNpc(npc));
    }

    player = _spawnPlayer();
    if (player is PlayerActor) {
      (player as PlayerActor)
        ..checkpoints = config.checkpoints.map((p) => Vector2(p.x, p.y)).toList(growable: false)
        ..deathPlaneY = config.deathPlaneY;
    }
    await add(player); // ensure the body exists before the camera follows it

    // The lighting pass renders last (on top of everything in the world).
    add(LightingLayer());

    game.state.beginLevel(
      character: config.character,
      episodeTitle: episodeLabel,
      objective: config.objective,
      flashback: config.flashback,
      showBreath: config.has(MechanicType.swim),
    );

    _setupCamera();
  }

  BodyComponent<NeonEchoGame> _spawnPlayer() {
    final spawn = Vector2(config.start.x, config.start.y);
    switch (config.vehicle) {
      case VehicleKind.onFoot:
        return PlayerActor(character: config.character, mechanics: config.mechanics, spawn: spawn);
      case VehicleKind.car:
        return CarActor(character: config.character, mechanics: config.mechanics, spawn: spawn);
      case VehicleKind.bike:
        return BikeActor(character: config.character, mechanics: config.mechanics, spawn: spawn);
    }
  }

  final Set<int> _firedTriggers = {};

  @override
  void update(double dt) {
    super.update(dt);
    if (!player.isMounted || config.dialogueTriggers.isEmpty) {
      return;
    }
    final x = player.body.position.x;
    for (var i = 0; i < config.dialogueTriggers.length; i++) {
      if (_firedTriggers.contains(i)) {
        continue;
      }
      final t = config.dialogueTriggers[i];
      if (x >= t.x && x <= t.x + t.width) {
        _firedTriggers.add(i);
        game.narrative.play(t.lines, blocking: t.blocking);
      }
    }
  }

  void _setupCamera() {
    final camera = game.camera;
    camera.viewfinder.position = Vector2(config.start.x, config.start.y + GameConfig.cameraLeadY);
    camera.follow(player, maxSpeed: GameConfig.cameraMaxSpeed);
    camera.setBounds(
      Rectangle.fromLTRB(0, 0, config.worldWidth, config.worldHeight),
      considerViewport: true,
    );
  }

  static Color _edgeColor(DistrictTheme theme) => switch (theme) {
        DistrictTheme.rooftops => NeonPalette.cyan,
        DistrictTheme.lowtownNight => NeonPalette.magenta,
        DistrictTheme.skyway => NeonPalette.violet,
        DistrictTheme.sunken => NeonPalette.waterGlow,
        DistrictTheme.reservoir => NeonPalette.signalGreen,
        DistrictTheme.steelVeins => NeonPalette.amber,
        DistrictTheme.spire => NeonPalette.hotPink,
      };
}
