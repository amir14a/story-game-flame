import 'dart:math' as math;
import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';

import '../../actors/markers.dart';
import '../../art/neon.dart';
import '../../core/palette.dart';
import '../neon_echo_game.dart';

/// A solid rectangular slab — used for platforms, rooftops and walls. Static
/// body tagged [SolidTerrain]; rendered as a dark neon-edged block.
class PlatformBody extends BodyComponent<NeonEchoGame> {
  PlatformBody({
    required this.rect,
    required this.color,
    this.friction = 0.8,
  })  : _hw = rect.width / 2,
        _hh = rect.height / 2 {
    renderBody = false;
  }

  final Rect rect;
  final Color color;
  final double friction;
  final double _hw;
  final double _hh;

  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBoxXY(_hw, _hh);
    final def = BodyDef(
      type: BodyType.static,
      position: Vector2(rect.left + _hw, rect.top + _hh),
      userData: const SolidTerrain(),
    );
    final body = world.createBody(def);
    body.createFixture(FixtureDef(shape, friction: friction));
    return body;
  }

  @override
  void render(Canvas canvas) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTRB(-_hw, -_hh, _hw, _hh),
      const Radius.circular(0.12),
    );
    canvas.drawRRect(r, Paint()..color = NeonPalette.voidBlack.withValues(alpha: 0.82));
    canvas.drawRRect(r, Neon.stroke(color.withValues(alpha: 0.55), 0.05));
    // bright top edge
    Neon.glowLine(canvas, Offset(-_hw + 0.1, -_hh), Offset(_hw - 0.1, -_hh), color, 0.06);
  }
}

/// A continuous ground chain (roads / terrain) with a filled body below it.
class GroundBody extends BodyComponent<NeonEchoGame> {
  GroundBody({required this.points, required this.color, this.friction = 0.7}) {
    renderBody = false;
  }

  final List<Vector2> points;
  final Color color;
  final double friction;

  @override
  Body createBody() {
    final shape = ChainShape()..createChain(points);
    final def = BodyDef(
      type: BodyType.static,
      position: Vector2.zero(),
      userData: const SolidTerrain(),
    );
    final body = world.createBody(def);
    body.createFixture(FixtureDef(shape, friction: friction));
    return body;
  }

  @override
  void render(Canvas canvas) {
    if (points.isEmpty) {
      return;
    }
    final fill = Path()..moveTo(points.first.x, points.first.y);
    for (final p in points) {
      fill.lineTo(p.x, p.y);
    }
    fill
      ..lineTo(points.last.x, points.last.y + 40)
      ..lineTo(points.first.x, points.first.y + 40)
      ..close();
    canvas.drawPath(fill, Paint()..color = NeonPalette.voidBlack.withValues(alpha: 0.85));

    final line = Path()..moveTo(points.first.x, points.first.y);
    for (final p in points) {
      line.lineTo(p.x, p.y);
    }
    Neon.glowPath(canvas, line, color, 0.07);
  }
}

/// A climbable rigging / ladder. Sensor body tagged [LadderMarker].
class LadderBody extends BodyComponent<NeonEchoGame> {
  LadderBody({required this.rect})
      : _hw = rect.width / 2,
        _hh = rect.height / 2 {
    renderBody = false;
  }

  final Rect rect;
  final double _hw;
  final double _hh;

  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBoxXY(_hw, _hh);
    final def = BodyDef(
      type: BodyType.static,
      position: Vector2(rect.left + _hw, rect.top + _hh),
      userData: const LadderMarker(),
    );
    final body = world.createBody(def);
    body.createFixture(FixtureDef(shape, isSensor: true));
    return body;
  }

  @override
  void render(Canvas canvas) {
    const color = NeonPalette.cyan;
    Neon.glowLine(canvas, Offset(-_hw * 0.6, -_hh), Offset(-_hw * 0.6, _hh), color, 0.05);
    Neon.glowLine(canvas, Offset(_hw * 0.6, -_hh), Offset(_hw * 0.6, _hh), color, 0.05);
    for (double y = -_hh + 0.4; y < _hh; y += 0.8) {
      Neon.glowLine(canvas, Offset(-_hw * 0.6, y), Offset(_hw * 0.6, y), color.withValues(alpha: 0.8), 0.04);
    }
  }
}

