import 'dart:math' as math;
import 'dart:ui';

import '../core/palette.dart';
import '../story/models/dialogue.dart';
import 'character_art.dart';
import 'neon.dart';

/// Vector art for the vehicles and drones, drawn in world **metres**, centred on
/// the physics body's origin.
abstract final class VehicleArtist {
  static (Color, Color) _colors(Character c) => switch (c) {
        Character.james => (NeonPalette.jamesPrimary, NeonPalette.jamesSecondary),
        Character.millie => (NeonPalette.milliePrimary, NeonPalette.millieSecondary),
      };

  /// A low, sleek courier car. Total length ~3.6m.
  static void drawCar(Canvas canvas, {required Character character, required double wheelSpin}) {
    final (primary, secondary) = _colors(character);
    const w = 0.08;

    // underglow
    Neon.halo(canvas, const Offset(0, 0.5), 1.8, primary, alpha: 0.28);

    // body wedge
    final body = Path()
      ..moveTo(-1.7, 0.2)
      ..lineTo(-1.5, -0.35)
      ..quadraticBezierTo(-0.9, -0.62, -0.2, -0.66) // windscreen base
      ..lineTo(0.6, -0.66)
      ..quadraticBezierTo(1.2, -0.6, 1.6, -0.2) // hood
      ..lineTo(1.78, 0.18)
      ..lineTo(1.6, 0.4)
      ..lineTo(-1.5, 0.4)
      ..close();
    Neon.glowPath(canvas, body, primary, w, filled: true, fillAlpha: 0.2);

    // cabin glass
    final cabin = Path()
      ..moveTo(-1.2, -0.34)
      ..lineTo(-0.2, -0.6)
      ..lineTo(0.5, -0.6)
      ..lineTo(0.9, -0.34)
      ..close();
    Neon.glowPath(canvas, cabin, secondary, w * 0.8, filled: true, fillAlpha: 0.3);

    // headlight
    Neon.halo(canvas, const Offset(1.85, -0.05), 0.7, NeonPalette.cyan, alpha: 0.6);
    // taillight
    Neon.halo(canvas, const Offset(-1.78, -0.05), 0.4, NeonPalette.danger, alpha: 0.5);

    _wheel(canvas, const Offset(-1.05, 0.5), 0.46, primary, wheelSpin);
    _wheel(canvas, const Offset(1.05, 0.5), 0.46, primary, wheelSpin);
  }

  /// A courier motorcycle with a rider. Total length ~2.4m.
  static void drawBike(Canvas canvas,
      {required Character character, required double wheelSpin, bool hostile = false}) {
    final primary = hostile ? NeonPalette.hollowRed : _colors(character).$1;
    final secondary = hostile ? NeonPalette.hollowSteel : _colors(character).$2;
    const w = 0.07;

    Neon.halo(canvas, const Offset(0, 0.45), 1.3, primary, alpha: 0.28);

    _wheel(canvas, const Offset(-0.95, 0.5), 0.42, primary, wheelSpin);
    _wheel(canvas, const Offset(0.95, 0.5), 0.42, primary, wheelSpin);

    // frame
    final frame = Path()
      ..moveTo(-0.95, 0.5)
      ..lineTo(-0.1, -0.05)
      ..lineTo(0.6, -0.05)
      ..lineTo(0.95, 0.5)
      ..moveTo(-0.1, -0.05)
      ..lineTo(0.95, 0.5);
    Neon.glowPath(canvas, frame, primary, w);

    // fairing / seat
    final seat = Path()
      ..moveTo(-0.5, -0.08)
      ..quadraticBezierTo(0.1, -0.28, 0.7, -0.12)
      ..lineTo(0.6, -0.02)
      ..lineTo(-0.4, -0.02)
      ..close();
    Neon.glowPath(canvas, seat, secondary, w, filled: true, fillAlpha: 0.25);

    // handlebars
    Neon.glowLine(canvas, const Offset(0.6, -0.05), const Offset(0.95, -0.42), primary, w);
    Neon.halo(canvas, const Offset(1.1, 0.0), 0.5, NeonPalette.cyan, alpha: 0.5);

    // rider (seated), shifted onto the seat
    canvas.save();
    canvas.translate(0.05, -0.78);
    canvas.scale(0.82, 0.82);
    if (hostile) {
      CharacterArtist.drawGrunt(canvas, t: wheelSpin * 0.1, facing: 1, pose: CharacterPose.seated);
    } else {
      CharacterArtist.draw(canvas,
          character: character, t: wheelSpin * 0.1, facing: 1, pose: CharacterPose.seated);
    }
    canvas.restore();
  }

  /// A hovering Hollow gun-drone. ~1.1m wide, bobs with [t].
  static void drawDrone(Canvas canvas, {required double t}) {
    final bob = 0.12 * math.sin(t * 3);
    canvas.save();
    canvas.translate(0, bob);
    const w = 0.06;
    const color = NeonPalette.hollowRed;

    Neon.halo(canvas, Offset.zero, 0.9, color, alpha: 0.3);

    // chassis diamond
    final body = Path()
      ..moveTo(0, -0.32)
      ..lineTo(0.5, 0)
      ..lineTo(0, 0.3)
      ..lineTo(-0.5, 0)
      ..close();
    Neon.glowPath(canvas, body, color, w, filled: true, fillAlpha: 0.22);

    // rotor arms with spin blur
    final spin = t * 22;
    for (final side in const [-1.0, 1.0]) {
      final cx = side * 0.5;
      Neon.glowLine(canvas, Offset(side * 0.32, -0.05), Offset(cx, -0.18), NeonPalette.hollowSteel, w * 0.8);
      final r = 0.26 + 0.02 * math.sin(spin + side);
      Neon.glowCircle(canvas, Offset(cx, -0.2), r, NeonPalette.hotPink, w * 0.5);
    }

    // scanning eye
    Neon.glowCircle(canvas, Offset.zero, 0.12, NeonPalette.danger, w, filled: true, fillAlpha: 0.6);
    Neon.halo(canvas, const Offset(0, 0), 0.3, NeonPalette.danger, alpha: 0.5);

    canvas.restore();
  }

  static void _wheel(Canvas canvas, Offset center, double radius, Color color, double spin) {
    Neon.glowCircle(canvas, center, radius, color, 0.06, filled: true, fillAlpha: 0.1);
    // spinning spokes
    for (var i = 0; i < 4; i++) {
      final a = spin + i * math.pi / 4;
      final d = Offset(math.cos(a), math.sin(a)) * radius * 0.82;
      Neon.glowLine(canvas, center - d, center + d, color.withValues(alpha: 0.7), 0.03);
    }
    Neon.glowCircle(canvas, center, radius * 0.22, NeonPalette.textBright, 0.04);
  }
}
