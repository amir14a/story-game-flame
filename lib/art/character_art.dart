import 'dart:math' as math;
import 'dart:ui';

import '../core/palette.dart';
import '../story/models/dialogue.dart';
import 'neon.dart';

/// The pose a humanoid figure is drawn in. The artist interpolates limb
/// positions from a continuous time value so movement reads as fluid.
enum CharacterPose { idle, run, jump, fall, swim, climb, aim, seated }

/// Per-character silhouette so the siblings actually look different — not just
/// recoloured. Kade (brother) is taller and broad-shouldered with cropped hair,
/// a hood collar and a courier satchel; Aria (sister) is slighter with a pinched
/// waist, a fringe and a long swaying ponytail.
class _Build {
  const _Build({
    required this.shoulder,
    required this.waist,
    required this.hip,
    required this.headR,
    required this.headY,
    required this.scaleY,
  });
  final double shoulder; // half-width at the shoulders
  final double waist; // half-width at mid-torso
  final double hip; // half-width at the hips
  final double headR;
  final double headY;
  final double scaleY; // overall height multiplier (Kade a touch taller)
}

/// Draws the sibling characters (and humanoid enemies) as clean neon vector
/// figures, entirely with [Canvas] paths. Everything is expressed in world
/// **metres** and centred on the body's origin.
abstract final class CharacterArtist {
  static const double height = 1.7;

  static const _Build _kadeBuild = _Build(
    shoulder: 0.21, waist: 0.20, hip: 0.16, headR: 0.205, headY: -0.62, scaleY: 1.0,
  );
  static const _Build _ariaBuild = _Build(
    shoulder: 0.145, waist: 0.105, hip: 0.155, headR: 0.18, headY: -0.6, scaleY: 0.94,
  );
  static const _Build _gruntBuild = _Build(
    shoulder: 0.22, waist: 0.2, hip: 0.17, headR: 0.2, headY: -0.62, scaleY: 1.02,
  );

  static (Color, Color) _colors(Character c) => switch (c) {
        Character.kade => (NeonPalette.kadePrimary, NeonPalette.kadeSecondary),
        Character.aria => (NeonPalette.ariaPrimary, NeonPalette.ariaSecondary),
      };

  static void draw(
    Canvas canvas, {
    required Character character,
    required double t,
    required int facing,
    required CharacterPose pose,
    double opacity = 1.0,
  }) {
    final (primary, secondary) = _colors(character);
    _drawFigure(canvas, primary, secondary,
        character: character,
        build: character == Character.aria ? _ariaBuild : _kadeBuild,
        t: t,
        facing: facing,
        pose: pose,
        opacity: opacity);
  }

  /// A hostile Hollow grunt (red, generic build, faceplate visor).
  static void drawGrunt(Canvas canvas, {required double t, required int facing, required CharacterPose pose}) {
    _drawFigure(canvas, NeonPalette.hollowRed, NeonPalette.hollowSteel,
        character: null, build: _gruntBuild, t: t, facing: facing, pose: pose);
  }

