import 'dart:math' as math;
import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';

import '../art/character_art.dart';
import '../art/lighting.dart';
import '../art/vehicle_art.dart';
import '../core/game_config.dart';
import '../core/palette.dart';
import '../engine/neon_echo_game.dart';
import '../story/models/dialogue.dart';
import '../story/models/level_config.dart';
import 'player_actor.dart';

/// A Hollow hostile. One class, three behaviours selected by [EnemyKind]:
/// a patrolling ground grunt, a hovering chase drone, and a pursuing rider.
class Enemy extends BodyComponent<NeonEchoGame> with ContactCallbacks, LightEmitter {
  Enemy({required this.kind, required Vector2 spawn, this.patrolHalf = 4})
      : _spawn = spawn.clone(),
        _homeX = spawn.x {
    renderBody = false;
  }

  final EnemyKind kind;
  final Vector2 _spawn;
  final double _homeX;
  final double patrolHalf;

  late int health = switch (kind) {
        EnemyKind.grunt => 2,
        EnemyKind.drone => 2,
        EnemyKind.rider => 3,
      };

  double _t = 0;
  int _facing = -1;

  bool get isDead => health <= 0;

  @override
  Vector2 get lightWorldPosition => body.position;
  @override
  double get lightRadius => kind == EnemyKind.grunt ? 2.6 : 3.6;
  @override
  Color get lightColor => NeonPalette.hollowRed;

  @override
  Body createBody() {
    late final Shape shape;
    late final BodyType type;
    var gravityScale = Vector2(1, 1);
    switch (kind) {
      case EnemyKind.grunt:
        shape = PolygonShape()..setAsBoxXY(0.28, 0.74);
        type = BodyType.dynamic;
      case EnemyKind.drone:
        shape = CircleShape()..radius = 0.5;
        type = BodyType.kinematic;
        gravityScale = Vector2.zero();
      case EnemyKind.rider:
        shape = PolygonShape()..setAsBoxXY(1.0, 0.7);
        type = BodyType.dynamic;
    }
    final def = BodyDef(
      type: type,
      position: _spawn,
      fixedRotation: true,
      gravityScale: gravityScale,
      userData: this,
    );
    final body = world.createBody(def);
    body.createFixture(FixtureDef(shape, friction: 0.5, density: 1.0));
    return body;
  }

  PlayerActor? get _player {
    final p = world.firstChild<PlayerActor>();
    // Only touch the player once it is mounted (so its physics body exists).
    return (p != null && p.isMounted) ? p : null;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
    final player = _player;
    switch (kind) {
      case EnemyKind.grunt:
        var vx = _facing * 3.0;
        if (body.position.x < _homeX - patrolHalf) {
          _facing = 1;
          vx = 3.0;
        } else if (body.position.x > _homeX + patrolHalf) {
          _facing = -1;
          vx = -3.0;
        }
        body.linearVelocity = Vector2(vx, body.linearVelocity.y);
      case EnemyKind.drone:
        var v = Vector2(math.sin(_t * 1.5) * 1.2, math.cos(_t * 2.2) * 1.0);
        if (player != null) {
          final toPlayer = player.body.position - body.position;
          if (toPlayer.length > 0.2) {
            v += toPlayer.normalized() * 3.2;
            _facing = toPlayer.x >= 0 ? 1 : -1;
          }
        }
        body.linearVelocity = v;
      case EnemyKind.rider:
        var vx = _facing * GameConfig.bikeMaxSpeed * 0.45;
        if (player != null) {
          final dx = player.body.position.x - body.position.x;
          _facing = dx >= 0 ? 1 : -1;
          vx = _facing * GameConfig.bikeMaxSpeed * 0.5;
        }
        body.linearVelocity = Vector2(vx, body.linearVelocity.y);
    }
  }

  void takeDamage(int amount) {
    health -= amount;
    if (health <= 0) {
      removeFromParent();
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is PlayerActor) {
      other.hit();
    }
  }

  @override
  void render(Canvas canvas) {
    switch (kind) {
      case EnemyKind.grunt:
        CharacterArtist.drawGrunt(canvas,
            t: _t, facing: _facing, pose: CharacterPose.run);
      case EnemyKind.drone:
        VehicleArtist.drawDrone(canvas, t: _t);
      case EnemyKind.rider:
        canvas.save();
        canvas.scale(_facing.toDouble(), 1);
        VehicleArtist.drawBike(canvas,
            character: Character.james, wheelSpin: _t * 12, hostile: true);
        canvas.restore();
    }
  }
}
