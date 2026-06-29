import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';

import '../art/character_art.dart';
import '../core/game_config.dart';
import '../engine/neon_echo_game.dart';
import '../story/models/dialogue.dart';
import '../story/models/level_config.dart';
import 'markers.dart';
import 'projectile.dart';

/// The on-foot player body — Kade in the present, Aria in the flashbacks.
///
/// It is a single capsule-like body with three sensor fixtures (foot / left /
/// right) used for ground- and wall-detection. The locomotion is organised into
/// clearly separated behaviours — ground running + jumping, parkour wall-jumps,
/// swimming, ladder climbing and shooting — and which behaviours are live is
/// decided by the level's [mechanics] set.
class PlayerActor extends BodyComponent<NeonEchoGame> with ContactCallbacks {
  PlayerActor({
    required this.character,
    required this.mechanics,
    required Vector2 spawn,
  }) : _spawn = spawn.clone() {
    renderBody = false;
  }

  final Character character;
  final Set<MechanicType> mechanics;
  final Vector2 _spawn;

  // Fixture references for contact identification.
  late final Fixture _torso;
  late final Fixture _foot;
  late final Fixture _left;
  late final Fixture _right;

  // Contact counters (a body can touch several fixtures at once).
  int _groundContacts = 0;
  int _leftContacts = 0;
  int _rightContacts = 0;
  int _waterContacts = 0;
  int _ladderContacts = 0;
  double _waterSurfaceY = 0;

  // Timers / state.
  double _t = 0;
  double _coyote = 0;
  double _invuln = 0;
  double _fireCd = 0;
  double _drownTimer = 0;
  int _jumpsUsed = 0;
  int _facing = 1;
  bool _reached = false;
  bool _climbing = false;
  bool _passThrough = false;
  CharacterPose _pose = CharacterPose.idle;

  bool get _parkour => mechanics.contains(MechanicType.parkour);
  bool get _canSwim => mechanics.contains(MechanicType.swim);
  bool get _canClimb => mechanics.contains(MechanicType.climb);
  bool get _canShoot => mechanics.contains(MechanicType.shoot);

  int get facing => _facing;

  @override
  Body createBody() {
    final torso = PolygonShape()..setAsBoxXY(0.28, 0.74);
    final def = BodyDef(
      type: BodyType.dynamic,
      position: _spawn,
      fixedRotation: true,
      userData: this,
    );
    final body = world.createBody(def);
    _torso = body.createFixture(FixtureDef(torso, friction: 0.0, density: 1.1, restitution: 0.0));

    final footShape = PolygonShape()..setAsBox(0.22, 0.12, Vector2(0, 0.82), 0);
    _foot = body.createFixture(FixtureDef(footShape, isSensor: true));

    final leftShape = PolygonShape()..setAsBox(0.1, 0.58, Vector2(-0.34, 0), 0);
    _left = body.createFixture(FixtureDef(leftShape, isSensor: true));

    final rightShape = PolygonShape()..setAsBox(0.1, 0.58, Vector2(0.34, 0), 0);
    _right = body.createFixture(FixtureDef(rightShape, isSensor: true));

    return body;
  }

  // ------------------------------------------------------------- update loop
  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
    if (_coyote > 0) _coyote -= dt;
    if (_invuln > 0) _invuln -= dt;
    if (_fireCd > 0) _fireCd -= dt;

    final input = game.input;
    final jumpPressed = input.consumeJump();
    final grounded = _groundContacts > 0;
    final inWater = _waterContacts > 0;
    final onLadder = _ladderContacts > 0;

    if (grounded) {
      _jumpsUsed = 0;
      _coyote = GameConfig.coyoteTime;
    }

    final firing = _canShoot && input.fireHeld;

    // Climbing is a held state: it starts when up/down is pressed on a ladder
    // and ends when the body leaves the ladder (or jumps off). While climbing,
    // the body passes through terrain so the player can rise onto the ledge the
    // ladder leads to instead of being blocked by it from below.
    if (_climbing && !onLadder) {
      _climbing = false;
    } else if (!_climbing && _canClimb && onLadder && (input.up || input.down)) {
      _climbing = true;
    }

