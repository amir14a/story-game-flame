import 'dart:math' as math;
import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';

import '../art/lighting.dart';
import '../art/neon.dart';
import '../core/palette.dart';
import '../engine/neon_echo_game.dart';
import '../story/models/level_config.dart';
import 'player_actor.dart';

/// A collectible sensor: air pockets refill breath, coins and clue markers push
/// a short story note to the HUD. Removes itself once collected.
class Pickup extends BodyComponent<NeonEchoGame> with ContactCallbacks, LightEmitter {
  Pickup({required this.kind, required Vector2 spawn, this.note}) : _spawn = spawn.clone() {
    renderBody = false;
  }

  final PickupKind kind;
  final Vector2 _spawn;
  final String? note;
  double _t = 0;
  bool _taken = false;

  Color get _color => switch (kind) {
        PickupKind.air => NeonPalette.waterGlow,
        PickupKind.coin => NeonPalette.amber,
        PickupKind.marker => NeonPalette.signalGreen,
      };

  @override
  Vector2 get lightWorldPosition => body.position;
  @override
  double get lightRadius => 3.2;
  @override
  Color get lightColor => _color;

  @override
  Body createBody() {
    final shape = CircleShape()..radius = 0.42;
    final def = BodyDef(type: BodyType.static, position: _spawn, userData: this);
    final body = world.createBody(def);
    body.createFixture(FixtureDef(shape, isSensor: true));
    return body;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (_taken || other is! PlayerActor) {
      return;
    }
    _taken = true;
    switch (kind) {
      case PickupKind.air:
        other.refillBreath();
      case PickupKind.coin:
      case PickupKind.marker:
        break;
    }
    final message = note;
    if (message != null) {
      game.state.showToast(message);
    }
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final bob = 0.12 * math.sin(_t * 3);
    canvas.save();
    canvas.translate(0, bob);
    Neon.halo(canvas, Offset.zero, 0.7, _color, alpha: 0.4);
    switch (kind) {
      case PickupKind.air:
        Neon.glowCircle(canvas, Offset.zero, 0.26, _color, 0.06, filled: true, fillAlpha: 0.25);
        Neon.glowCircle(canvas, const Offset(-0.08, -0.08), 0.07, NeonPalette.textBright, 0.04);
      case PickupKind.coin:
        Neon.glowCircle(canvas, Offset.zero, 0.3, _color, 0.07, filled: true, fillAlpha: 0.3);
        Neon.glowLine(canvas, const Offset(0, -0.16), const Offset(0, 0.16), _color, 0.06);
      case PickupKind.marker:
        final d = Path()
          ..moveTo(0, -0.32)
          ..lineTo(0.26, 0)
          ..lineTo(0, 0.32)
          ..lineTo(-0.26, 0)
          ..close();
        final spin = _t * 1.5;
        canvas.save();
        canvas.scale(math.cos(spin).abs() * 0.6 + 0.4, 1);
        Neon.glowPath(canvas, d, _color, 0.07, filled: true, fillAlpha: 0.3);
        canvas.restore();
    }
    canvas.restore();
  }
}
