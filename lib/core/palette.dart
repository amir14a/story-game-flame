import 'package:flutter/material.dart';

/// The neon colour system for the whole game.
///
/// Kept in one place so the cyberpunk look is consistent across the engine art
/// and the Flutter overlays.
abstract final class NeonPalette {
  // Backdrop / atmosphere.
  static const Color voidBlack = Color(0xFF05060E);
  static const Color deepNight = Color(0xFF0B0F2A);
  static const Color midnight = Color(0xFF131A3A);
  static const Color hazePurple = Color(0xFF2A1B4A);

  // Primary neon accents.
  static const Color cyan = Color(0xFF21F3FF);
  static const Color magenta = Color(0xFFFF2BD6);
  static const Color violet = Color(0xFF9B5BFF);
  static const Color hotPink = Color(0xFFFF4D8D);
  static const Color limeGlow = Color(0xFF8BFF3D);
  static const Color amber = Color(0xFFFFB23D);
  static const Color danger = Color(0xFFFF3B5C);
  static const Color signalGreen = Color(0xFF38FFA3);

  // Characters.
  static const Color kadePrimary = Color(0xFF21F3FF); // cyan
  static const Color kadeSecondary = Color(0xFF1B6CFF);
  static const Color ariaPrimary = Color(0xFFFF2BD6); // magenta
  static const Color ariaSecondary = Color(0xFFFF8AE0);

  // Hostiles.
  static const Color hollowRed = Color(0xFFFF2E4D);
  static const Color hollowSteel = Color(0xFF3A4666);

  // Water (Sunken District).
  static const Color waterDeep = Color(0xFF06243A);
  static const Color waterMid = Color(0xFF0B4E73);
  static const Color waterGlow = Color(0xFF1FD3FF);

  // UI text.
  static const Color textBright = Color(0xFFEAF6FF);
  static const Color textDim = Color(0xFF8FA3C8);

  /// A vertical neon gradient used for skies / panels.
  static const LinearGradient nightSky = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [voidBlack, deepNight, hazePurple],
    stops: [0.0, 0.55, 1.0],
  );

  /// The signature cyan→magenta sweep used on titles and key art.
  static const LinearGradient duotone = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [cyan, violet, magenta],
  );
}