  static void _drawFigure(
    Canvas canvas,
    Color primary,
    Color secondary, {
    required Character? character,
    required _Build build,
    required double t,
    required int facing,
    required CharacterPose pose,
    double opacity = 1.0,
  }) {
    final p = primary.withValues(alpha: opacity);
    final s = secondary.withValues(alpha: opacity * 0.95);

    canvas.save();
    final dir = facing.toDouble().sign == 0 ? 1.0 : facing.toDouble();
    canvas.scale(dir, build.scaleY);

    const double w = 0.07;
    final swing = math.sin(t * 11);
    final swing2 = math.sin(t * 11 + math.pi);

    const shoulder = Offset(0, -0.42);
    const hip = Offset(0, 0.16);
    final headCenter = Offset(0.02, build.headY);

    late Offset lFoot, rFoot, lKnee, rKnee, lHand, rHand, lElbow, rElbow;
    switch (pose) {
      case CharacterPose.run:
        lFoot = Offset(0.34 * swing, 0.82);
        rFoot = Offset(0.34 * swing2, 0.82);
        lKnee = Offset(0.18 * swing, 0.5);
        rKnee = Offset(0.18 * swing2, 0.5);
        lHand = Offset(0.30 * swing2, -0.18);
        rHand = Offset(0.30 * swing, -0.18);
        lElbow = Offset(0.18 * swing2, -0.34);
        rElbow = Offset(0.18 * swing, -0.34);
      case CharacterPose.jump:
        lFoot = const Offset(-0.18, 0.62);
        rFoot = const Offset(0.22, 0.7);
        lKnee = const Offset(-0.1, 0.36);
        rKnee = const Offset(0.16, 0.4);
        lHand = const Offset(-0.28, -0.62);
        rHand = const Offset(0.28, -0.6);
        lElbow = const Offset(-0.2, -0.44);
        rElbow = const Offset(0.2, -0.42);
      case CharacterPose.fall:
        lFoot = const Offset(-0.24, 0.74);
        rFoot = const Offset(0.24, 0.74);
        lKnee = const Offset(-0.14, 0.46);
        rKnee = const Offset(0.14, 0.46);
        lHand = Offset(-0.34, -0.5 + 0.05 * swing);
        rHand = Offset(0.34, -0.5 + 0.05 * swing2);
        lElbow = const Offset(-0.24, -0.4);
        rElbow = const Offset(0.24, -0.4);
      case CharacterPose.swim:
        lFoot = Offset(-0.32 + 0.1 * swing, 0.6 + 0.12 * swing);
        rFoot = Offset(-0.36 + 0.1 * swing2, 0.78 + 0.12 * swing2);
        lKnee = const Offset(-0.16, 0.44);
        rKnee = const Offset(-0.18, 0.52);
        lHand = Offset(0.46, -0.5 + 0.08 * swing);
        rHand = Offset(0.4, -0.34 + 0.08 * swing2);
        lElbow = const Offset(0.24, -0.46);
        rElbow = const Offset(0.22, -0.36);
      case CharacterPose.climb:
        lFoot = Offset(-0.16, 0.74 + 0.06 * swing);
        rFoot = Offset(0.18, 0.6 - 0.06 * swing);
        lKnee = const Offset(-0.12, 0.46);
        rKnee = const Offset(0.16, 0.42);
        lHand = Offset(0.04, -0.78 + 0.08 * swing);
        rHand = Offset(0.1, -0.5 - 0.08 * swing);
        lElbow = const Offset(0.06, -0.56);
        rElbow = const Offset(0.14, -0.46);
      case CharacterPose.aim:
        lFoot = const Offset(-0.22, 0.82);
        rFoot = const Offset(0.16, 0.82);
        lKnee = const Offset(-0.12, 0.5);
        rKnee = const Offset(0.12, 0.5);
        lHand = const Offset(0.52, -0.34); // front arm holds the weapon
        lElbow = const Offset(0.28, -0.36);
        rHand = const Offset(0.16, -0.18); // back arm braced
        rElbow = const Offset(0.1, -0.3);
      case CharacterPose.seated:
        lFoot = const Offset(0.18, 0.58);
        rFoot = const Offset(0.3, 0.66);
        lKnee = const Offset(0.32, 0.3);
        rKnee = const Offset(0.34, 0.36);
        lHand = const Offset(0.34, -0.2);
        rHand = const Offset(0.42, -0.18);
        lElbow = const Offset(0.2, -0.32);
        rElbow = const Offset(0.26, -0.3);
      case CharacterPose.idle:
        final breathe = 0.02 * math.sin(t * 2.4);
        lFoot = Offset(-0.14, 0.82 + breathe);
        rFoot = Offset(0.14, 0.82 + breathe);
        lKnee = const Offset(-0.1, 0.5);
        rKnee = const Offset(0.1, 0.5);
        lHand = Offset(-0.22, -0.1 + breathe);
        rHand = Offset(0.22, -0.1 + breathe);
        lElbow = const Offset(-0.18, -0.3);
        rElbow = const Offset(0.18, -0.3);
    }

    // back limbs (dimmer for depth)
    _limb(canvas, hip, rKnee, rFoot, s, w * 0.9);
    _limb(canvas, shoulder, rElbow, rHand, s, w * 0.9);

    // ponytail sits behind the body for Aria
    if (character == Character.aria) {
      _ponytail(canvas, headCenter, build.headR, s, w, swing, t);
    }
    // hood collar behind the neck for Kade
    if (character == Character.kade) {
      _hood(canvas, build, s, w);
    }

    // torso (shaped per build)
    final torso = Path()
      ..moveTo(build.shoulder, shoulder.dy)
      ..quadraticBezierTo(build.waist, -0.1, build.hip, hip.dy)
      ..lineTo(-build.hip, hip.dy)
      ..quadraticBezierTo(-build.waist, -0.1, -build.shoulder, shoulder.dy)
      ..close();
    Neon.glowPath(canvas, torso, p, w, filled: true, fillAlpha: 0.22);

    // hip / jacket hem cue: Aria gets a slight tunic flare, Kade a belt line
    if (character == Character.aria) {
      final hem = Path()
        ..moveTo(-build.hip - 0.04, hip.dy)
        ..lineTo(build.hip + 0.04, hip.dy)
        ..lineTo(build.hip - 0.02, hip.dy + 0.16)
        ..lineTo(-build.hip + 0.02, hip.dy + 0.16)
        ..close();
      Neon.glowPath(canvas, hem, p, w * 0.8, filled: true, fillAlpha: 0.18);
    } else {
      Neon.glowLine(canvas, Offset(-build.hip, hip.dy), Offset(build.hip, hip.dy), s, w * 0.7);
    }

    // chest accent
    Neon.glowLine(canvas, const Offset(-0.04, -0.34), const Offset(0.06, 0.04), s, w * 0.6);

    // satchel strap for Kade
    if (character == Character.kade) {
      Neon.glowLine(canvas, const Offset(0.16, -0.4), const Offset(-0.16, 0.12), s, w * 0.8);
      Neon.glowRRect(
        canvas,
        RRect.fromRectAndRadius(const Rect.fromLTWH(-0.34, 0.0, 0.2, 0.22), const Radius.circular(0.05)),
        s,
        w * 0.7,
        filled: true,
        fillAlpha: 0.2,
      );
    }
    // slim data-deck on Aria's hip
    if (character == Character.aria) {
      Neon.glowRRect(
        canvas,
        RRect.fromRectAndRadius(const Rect.fromLTWH(0.16, 0.04, 0.14, 0.1), const Radius.circular(0.03)),
        NeonPalette.signalGreen.withValues(alpha: opacity),
        w * 0.6,
        filled: true,
        fillAlpha: 0.3,
      );
    }

    // head
    Neon.glowCircle(canvas, headCenter, build.headR, p, w, filled: true, fillAlpha: 0.25);
    _faceAndHair(canvas, character, headCenter, build, p, s, w);

    // front limbs
    _limb(canvas, hip, lKnee, lFoot, p, w);
    _limb(canvas, shoulder, lElbow, lHand, p, w);

    if (pose == CharacterPose.aim) {
      Neon.glowLine(canvas, lHand, Offset(lHand.dx + 0.28, lHand.dy), NeonPalette.amber, w);
      Neon.halo(canvas, Offset(lHand.dx + 0.3, lHand.dy), 0.16, NeonPalette.amber, alpha: 0.5);
    }

    canvas.restore();
  }

