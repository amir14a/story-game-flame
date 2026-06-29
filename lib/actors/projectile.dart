import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';

import '../art/neon.dart';
import '../core/game_config.dart';
import '../core/palette.dart';
import '../engine/neon_echo_game.dart';
import 'enemy.dart';
import 'markers.dart';

/// A neon bolt fired by the player. A fast gravity-free sensor body that
/// damages the first enemy it touches and dies on terrain or after a timeout.
class Bullet extends BodyComponent<NeonEchoGame> with ContactCallbacks {
  Bullet({required Vector2 spawn, required this.direction, this.color = NeonPalette.amber})
      : _spawn = spawn.clone() {
    renderBody = false;
  }

  final Vector2 _spawn;
  final Vector2 direction; // unit vector
  final Color color;
  double _life = GameConfig.bulletLife;

  @override
  Body createBody() {
    final shape = CircleShape()..radius = 0.13;
    final def = BodyDef(
      type: BodyType.dynamic,
      position: _spawn,
      bullet: true,
      gravityScale: Vector2.zero(),
      fixedRotation: true,
      userData: this,
    );
    final body = world.createBody(def);
    body.createFixture(FixtureDef(shape, isSensor: true, density: 0.05));
    body.linearVelocity = direction * GameConfig.bulletSpeed;
    return body;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _life -= dt;
    if (_life <= 0) {
      removeFromParent();
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Enemy) {
      other.takeDamage(GameConfig.bulletDamage);
      removeFromParent();
    } else if (other is SolidTerrain) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final sign = direction.x >= 0 ? 1.0 : -1.0;
    Neon.glowLine(canvas, Offset(-0.22 * sign, 0), Offset(0.22 * sign, 0), color, 0.1, glowScale: 3);
    Neon.glowCircle(canvas, Offset(0.22 * sign, 0), 0.1, color, 0.06, filled: true, fillAlpha: 0.8);
  }
}
