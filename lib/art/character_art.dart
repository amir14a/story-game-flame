import 'dart:math' as math;
import 'dart:ui';

import '../core/palette.dart';
import '../story/models/dialogue.dart';
import 'neon.dart';

/// The pose a humanoid figure is drawn in. The artist interpolates limb
/// positions from a continuous time value so movement reads as fluid.
enum CharacterPose { idle, run, jump, fall, swim, climb, aim, seated }

/// Draws the sibling characters (and humanoid enemies) as clean neon vector
/// figures, entirely with [Canvas] paths. Everything is expressed in world
/// **metres** and centred on the body's origin, so the art tracks the physics
/// body exactly.
abstract final class CharacterArtist {
  /// Nominal figure height in metres. Body fixtures are sized to match.
  static const double height = 1.7;

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
    _drawFigure(canvas, primary, secondary, t: t, facing: facing, pose: pose, opacity: opacity);
  }

  /// Draws a hostile humanoid (Hollow grunt) in red.
  static void drawGrunt(Canvas canvas, {required double t, required int facing, required CharacterPose pose}) {
    _drawFigure(canvas, NeonPalette.hollowRed, NeonPalette.hollowSteel,
        t: t, facing: facing, pose: pose);
  }

  static void _drawFigure(
    Canvas canvas,
    Color primary,
    Color secondary, {
    required double t,
    required int facing,
    required CharacterPose pose,
    double opacity = 1.0,
  }) {
    final p = primary.withValues(alpha: opacity);
    final s = secondary.withValues(alpha: opacity * 0.9);

    canvas.save();
    canvas.scale(facing.toDouble().sign == 0 ? 1 : facing.toDouble(), 1);

    const double w = 0.07; // neon stroke width in metres
    final swing = math.sin(t * 11);
    final swing2 = math.sin(t * 11 + math.pi);

    // Anchor points (metres, origin at body centre).
    const shoulder = Offset(0, -0.42);
    const hip = Offset(0, 0.16);
    const headCenter = Offset(0.02, -0.62);

    // ---- legs / arms posing per pose -----------------------------------
    late Offset lFoot, rFoot, lKnee, rKnee;
    late Offset lHand, rHand, lElbow, rElbow;

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
        rHand = const Offset(0.52, -0.34); // front arm extended (holds weapon)
        rElbow = const Offset(0.28, -0.36);
        lHand = const Offset(0.16, -0.18); // back arm braced
        lElbow = const Offset(0.1, -0.3);
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
        lFoot = Offset(-0.16, 0.82 + breathe);
        rFoot = Offset(0.16, 0.82 + breathe);
        lKnee = const Offset(-0.12, 0.5);
        rKnee = const Offset(0.12, 0.5);
        lHand = Offset(-0.24, -0.1 + breathe);
        rHand = Offset(0.24, -0.1 + breathe);
        lElbow = const Offset(-0.2, -0.3);
        rElbow = const Offset(0.2, -0.3);
    }

    // ---- back limbs (dimmer for depth) ---------------------------------
    _limb(canvas, hip, rKnee, rFoot, s, w * 0.9);
    _limb(canvas, shoulder, rElbow, rHand, s, w * 0.9);

    // ---- torso ----------------------------------------------------------
    final torso = Path()
      ..moveTo(shoulder.dx - 0.16, shoulder.dy)
      ..quadraticBezierTo(0.22, -0.1, hip.dx + 0.12, hip.dy)
      ..lineTo(hip.dx - 0.12, hip.dy)
      ..quadraticBezierTo(-0.22, -0.1, shoulder.dx - 0.16, shoulder.dy)
      ..close();
    Neon.glowPath(canvas, torso, p, w, filled: true, fillAlpha: 0.22);

    // a little chest/jacket accent line
    Neon.glowLine(canvas, const Offset(-0.05, -0.34), const Offset(0.08, 0.06), s, w * 0.7);

    // ---- head -----------------------------------------------------------
    Neon.glowCircle(canvas, headCenter, 0.2, p, w, filled: true, fillAlpha: 0.25);
    // visor
    Neon.glowLine(canvas, Offset(headCenter.dx - 0.02, headCenter.dy - 0.02),
        Offset(headCenter.dx + 0.16, headCenter.dy + 0.02), s, w * 0.8);

    // ---- front limbs ----------------------------------------------------
    _limb(canvas, hip, lKnee, lFoot, p, w);
    _limb(canvas, shoulder, lElbow, lHand, p, w);

    // weapon for aim pose
    if (pose == CharacterPose.aim) {
      Neon.glowLine(canvas, rHand, Offset(rHand.dx + 0.28, rHand.dy), NeonPalette.amber, w);
      Neon.halo(canvas, Offset(rHand.dx + 0.3, rHand.dy), 0.16, NeonPalette.amber, alpha: 0.5);
    }

    canvas.restore();
  }

  /// A two-segment limb drawn as a smooth glowing curve.
  static void _limb(Canvas canvas, Offset root, Offset joint, Offset end, Color color, double w) {
    final path = Path()
      ..moveTo(root.dx, root.dy)
      ..quadraticBezierTo(joint.dx, joint.dy, end.dx, end.dy);
    Neon.glowPath(canvas, path, color, w);
  }
}
