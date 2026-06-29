import 'dart:ui';

import 'package:flame/components.dart';

import '../engine/neon_echo_game.dart';
import '../story/models/level_config.dart';

/// Implemented by anything that casts light into the scene (the player, enemies,
/// pickups, the goal, vehicle headlamps). The [LightingLayer] collects every
/// mounted emitter in the world each frame.
mixin LightEmitter on Component {
  Vector2 get lightWorldPosition;
  double get lightRadius;
  Color get lightColor;
  double get lightIntensity => 1.0;
}

/// A real 2D lighting pass drawn over the world. It lays an ambient "night"
/// veil across the visible area, then carves soft pools of visibility out of it
/// at every [LightEmitter] (so the scene reads as lit by its neon sources), and
/// finally adds a gentle additive colour cast for mood.
///
/// Rendered last in the world (high [priority]) so it sits on top of all the
/// terrain, actors and effects.
class LightingLayer extends Component with HasGameReference<NeonEchoGame> {
  LightingLayer() : super(priority: 1000);

  Color _ambientFor(DistrictTheme theme) {
    switch (theme) {
      case DistrictTheme.sunken:
        return const Color(0xE6020E18); // deep, blue, oppressive
      case DistrictTheme.reservoir:
        return const Color(0xB4031722);
      case DistrictTheme.steelVeins:
        return const Color(0xD61A0A04); // smoky amber-black
      case DistrictTheme.lowtownNight:
        return const Color(0xCC120726);
      case DistrictTheme.spire:
        return const Color(0xCC07061C);
      case DistrictTheme.skyway:
        return const Color(0xCC05061A);
      case DistrictTheme.rooftops:
        return const Color(0xD4050614);
    }
  }

  @override
  void render(Canvas canvas) {
    final rect = game.camera.visibleWorldRect.inflate(2);
    var ambient = _ambientFor(game.backdropTheme);
    // Memories breathe a little lighter than the present.
    if (game.state.flashback) {
      ambient = ambient.withValues(alpha: ambient.a * 0.6);
    }

    final lights = game.world.children
        .whereType<LightEmitter>()
        .where((e) => e.isMounted)
        .toList(growable: false);

    // --- Pass 1: ambient veil with soft holes punched at each light. ---
    canvas.saveLayer(rect, Paint());
    canvas.drawRect(rect, Paint()..color = ambient);
    for (final light in lights) {
      final c = light.lightWorldPosition.toOffset();
      final r = light.lightRadius;
      final reveal = Paint()
        ..blendMode = BlendMode.dstOut
        ..shader = Gradient.radial(c, r, [
          const Color(0xFFFFFFFF).withValues(alpha: (0.95 * light.lightIntensity).clamp(0.0, 1.0)),
          const Color(0x66FFFFFF),
          const Color(0x00FFFFFF),
        ], const [0.0, 0.55, 1.0]);
      canvas.drawCircle(c, r, reveal);
    }
    canvas.restore();

    // --- Pass 2: additive coloured glow for atmosphere. ---
    for (final light in lights) {
      final c = light.lightWorldPosition.toOffset();
      final r = light.lightRadius * 0.85;
      final glow = Paint()
        ..blendMode = BlendMode.plus
        ..shader = Gradient.radial(c, r, [
          light.lightColor.withValues(alpha: 0.22 * light.lightIntensity),
          light.lightColor.withValues(alpha: 0.0),
        ]);
      canvas.drawCircle(c, r, glow);
    }
  }
}
