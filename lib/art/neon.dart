import 'dart:ui';

/// Low-level neon drawing helpers shared by every painter in the game.
///
/// These work in whatever unit the [Canvas] is currently in: the engine draws
/// actors in world **metres** (so widths are ~0.1), while Flutter overlays draw
/// in **pixels** (so widths are ~3). Callers pass sizes appropriate to context.
abstract final class Neon {
  static Paint fill(Color color) => Paint()..color = color;

  static Paint stroke(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  /// A blurred "bloom" paint used under a crisp stroke to fake neon glow.
  static Paint bloom(Color color, double width, double sigma) =>
      stroke(color.withValues(alpha: 0.55), width)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);

  /// Draws a line with a soft outer glow and a bright core.
  static void glowLine(
    Canvas canvas,
    Offset a,
    Offset b,
    Color color,
    double width, {
    double glowScale = 2.6,
  }) {
    canvas.drawLine(a, b, bloom(color, width * glowScale, width * 1.6));
    canvas.drawLine(a, b, stroke(color, width));
  }

  /// Draws a path as a glowing neon outline (and optionally a translucent fill).
  static void glowPath(
    Canvas canvas,
    Path path,
    Color color,
    double width, {
    bool filled = false,
    double fillAlpha = 0.18,
    double glowScale = 2.6,
  }) {
    if (filled) {
      canvas.drawPath(path, fill(color.withValues(alpha: fillAlpha)));
    }
    canvas.drawPath(path, bloom(color, width * glowScale, width * 1.6));
    canvas.drawPath(path, stroke(color, width));
  }

  static void glowCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double width, {
    bool filled = false,
    double fillAlpha = 0.2,
  }) {
    if (filled) {
      canvas.drawCircle(center, radius, fill(color.withValues(alpha: fillAlpha)));
    }
    canvas.drawCircle(center, radius, bloom(color, width * 2.6, width * 1.6));
    canvas.drawCircle(center, radius, stroke(color, width));
  }

  /// A soft radial halo (no outline) — used for lights, headlamps, signals.
  static void halo(Canvas canvas, Offset center, double radius, Color color, {double alpha = 0.5}) {
    final paint = Paint()
      ..shader = Gradient.radial(center, radius, [
        color.withValues(alpha: alpha),
        color.withValues(alpha: 0.0),
      ]);
    canvas.drawCircle(center, radius, paint);
  }

  static void glowRRect(
    Canvas canvas,
    RRect rrect,
    Color color,
    double width, {
    bool filled = false,
    double fillAlpha = 0.16,
  }) {
    if (filled) {
      canvas.drawRRect(rrect, fill(color.withValues(alpha: fillAlpha)));
    }
    canvas.drawRRect(rrect, bloom(color, width * 2.4, width * 1.5));
    canvas.drawRRect(rrect, stroke(color, width));
  }
}