    if (_climbing && jumpPressed) {
      _climbing = false;
      _setPassThrough(false);
      body.linearVelocity = Vector2(_facing * GameConfig.wallJumpX * 0.5, -GameConfig.jumpImpulse);
      _pose = CharacterPose.jump;
    } else if (_climbing) {
      _setPassThrough(true);
      _climbMove();
      _pose = CharacterPose.climb;
    } else {
      _setPassThrough(false);
      if (inWater && _canSwim) {
        _swim(dt);
        _pose = CharacterPose.swim;
      } else {
        _ground(dt, grounded: grounded, jumpPressed: jumpPressed);
        final v = body.linearVelocity;
        if (!grounded) {
          _pose = v.y < 0 ? CharacterPose.jump : CharacterPose.fall;
        } else if (firing) {
          _pose = CharacterPose.aim;
        } else {
          _pose = input.moveX.abs() > 0.1 ? CharacterPose.run : CharacterPose.idle;
        }
      }
    }

    if (firing) {
      _shoot();
    }
    _breath(dt, inWater);
  }

  /// Toggles whether the body collides with terrain. Used so the player can
  /// climb up *through* the platform a ladder leads to, then land on top of it.
  void _setPassThrough(bool on) {
    if (_passThrough == on) {
      return;
    }
    _passThrough = on;
    _torso.filterData = Filter()
      ..categoryBits = 0x0001
      ..maskBits = on ? 0x0000 : 0xFFFF
      ..groupIndex = 0;
  }

  void _ground(double dt, {required bool grounded, required bool jumpPressed}) {
    final input = game.input;
    final v = body.linearVelocity;
    final moveX = input.moveX;
    if (moveX.abs() > 0.05) {
      _facing = moveX > 0 ? 1 : -1;
    }
    final control = grounded ? 1.0 : GameConfig.airControl;
    var nvx = _approach(v.x, moveX * GameConfig.runSpeed, GameConfig.runAccel * control * dt);
    var nvy = v.y;

    final wallDir = _rightContacts > 0 ? 1 : (_leftContacts > 0 ? -1 : 0);
    final clinging = _parkour && !grounded && wallDir != 0 && nvy > 0 && moveX * wallDir > 0.05;
    if (clinging && nvy > GameConfig.wallSlideSpeed) {
      nvy = GameConfig.wallSlideSpeed;
    }

    if (jumpPressed) {
      if (grounded || _coyote > 0) {
        nvy = -GameConfig.jumpImpulse;
        _jumpsUsed = 1;
        _coyote = 0;
      } else if (_parkour && wallDir != 0) {
        nvx = -wallDir * GameConfig.wallJumpX;
        nvy = -GameConfig.wallJumpY;
        _jumpsUsed = 1;
        _facing = -wallDir;
      } else if (_jumpsUsed < 2) {
        nvy = -GameConfig.doubleJumpImpulse;
        _jumpsUsed++;
      }
    }
    body.linearVelocity = Vector2(nvx, nvy);
  }

  void _swim(double dt) {
    final input = game.input;
    final v = body.linearVelocity;
    final moveX = input.moveX;
    if (moveX.abs() > 0.05) {
      _facing = moveX > 0 ? 1 : -1;
    }
    final tvx = moveX * GameConfig.swimSpeed;
    final tvy = input.up
        ? -GameConfig.swimSpeed
        : input.down
            ? GameConfig.swimSpeed
            : -1.2; // gentle buoyant drift upward
    final a = GameConfig.swimAccel * dt;
    body.linearVelocity = Vector2(_approach(v.x, tvx, a), _approach(v.y, tvy, a));
  }

  void _climbMove() {
    final input = game.input;
    final moveX = input.moveX;
    if (moveX.abs() > 0.05) {
      _facing = moveX > 0 ? 1 : -1;
    }
    final vy = input.up
        ? -GameConfig.climbSpeed
        : input.down
            ? GameConfig.climbSpeed
            : 0.0;
    // Setting velocity directly each frame cancels gravity, so the player hangs
    // on the ladder when not pressing up/down.
    body.linearVelocity = Vector2(moveX * GameConfig.climbSpeed * 0.5, vy);
  }

  void _shoot() {
    if (_fireCd > 0) {
      return;
    }
    _fireCd = GameConfig.fireCooldown;
    final dir = Vector2(_facing.toDouble(), 0);
    final spawn = body.position + Vector2(_facing * 0.7, -0.18);
    world.add(Bullet(spawn: spawn, direction: dir));
  }

  void _breath(double dt, bool inWater) {
    if (!_canSwim) {
      return;
    }
    final headY = body.position.y - 0.6;
    final submerged = inWater && headY > _waterSurfaceY + 0.1;
    final state = game.state;
    if (submerged) {
      state.setBreath(state.breath - dt);
      if (state.breath <= 0) {
        _drownTimer += dt;
        if (_drownTimer >= 1.0) {
          _drownTimer = 0;
          hit();
        }
      }
    } else {
      _drownTimer = 0;
      state.setBreath(state.breath + GameConfig.breathRefill * dt);
    }
  }

  // ----------------------------------------------------------- damage / state
  void hit([int amount = GameConfig.contactDamage]) {
    if (_invuln > 0 || game.state.isDead) {
      return;
    }
    _invuln = GameConfig.hitInvulnerability;
    game.state.damage(amount);
    body.linearVelocity = Vector2(-_facing * 5.0, -5.0);
    if (game.state.isDead) {
      game.director.onPlayerDied();
    }
  }

  void refillBreath() => game.state.setBreath(game.state.maxBreath);

  void _killInstant() {
    if (game.state.isDead || _reached) {
      return;
    }
    game.state.damage(game.state.maxHealth);
    game.director.onPlayerDied();
  }

  void _reachGoal() {
    if (_reached) {
      return;
    }
    _reached = true;
    game.director.onLevelCleared();
  }

  // --------------------------------------------------------------- contacts
  Fixture _mine(Contact contact) =>
      contact.fixtureA.body == body ? contact.fixtureA : contact.fixtureB;

  @override
  void beginContact(Object other, Contact contact) {
    final mine = _mine(contact);
    if (other is SolidTerrain) {
      if (mine == _foot) {
        _groundContacts++;
      } else if (mine == _left) {
        _leftContacts++;
      } else if (mine == _right) {
        _rightContacts++;
      }
    } else if (other is WaterMarker) {
      _waterContacts++;
      _waterSurfaceY = other.surfaceY;
    } else if (other is LadderMarker) {
      _ladderContacts++;
    } else if (other is HazardMarker) {
      _killInstant();
    } else if (other is GoalMarker) {
      _reachGoal();
    }
  }

  @override
  void endContact(Object other, Contact contact) {
    final mine = _mine(contact);
    if (other is SolidTerrain) {
      if (mine == _foot) {
        _groundContacts = (_groundContacts - 1).clamp(0, 99);
      } else if (mine == _left) {
        _leftContacts = (_leftContacts - 1).clamp(0, 99);
      } else if (mine == _right) {
        _rightContacts = (_rightContacts - 1).clamp(0, 99);
      }
    } else if (other is WaterMarker) {
      _waterContacts = (_waterContacts - 1).clamp(0, 99);
    } else if (other is LadderMarker) {
      _ladderContacts = (_ladderContacts - 1).clamp(0, 99);
    }
  }

  static double _approach(double current, double target, double maxDelta) {
    if ((target - current).abs() <= maxDelta) {
      return target;
    }
    return current + maxDelta * (target > current ? 1 : -1);
  }

  // ----------------------------------------------------------------- render
  @override
  void render(Canvas canvas) {
    if (_invuln > 0 && (_invuln * 18).floor().isEven) {
      return; // flash while invulnerable
    }
    CharacterArtist.draw(
      canvas,
      character: character,
      t: _t,
      facing: _facing,
      pose: _pose,
      opacity: _invuln > 0 ? 0.7 : 1.0,
    );
  }
}