/// A water volume. Sensor tagged [WaterMarker] carrying the surface height.
class WaterBody extends BodyComponent<NeonEchoGame> {
  WaterBody({required this.rect})
      : _hw = rect.width / 2,
        _hh = rect.height / 2 {
    renderBody = false;
  }

  final Rect rect;
  final double _hw;
  final double _hh;
  double _t = 0;

  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBoxXY(_hw, _hh);
    final def = BodyDef(
      type: BodyType.static,
      position: Vector2(rect.left + _hw, rect.top + _hh),
      userData: WaterMarker(rect.top),
    );
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
  void render(Canvas canvas) {
    final body = Rect.fromLTRB(-_hw, -_hh, _hw, _hh);
    canvas.drawRect(
      body,
      Paint()
        ..shader = Gradient.linear(
          Offset(0, -_hh),
          Offset(0, _hh),
          [
            NeonPalette.waterMid.withValues(alpha: 0.35),
            NeonPalette.waterDeep.withValues(alpha: 0.62),
          ],
        ),
    );
    // animated surface ripple
    final surface = Path()..moveTo(-_hw, -_hh);
    for (double x = -_hw; x <= _hw; x += 0.6) {
      surface.lineTo(x, -_hh + 0.12 * math.sin(x * 0.7 + _t * 2));
    }
    Neon.glowPath(canvas, surface, NeonPalette.waterGlow, 0.05);
  }
}

/// A deadly region. Sensor tagged [HazardMarker]. The full-width "fall" plane
/// is created invisible; smaller hazards show a warning stripe.
class HazardBody extends BodyComponent<NeonEchoGame> {
  HazardBody({required this.rect, this.visible = true})
      : _hw = rect.width / 2,
        _hh = rect.height / 2 {
    renderBody = false;
  }

  final Rect rect;
  final bool visible;
  final double _hw;
  final double _hh;
  double _t = 0;

  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBoxXY(_hw, _hh);
    final def = BodyDef(
      type: BodyType.static,
      position: Vector2(rect.left + _hw, rect.top + _hh),
      userData: const HazardMarker(),
    );
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
  void render(Canvas canvas) {
    if (!visible) {
      return;
    }
    final pulse = 0.5 + 0.5 * math.sin(_t * 4);
    Neon.glowLine(
      canvas,
      Offset(-_hw, -_hh),
      Offset(_hw, -_hh),
      NeonPalette.danger.withValues(alpha: 0.4 + 0.4 * pulse),
      0.06,
    );
    final stripe = Neon.stroke(NeonPalette.danger.withValues(alpha: 0.25), 0.05);
    for (double x = -_hw; x < _hw; x += 0.6) {
      canvas.drawLine(Offset(x, -_hh), Offset(x + 0.3, -_hh + 0.3), stripe);
    }
  }
}

/// The level-completion trigger: a glowing beacon tagged [GoalMarker].
class GoalBody extends BodyComponent<NeonEchoGame> {
  GoalBody({required Vector2 center}) : _center = center.clone() {
    renderBody = false;
  }

  final Vector2 _center;
  double _t = 0;

  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBoxXY(1.0, 2.2);
    final def = BodyDef(
      type: BodyType.static,
      position: _center,
      userData: const GoalMarker(),
    );
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
  void render(Canvas canvas) {
    final pulse = 0.6 + 0.4 * math.sin(_t * 3);
    Neon.halo(canvas, Offset.zero, 2.2 * pulse, NeonPalette.signalGreen, alpha: 0.35);
    for (var i = 0; i < 3; i++) {
      final r = (0.6 + i * 0.6 + _t) % 2.2;
      Neon.glowCircle(canvas, Offset.zero, r, NeonPalette.signalGreen, 0.05);
    }
    Neon.glowLine(canvas, const Offset(0, -2.2), const Offset(0, 2.2), NeonPalette.signalGreen, 0.07);
  }
}
