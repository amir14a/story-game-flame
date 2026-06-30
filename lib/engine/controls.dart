import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/input.dart' show HudButtonComponent;
import 'package:flutter/widgets.dart' show EdgeInsets, FontWeight, TextStyle;

import '../art/neon.dart';
import '../core/palette.dart';
import 'neon_echo_game.dart';

/// The in-engine touch/mouse control rig: a left joystick plus A (jump) and
/// B (fire) buttons and a pause button, all writing into [GameInput].
///
/// It is mounted once for the whole session and merely shown/hidden via
/// [active] — never added/removed — so the controls can never get "lost" on a
/// scene transition.
class Controls extends Component with HasGameReference<NeonEchoGame> {
  bool active = false;

  JoystickComponent? _joystick;

  @override
  Future<void> onLoad() async {
    final viewport = game.camera.viewport;

    _joystick = JoystickComponent(
      knob: _ControlDisc(this, radius: 26, color: NeonPalette.jamesPrimary, fillAlpha: 0.85),
      background: _ControlDisc(this, radius: 62, color: NeonPalette.jamesPrimary, fillAlpha: 0.08),
      margin: const EdgeInsets.only(left: 34, bottom: 34),
    );

    final jump = HudButtonComponent(
      button: _ControlDisc(this, radius: 40, color: NeonPalette.limeGlow, label: 'A', fillAlpha: 0.18),
      buttonDown: _ControlDisc(this, radius: 40, color: NeonPalette.limeGlow, label: 'A', fillAlpha: 0.5),
      margin: const EdgeInsets.only(right: 42, bottom: 46),
      onPressed: () {
        if (active) game.input.setTouchJump(true);
      },
      onReleased: () => game.input.setTouchJump(false),
    );

    final fire = HudButtonComponent(
      button: _ControlDisc(this, radius: 34, color: NeonPalette.amber, label: 'B', fillAlpha: 0.18),
      buttonDown: _ControlDisc(this, radius: 34, color: NeonPalette.amber, label: 'B', fillAlpha: 0.5),
      margin: const EdgeInsets.only(right: 124, bottom: 72),
      onPressed: () {
        if (active) game.input.setTouchFire(true);
      },
      onReleased: () => game.input.setTouchFire(false),
    );

    final pause = HudButtonComponent(
      button: _ControlDisc(this, radius: 20, color: NeonPalette.textDim, label: 'II', fillAlpha: 0.12),
      buttonDown: _ControlDisc(this, radius: 20, color: NeonPalette.textBright, label: 'II', fillAlpha: 0.3),
      margin: const EdgeInsets.only(right: 22, top: 22),
      onPressed: () {
        if (active) game.togglePause();
      },
    );

    await viewport.addAll([_joystick!, jump, fire, pause]);
  }

  @override
  void update(double dt) {
    if (!active) {
      return;
    }
    final d = _joystick?.relativeDelta;
    if (d != null) {
      game.input.setTouchMove(d.x, up: d.y < -0.5, down: d.y > 0.5);
    }
  }
}

/// A round neon control surface (joystick disc / button face). Renders nothing
/// while its owning [Controls] is inactive, so the whole rig hides cleanly.
class _ControlDisc extends PositionComponent {
  _ControlDisc(this.owner, {required double radius, required this.color, this.label, this.fillAlpha = 0.2})
      : super(size: Vector2.all(radius * 2));

  final Controls owner;
  final Color color;
  final String? label;
  final double fillAlpha;

  static final _labelPaint = TextPaint(
    style: const TextStyle(
      color: NeonPalette.textBright,
      fontSize: 20,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.5,
    ),
  );

  @override
  void render(Canvas canvas) {
    if (!owner.active) {
      return;
    }
    final center = Offset(size.x / 2, size.y / 2);
    final r = size.x / 2;
    Neon.glowCircle(canvas, center, r * 0.92, color, 3.0, filled: true, fillAlpha: fillAlpha);
    final text = label;
    if (text != null) {
      _labelPaint.render(canvas, text, Vector2(center.dx, center.dy), anchor: Anchor.center);
    }
  }
}
