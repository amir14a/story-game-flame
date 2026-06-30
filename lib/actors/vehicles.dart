import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';

import '../art/lighting.dart';
import '../art/vehicle_art.dart';
import '../core/game_config.dart';
import '../core/palette.dart';
import '../engine/neon_echo_game.dart';
import '../story/models/dialogue.dart';
import '../story/models/level_config.dart';
import 'enemy.dart';
import 'markers.dart';
import 'projectile.dart';

/// Shared base for the player-driven vehicles.
///
/// The chassis is a **freely rotating** dynamic body resting on **two sprung
/// wheels** (Forge2D [WheelJoint]s). That means it naturally **leans into climbs
/// and downhills** (bug 1) and there is **no jump** (bug 2) — the player only
/// throttles forward/back with a horizontal drive force.
abstract class VehicleActor extends BodyComponent<NeonEchoGame> with ContactCallbacks, LightEmitter {
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

  // --- per-vehicle tuning ---
  double get maxSpeed;
  double get driveForce;
  double get halfLength;
  double get halfHeight => 0.42;
  double get wheelRadius => 0.42;
  double get wheelBase => halfLength * 0.72;
  double get brakeDrag => 6.0;

  final List<Body> _wheels = [];
  double _wheelSpin = 0;
  double _invuln = 0;
  double _fireCd = 0;
  bool _reached = false;

  bool get _canShoot => mechanics.contains(MechanicType.shoot);

  @override
  Vector2 get lightWorldPosition => body.position;
  @override
  double get lightRadius => 9.0;
  @override
  Color get lightColor => NeonPalette.jamesPrimary;

  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBoxXY(halfLength, halfHeight);
    final def = BodyDef(
      type: BodyType.dynamic,
      position: _spawn,
      angularDamping: 0.6,
      userData: this,
    );
    final b = world.createBody(def);
    b.createFixture(FixtureDef(shape, density: 1.0, friction: 0.25, restitution: 0.0));
    return b;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _buildWheels();
  }

  void _buildWheels() {
    final axis = Vector2(0, 1); // vertical suspension travel
    for (final dx in [-wheelBase, wheelBase]) {
      final wheelDef = BodyDef(
        type: BodyType.dynamic,
        position: body.position + Vector2(dx, halfHeight + wheelRadius * 0.3),
        userData: this,
      );
      final wheel = world.createBody(wheelDef);
      wheel.createFixture(
        FixtureDef(CircleShape()..radius = wheelRadius, density: 1.0, friction: 1.4, restitution: 0.0),
      );
      final jd = WheelJointDef<Body, Body>()
        ..frequencyHz = 5.5
        ..dampingRatio = 0.7;
      jd.initialize(body, wheel, wheel.position, axis);
      world.createJoint(WheelJoint(jd));
      _wheels.add(wheel);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_invuln > 0) _invuln -= dt;
    if (_fireCd > 0) _fireCd -= dt;

    final input = game.input;
    input.consumeJump(); // vehicles never jump — swallow the press

    final v = body.linearVelocity;
    var throttle = 0;
    if (input.moveX > 0.1 || input.up) {
      throttle = 1;
    } else if (input.moveX < -0.1 || input.down) {
      throttle = -1;
    }

    // Apply the drive force low on the chassis to limit nose-lift / tipping.
    final point = body.worldPoint(Vector2(0, halfHeight * 0.8));
    if (throttle > 0 && v.x < maxSpeed) {
      body.applyForce(Vector2(driveForce, 0), point: point);
    } else if (throttle < 0 && v.x > -maxSpeed * 0.5) {
      body.applyForce(Vector2(-driveForce, 0), point: point);
    } else {
      body.applyForce(Vector2(-v.x * brakeDrag * body.mass * 0.2, 0));
    }

    // Gentle self-right only if almost completely flipped (never fights normal
    // slope tilt, which stays well under ~0.6 rad on the passable terrain).
    if (body.angle.abs() > 1.5) {
      body.applyTorque(-body.angle.sign * 12.0 - body.angularVelocity * 3.0);
    }

    _wheelSpin += v.x * dt * 1.6;

    if (_canShoot && input.fireHeld) {
      _shoot();
    }
  }

  void _shoot() {
    if (_fireCd > 0) {
      return;
    }
    _fireCd = GameConfig.fireCooldown;
    final spawn = body.worldPoint(Vector2(halfLength + 0.2, -0.3));
    world.add(Bullet(spawn: spawn, direction: Vector2(1, 0)));
  }

  void hit([int amount = GameConfig.contactDamage]) {
    if (_invuln > 0 || game.state.isDead || _reached) {
      return;
    }
    _invuln = GameConfig.hitInvulnerability;
    game.state.damage(amount);
    if (game.state.isDead) {
      game.director.onPlayerDied();
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is HazardMarker) {
      hit();
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
  void onRemove() {
    if (!world.isRemoving) {
      for (final wheel in _wheels) {
        world.destroyBody(wheel);
      }
    }
    _wheels.clear();
    super.onRemove();
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

/// The Episode 2 courier hauler.
class CarActor extends VehicleActor {
  CarActor({required super.character, required super.mechanics, required super.spawn});

  @override
  double get maxSpeed => GameConfig.carMaxSpeed;
  @override
  double get driveForce => 150;
  @override
  double get halfLength => 1.7;
  @override
  double get wheelRadius => 0.46;

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
  double get driveForce => 95;
  @override
  double get halfLength => 1.0;
  @override
  double get wheelRadius => 0.42;
  @override
  double get wheelBase => 0.92;

  @override
  void drawVehicle(Canvas canvas) {
    VehicleArtist.drawBike(canvas, character: character, wheelSpin: _wheelSpin);
  }
}
