import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../core/game_config.dart';
import '../../core/palette.dart';
import '../../engine/neon_echo_game.dart';
import '../../story/models/level_config.dart';
import '../neon.dart';

/// A per-district atmospheric backdrop drawn entirely in vector. It is set as
/// the camera's [backdrop] so it renders statically behind the world, in screen
/// pixels, and reads the camera position to fake multi-layer parallax.
class CityBackdrop extends Component with HasGameReference<NeonEchoGame> {
  CityBackdrop();

  double _t = 0;

  @override
  void update(double dt) => _t += dt;

  _Theme get _theme => _themeFor(game.backdropTheme);

  @override
  void render(Canvas canvas) {
    final size = game.size;
    final theme = _theme;
    final cam = game.camera.viewfinder.position;

    _sky(canvas, size, theme);
    _stars(canvas, size, theme, cam);

    if (theme.underwater) {
      _caustics(canvas, size, cam);
    }

    // Distant → near skyline layers (parallax fractions < 1 scroll slower).
    _skyline(canvas, size, theme, cam, depth: 0.18, base: 0.62, color: theme.farBuilding, h: 0.42, gap: 280);
    _skyline(canvas, size, theme, cam, depth: 0.38, base: 0.74, color: theme.midBuilding, h: 0.5, gap: 210);
    _skyline(canvas, size, theme, cam, depth: 0.62, base: 0.9, color: theme.nearBuilding, h: 0.62, gap: 150);

    if (theme.underwater) {
      _waterTint(canvas, size);
      _bubbles(canvas, size, cam);
    } else if (theme.rain) {
      _rain(canvas, size, theme);
    }

    _vignette(canvas, size);
  }

