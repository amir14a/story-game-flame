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
  static GroundProfile road({
    required double x0,
    required double x1,
    double y = 20,
    double amp = 1.5,
    double wavelength = 48,
    double step = 4,
    double phase = 0,
  }) {
    final pts = <Pt>[];
    for (var x = x0; x <= x1; x += step) {
      pts.add(Pt(x, y + amp * math.sin(x * 2 * math.pi / wavelength + phase)));
    }
    pts.add(Pt(x1, y));
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
