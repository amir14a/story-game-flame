import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/input.dart' show HudButtonComponent;
import 'package:flutter/widgets.dart' show EdgeInsets, FontWeight, TextStyle;

import '../art/neon.dart';
import '../core/palette.dart';
import 'neon_echo_game.dart';

/// The in-engine touch/mouse control rig: a left joystick plus A (jump) and
/// B (fire) buttons and a pause button. All of it writes into [GameInput] so it
/// is interchangeable with keyboard input. Lives in the camera viewport so it
/// stays fixed on screen.
class Controls extends Component with HasGameReference<NeonEchoGame> {
  JoystickComponent? _joystick;
  final List<Component> _widgets = [];

  @override
  Future<void> onLoad() async {
    final viewport = game.camera.viewport;

    _joystick = JoystickComponent(
      knob: _ControlDisc(radius: 26, color: NeonPalette.cyan, fillAlpha: 0.85),
      background: _ControlDisc(radius: 62, color: NeonPalette.cyan, fillAlpha: 0.08),
      margin: const EdgeInsets.only(left: 34, bottom: 34),
    );

    final jump = HudButtonComponent(
      button: _ControlDisc(radius: 40, color: NeonPalette.limeGlow, label: 'A', fillAlpha: 0.18),
      buttonDown: _ControlDisc(radius: 40, color: NeonPalette.limeGlow, label: 'A', fillAlpha: 0.5),
      margin: const EdgeInsets.only(right: 42, bottom: 46),
      onPressed: () => game.input.setTouchJump(true),
      onReleased: () => game.input.setTouchJump(false),
    );

    final fire = HudButtonComponent(
      button: _ControlDisc(radius: 34, color: NeonPalette.amber, label: 'B', fillAlpha: 0.18),
      buttonDown: _ControlDisc(radius: 34, color: NeonPalette.amber, label: 'B', fillAlpha: 0.5),
      margin: const EdgeInsets.only(right: 124, bottom: 72),
      onPressed: () => game.input.setTouchFire(true),
      onReleased: () => game.input.setTouchFire(false),
    );

    final pause = HudButtonComponent(
      button: _ControlDisc(radius: 20, color: NeonPalette.textDim, label: 'II', fillAlpha: 0.12),
      buttonDown: _ControlDisc(radius: 20, color: NeonPalette.textBright, label: 'II', fillAlpha: 0.3),
      margin: const EdgeInsets.only(right: 22, top: 22),
      onPressed: game.togglePause,
    );

    _widgets.addAll([_joystick!, jump, fire, pause]);
    await viewport.addAll(_widgets);
  }

  @override
  void update(double dt) {
    final d = _joystick?.relativeDelta;
    if (d != null) {
      game.input.setTouchMove(d.x, up: d.y < -0.5, down: d.y > 0.5);
    }
  }

  @override
  void onRemove() {
    for (final w in _widgets) {
      w.removeFromParent();
    }
    _widgets.clear();
    game.input.clear();
    super.onRemove();
  }
}

/// A round neon control surface (joystick disc / button face) drawn in vector.
class _ControlDisc extends PositionComponent {
  _ControlDisc({required double radius, required this.color, this.label, this.fillAlpha = 0.2})
      : super(size: Vector2.all(radius * 2));

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
    final center = Offset(size.x / 2, size.y / 2);
    final r = size.x / 2;
    Neon.glowCircle(canvas, center, r * 0.92, color, 3.0, filled: true, fillAlpha: fillAlpha);
    final text = label;
    if (text != null) {
      _labelPaint.render(canvas, text, Vector2(center.dx, center.dy), anchor: Anchor.center);
    }
  }
}