  // ---------------------------------------------------------------- layers
  void _sky(Canvas canvas, Vector2 size, _Theme theme) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = Gradient.linear(
          Offset(size.x / 2, 0),
          Offset(size.x / 2, size.y),
          theme.sky,
          theme.skyStops,
        ),
    );
    // horizon glow
    Neon.halo(canvas, Offset(size.x * 0.5, size.y * 0.66), size.x * 0.6, theme.glow, alpha: 0.22);
  }

  void _stars(Canvas canvas, Vector2 size, _Theme theme, Vector2 cam) {
    final rng = math.Random(7);
    final offset = cam.x * GameConfig.zoom * 0.06;
    final paint = Paint()..color = theme.glow.withValues(alpha: 0.6);
    for (var i = 0; i < 60; i++) {
      final x = (rng.nextDouble() * size.x * 1.5 - offset) % size.x;
      final y = rng.nextDouble() * size.y * 0.6;
      final tw = 0.4 + 0.6 * (0.5 + 0.5 * math.sin(_t * 2 + i));
      canvas.drawCircle(Offset(x, y), 0.9 * tw, paint);
    }
    // a moon / sun disc
    final disc = Offset(size.x * 0.78, size.y * 0.22);
    Neon.halo(canvas, disc, size.x * 0.12, theme.disc, alpha: 0.5);
    canvas.drawCircle(disc, size.x * 0.04, Paint()..color = theme.disc.withValues(alpha: 0.85));
  }

  void _skyline(
    Canvas canvas,
    Vector2 size,
    _Theme theme,
    Vector2 cam, {
    required double depth,
    required double base,
    required Color color,
    required double h,
    required double gap,
  }) {
    final scroll = cam.x * GameConfig.zoom * depth;
    final vShift = cam.y * GameConfig.zoom * depth * 0.5;
    final baseY = size.y * base + vShift;
    final span = size.x + gap * 2;
    final start = -(scroll % gap) - gap;
    final rng = math.Random((depth * 1000).toInt());

    for (double x = start; x < span; x += gap) {
      final seed = ((x + scroll) / gap).round();
      final r = math.Random(seed * 911 + (depth * 100).toInt());
      final bw = gap * (0.5 + r.nextDouble() * 0.4);
      final bh = size.y * h * (0.5 + r.nextDouble() * 0.7);
      final rect = Rect.fromLTWH(x, baseY - bh, bw, bh + size.y);
      canvas.drawRect(rect, Paint()..color = color);
      // edge neon
      canvas.drawLine(Offset(x, baseY - bh), Offset(x + bw, baseY - bh),
          Neon.stroke(theme.glow.withValues(alpha: 0.35), 1.4));
      // a few lit windows
      final cols = 2 + r.nextInt(3);
      for (var wy = baseY - bh + 10; wy < baseY - 10; wy += 16) {
        for (var ci = 0; ci < cols; ci++) {
          if (r.nextDouble() < 0.5) continue;
          final wx = x + 8 + ci * (bw - 16) / cols;
          canvas.drawRect(
            Rect.fromLTWH(wx, wy, 3, 5),
            Paint()..color = (r.nextBool() ? theme.glow : theme.accent).withValues(alpha: 0.5),
          );
        }
      }
      rng.nextDouble();
    }
  }

  void _rain(Canvas canvas, Vector2 size, _Theme theme) {
    final paint = Neon.stroke(theme.glow.withValues(alpha: 0.16), 1.2);
    final n = 90;
    for (var i = 0; i < n; i++) {
      final phase = (_t * 900 + i * 53) % (size.y + 60);
      final x = (i * 97.0) % size.x;
      canvas.drawLine(Offset(x, phase - 18), Offset(x - 6, phase), paint);
    }
  }

  void _caustics(Canvas canvas, Vector2 size, Vector2 cam) {
    final paint = Neon.stroke(NeonPalette.waterGlow.withValues(alpha: 0.1), 2.2);
    for (var i = 0; i < 10; i++) {
      final y = size.y * (i / 10) + 12 * math.sin(_t + i);
      final path = Path()..moveTo(0, y);
      for (double x = 0; x <= size.x; x += 40) {
        path.lineTo(x, y + 10 * math.sin(x * 0.02 + _t * 1.5 + i));
      }
      canvas.drawPath(path, paint);
    }
  }

  void _bubbles(Canvas canvas, Vector2 size, Vector2 cam) {
    final paint = Paint()..color = NeonPalette.waterGlow.withValues(alpha: 0.18);
    for (var i = 0; i < 40; i++) {
      final rise = (_t * 40 + i * 37) % (size.y + 40);
      final x = (i * 83.0 - cam.x * GameConfig.zoom * 0.2) % size.x;
      canvas.drawCircle(Offset(x, size.y - rise), 1.4 + (i % 3), paint);
    }
  }

  void _waterTint(Canvas canvas, Vector2 size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()
        ..shader = Gradient.linear(
          Offset(0, 0),
          Offset(0, size.y),
          [
            NeonPalette.waterMid.withValues(alpha: 0.25),
            NeonPalette.waterDeep.withValues(alpha: 0.55),
          ],
        ),
    );
  }

  void _vignette(Canvas canvas, Vector2 size) {
    final center = Offset(size.x / 2, size.y / 2);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()
        ..shader = Gradient.radial(center, size.x * 0.7, [
          const Color(0x00000000),
          const Color(0x88000000),
        ], [0.6, 1.0]),
    );
  }

  // ---------------------------------------------------------------- themes
  _Theme _themeFor(DistrictTheme t) {
    switch (t) {
      case DistrictTheme.rooftops:
        return _Theme(
          sky: const [NeonPalette.voidBlack, NeonPalette.deepNight, NeonPalette.hazePurple],
          skyStops: const [0, 0.55, 1],
          glow: NeonPalette.cyan,
          accent: NeonPalette.magenta,
          disc: NeonPalette.violet,
          farBuilding: const Color(0xFF0C1130),
          midBuilding: const Color(0xFF111842),
          nearBuilding: const Color(0xFF0A0E26),
          rain: true,
        );
      case DistrictTheme.lowtownNight:
        return _Theme(
          sky: const [Color(0xFF1A0A2A), Color(0xFF2A1B4A), Color(0xFF3A1240)],
          skyStops: const [0, 0.5, 1],
          glow: NeonPalette.magenta,
          accent: NeonPalette.hotPink,
          disc: NeonPalette.hotPink,
          farBuilding: const Color(0xFF241038),
          midBuilding: const Color(0xFF2E143F),
          nearBuilding: const Color(0xFF190826),
          rain: true,
        );
      case DistrictTheme.skyway:
        return _Theme(
          sky: const [Color(0xFF050617), Color(0xFF161B4A), Color(0xFF3A1E5A)],
          skyStops: const [0, 0.5, 1],
          glow: NeonPalette.cyan,
          accent: NeonPalette.violet,
          disc: NeonPalette.cyan,
          farBuilding: const Color(0xFF0A1038),
          midBuilding: const Color(0xFF131A52),
          nearBuilding: const Color(0xFF080C2A),
          rain: true,
        );
      case DistrictTheme.sunken:
        return _Theme(
          sky: const [NeonPalette.waterDeep, Color(0xFF06303F), NeonPalette.waterMid],
          skyStops: const [0, 0.5, 1],
          glow: NeonPalette.waterGlow,
          accent: NeonPalette.cyan,
          disc: NeonPalette.waterGlow,
          farBuilding: const Color(0xFF062231),
          midBuilding: const Color(0xFF083446),
          nearBuilding: const Color(0xFF04161F),
          rain: false,
          underwater: true,
        );
      case DistrictTheme.reservoir:
        return _Theme(
          sky: const [Color(0xFF0B3A52), Color(0xFF12698F), Color(0xFF1FA6C2)],
          skyStops: const [0, 0.55, 1],
          glow: NeonPalette.waterGlow,
          accent: NeonPalette.signalGreen,
          disc: const Color(0xFFFFE9A8),
          farBuilding: const Color(0xFF115273),
          midBuilding: const Color(0xFF0E4763),
          nearBuilding: const Color(0xFF0A3349),
          rain: false,
          underwater: true,
        );
      case DistrictTheme.steelVeins:
        return _Theme(
          sky: const [Color(0xFF160803), Color(0xFF2E1206), Color(0xFF4A1E08)],
          skyStops: const [0, 0.5, 1],
          glow: NeonPalette.amber,
          accent: NeonPalette.danger,
          disc: NeonPalette.amber,
          farBuilding: const Color(0xFF24130A),
          midBuilding: const Color(0xFF311708),
          nearBuilding: const Color(0xFF180A04),
          rain: true,
        );
      case DistrictTheme.spire:
        return _Theme(
          sky: const [Color(0xFF0A0A2A), Color(0xFF3A1E5A), Color(0xFFB23A7A)],
          skyStops: const [0, 0.55, 1],
          glow: NeonPalette.cyan,
          accent: NeonPalette.hotPink,
          disc: const Color(0xFFFFC56B),
          farBuilding: const Color(0xFF1A1448),
          midBuilding: const Color(0xFF241A5A),
          nearBuilding: const Color(0xFF120C30),
          rain: true,
        );
    }
  }
}

class _Theme {
  _Theme({
    required this.sky,
    required this.skyStops,
    required this.glow,
    required this.accent,
    required this.disc,
    required this.farBuilding,
    required this.midBuilding,
    required this.nearBuilding,
    this.rain = false,
    this.underwater = false,
  });

  final List<Color> sky;
  final List<double> skyStops;
  final Color glow;
  final Color accent;
  final Color disc;
  final Color farBuilding;
  final Color midBuilding;
  final Color nearBuilding;
  final bool rain;
  final bool underwater;
}
