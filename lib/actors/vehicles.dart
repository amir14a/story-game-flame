import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';

import '../art/vehicle_art.dart';
import '../core/game_config.dart';
import '../engine/neon_echo_game.dart';
import '../story/models/dialogue.dart';
import '../story/models/level_config.dart';
import 'enemy.dart';
import 'markers.dart';
import 'projectile.dart';

double _approach(double current, double target, double maxDelta) {
  if ((target - current).abs() <= maxDelta) {
    return target;
  }
  return current + maxDelta * (target > current ? 1 : -1);
}

/// Shared base for the player-driven vehicles. A single fixed-rotation body with
/// a rounded (circle) collider so it rolls smoothly over the ground chain. The
/// player throttles with right/left (or the joystick), hops with jump, and — on
/// the bike — fires forward.
abstract class VehicleActor extends BodyComponent<NeonEchoGame> with ContactCallbacks {
  VehicleActor({
    required this.character,
    required this.mechanics,
    required Vector2 spawn,
  }) : _spawn = spawn.clone() {
    renderBody = false;
  }

  final Character character;
  final Set<MechanicType> mechanics;
  final Vector2 _spawn;

  double get maxSpeed;
  double get accel;
  double get brake;
  double get hopSpeed;
  double get colliderRadius => 0.72;

  double _wheelSpin = 0;
  double _invuln = 0;
  double _fireCd = 0;
  bool _reached = false;

  bool get _canShoot => mechanics.contains(MechanicType.shoot);

  @override
  Body createBody() {
    final shape = CircleShape()
      ..radius = colliderRadius
      ..position.setValues(0, 0.28);
    final def = BodyDef(
      type: BodyType.dynamic,
      position: _spawn,
      fixedRotation: true,
      bullet: true,
      userData: this,
    );
    final body = world.createBody(def);
    body.createFixture(FixtureDef(shape, friction: 0.35, density: 1.0, restitution: 0.0));
    return body;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_invuln > 0) _invuln -= dt;
    if (_fireCd > 0) _fireCd -= dt;

    final input = game.input;
    final v = body.linearVelocity;
    final jumpPressed = input.consumeJump();

    var throttle = 0;
    if (input.moveX > 0.1 || input.up) {
      throttle = 1;
    } else if (input.moveX < -0.1 || input.down) {
      throttle = -1;
    }

    final target = throttle > 0
        ? maxSpeed
        : throttle < 0
            ? -maxSpeed * 0.4
            : 0.0;
    final rate = throttle != 0 ? accel : brake;
    var nvx = _approach(v.x, target, rate * dt);
    var nvy = v.y;
    if (jumpPressed && v.y > -2.0) {
      nvy = -hopSpeed; // arcade hop over gaps / barricades
    }
    body.linearVelocity = Vector2(nvx, nvy);
    _wheelSpin += nvx * dt * 1.6;

    if (_canShoot && input.fireHeld) {
      _shoot();
    }
  }

  void _shoot() {
    if (_fireCd > 0) {
      return;
    }
    _fireCd = GameConfig.fireCooldown;
    final spawn = body.position + Vector2(1.2, -0.3);
    world.add(Bullet(spawn: spawn, direction: Vector2(1, 0)));
  }

  void hit([int amount = GameConfig.contactDamage]) {
    if (_invuln > 0 || game.state.isDead || _reached) {
      return;
    }
    _invuln = GameConfig.hitInvulnerability;
    game.state.damage(amount);
    body.linearVelocity = Vector2(body.linearVelocity.x * 0.5, -6.0);
    if (game.state.isDead) {
      game.director.onPlayerDied();
    }
  }

  void _crash() {
    if (game.state.isDead || _reached) {
      return;
    }
    game.state.damage(game.state.maxHealth);
    game.director.onPlayerDied();
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is HazardMarker) {
      _crash();
    } else if (other is GoalMarker) {
      if (!_reached) {
        _reached = true;
        game.director.onLevelCleared();
      }
    } else if (other is Enemy) {
      hit();
    }
  }

  @override
  void render(Canvas canvas) {
    if (_invuln > 0 && (_invuln * 18).floor().isEven) {
      return;
    }
    drawVehicle(canvas);
  }

  void drawVehicle(Canvas canvas);
}

/// The Episode 2 courier car.
class CarActor extends VehicleActor {
  CarActor({required super.character, required super.mechanics, required super.spawn});

  @override
  double get maxSpeed => GameConfig.carMaxSpeed;
  @override
  double get accel => GameConfig.carAccel;
  @override
  double get brake => GameConfig.carBrake;
  @override
  double get hopSpeed => GameConfig.carTurnImpulse;

  @override
  void drawVehicle(Canvas canvas) {
    VehicleArtist.drawCar(canvas, character: character, wheelSpin: _wheelSpin);
  }
}

/// The Episode 4 motorcycle (also shoots).
class BikeActor extends VehicleActor {
  BikeActor({required super.character, required super.mechanics, required super.spawn});

  @override
  double get maxSpeed => GameConfig.bikeMaxSpeed;
  @override
  double get accel => GameConfig.bikeAccel;
  @override
  double get brake => GameConfig.carBrake;
  @override
  double get hopSpeed => GameConfig.bikeJumpImpulse;
  @override
  double get colliderRadius => 0.6;

  @override
  void drawVehicle(Canvas canvas) {
    VehicleArtist.drawBike(canvas, character: character, wheelSpin: _wheelSpin);
  }
}
