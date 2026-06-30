import 'dart:math' as math;

import 'models/level_config.dart';

/// Procedural helpers so the long, combined levels can be expressed compactly.
/// Distances are in world metres (y grows downward).
abstract final class Build {
  /// A run of rooftop platforms with gaps to vault/jump. Returns the platforms;
  /// use [runEndX] to know where the run ends.
  static List<Platform> roofRun({
    required double x0,
    required int count,
    double width = 9,
    double gap = 4.0,
    double baseY = 12,
    double vary = 2.2,
    double depth = 20,
    double friction = 0.9,
    double phase = 0,
  }) {
    final list = <Platform>[];
    var x = x0;
    for (var i = 0; i < count; i++) {
      final y = baseY + vary * math.sin(i * 0.8 + phase);
      list.add(Platform(x: x, y: y, width: width, height: depth, friction: friction));
      x += width + gap;
    }
    return list;
  }

  static double runEndX({required double x0, required int count, double width = 9, double gap = 4.0}) =>
      x0 + count * (width + gap) - gap;

  /// One long solid floor (a street / catwalk).
  static Platform floor({required double x, required double width, double y = 16, double depth = 14}) =>
      Platform(x: x, y: y, width: width, height: depth);

  /// A continuous, gently rolling road for vehicles — no gaps, shallow hills, so
  /// it is always passable without jumping.
  ///
  /// Points are evenly spaced by [step] (>= a few metres), which keeps every
  /// chain segment well above Forge2D's minimum vertex spacing. The road always
  /// ends *exactly* at [x1], and only if that final point is far enough from the
  /// previous one — appending a near-coincident vertex produces a degenerate
  /// `ChainShape` that throws and leaves the level empty.
  static GroundProfile road({
    required double x0,
    required double x1,
    double y = 20,
    double amp = 1.5,
    double wavelength = 48,
    double step = 4,
    double phase = 0,
  }) {
    double curve(double x) => y + amp * math.sin(x * 2 * math.pi / wavelength + phase);
    final pts = <Pt>[];
    for (var x = x0; x < x1 - 0.5; x += step) {
      pts.add(Pt(x, curve(x)));
    }
    pts.add(Pt(x1, curve(x1))); // exact end, on the curve, never a duplicate
    return GroundProfile(pts);
  }

  static List<EnemySpawn> enemiesAt(EnemyKind kind, List<double> xs, double y, {double patrol = 4}) =>
      [for (final x in xs) EnemySpawn(kind, x: x, y: y, patrol: patrol)];

  static List<Pt> checkpointsEvery(double x0, double x1, double spacing, double y) {
    final list = <Pt>[];
    for (var x = x0; x <= x1; x += spacing) {
      list.add(Pt(x, y));
    }
    return list;
  }

  static Ladder ladder({required double x, required double topY, required double bottomY, double width = 2.6}) =>
      Ladder(x: x, y: topY, width: width, height: bottomY - topY);

  static WaterZone water({required double x, required double surfaceY, required double width, required double depth}) =>
      WaterZone(x: x, y: surfaceY, width: width, height: depth);
}