  // ---- character-specific features -------------------------------------
  static void _faceAndHair(
      Canvas canvas, Character? character, Offset c, _Build b, Color p, Color s, double w) {
    final r = b.headR;
    switch (character) {
      case Character.kade:
        // cropped hair cap + short spikes
        final cap = Path()
          ..moveTo(c.dx - r * 0.95, c.dy - r * 0.1)
          ..quadraticBezierTo(c.dx, c.dy - r * 1.7, c.dx + r * 0.95, c.dy - r * 0.1);
        Neon.glowPath(canvas, cap, s, w * 0.9);
        for (var i = -1; i <= 1; i++) {
          final x = c.dx + i * r * 0.55;
          Neon.glowLine(canvas, Offset(x, c.dy - r * 0.7), Offset(x + r * 0.18, c.dy - r * 1.25), s, w * 0.6);
        }
        // visor
        Neon.glowLine(canvas, Offset(c.dx - r * 0.1, c.dy), Offset(c.dx + r * 0.8, c.dy + r * 0.1), s, w * 0.8);
      case Character.aria:
        // soft fringe sweeping across the forehead
        final fringe = Path()
          ..moveTo(c.dx - r * 0.9, c.dy - r * 0.2)
          ..quadraticBezierTo(c.dx - r * 0.2, c.dy - r * 1.4, c.dx + r * 1.0, c.dy - r * 0.5)
          ..quadraticBezierTo(c.dx + r * 0.5, c.dy - r * 0.3, c.dx + r * 0.2, c.dy - r * 0.15);
        Neon.glowPath(canvas, fringe, s, w * 0.85, filled: true, fillAlpha: 0.18);
        // eye
        Neon.glowCircle(canvas, Offset(c.dx + r * 0.35, c.dy + r * 0.08), r * 0.1, NeonPalette.textBright, w * 0.5);
      case null:
        // grunt faceplate
        Neon.glowRRect(
          canvas,
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(c.dx, c.dy), width: r * 1.6, height: r * 1.2),
            Radius.circular(r * 0.3),
          ),
          s,
          w * 0.7,
        );
        Neon.glowLine(canvas, Offset(c.dx - r * 0.5, c.dy), Offset(c.dx + r * 0.5, c.dy), NeonPalette.danger, w * 0.7);
    }
  }

  static void _ponytail(Canvas canvas, Offset head, double r, Color s, double w, double swing, double t) {
    final sway = 0.05 * swing + 0.03 * math.sin(t * 2.2);
    final base = Offset(head.dx - r * 0.7, head.dy - r * 0.3);
    final mid = Offset(base.dx - 0.18 - sway, head.dy + 0.05 + sway);
    final tip = Offset(base.dx - 0.28 - sway * 1.6, head.dy + 0.4 + sway);
    final tail = Path()
      ..moveTo(base.dx, base.dy - 0.04)
      ..quadraticBezierTo(mid.dx - 0.06, mid.dy, tip.dx, tip.dy)
      ..quadraticBezierTo(mid.dx + 0.08, mid.dy + 0.02, base.dx + 0.06, base.dy + 0.04)
      ..close();
    Neon.glowPath(canvas, tail, s, w * 0.85, filled: true, fillAlpha: 0.28);
    // tie
    Neon.glowCircle(canvas, base, 0.05, s, w * 0.6, filled: true, fillAlpha: 0.4);
  }

  static void _hood(Canvas canvas, _Build b, Color s, double w) {
    final collar = Path()
      ..moveTo(-b.shoulder - 0.04, -0.4)
      ..quadraticBezierTo(0, -0.66, b.shoulder + 0.04, -0.4)
      ..quadraticBezierTo(0, -0.52, -b.shoulder - 0.04, -0.4)
      ..close();
    Neon.glowPath(canvas, collar, s, w * 0.8, filled: true, fillAlpha: 0.2);
  }

  static void _limb(Canvas canvas, Offset root, Offset joint, Offset end, Color color, double w) {
    final path = Path()
      ..moveTo(root.dx, root.dy)
      ..quadraticBezierTo(joint.dx, joint.dy, end.dx, end.dy);
    Neon.glowPath(canvas, path, color, w);
  }
}
