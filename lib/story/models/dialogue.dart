import 'package:flutter/material.dart';

import '../../core/palette.dart';

/// Which sibling a piece of content belongs to (drives art + colour).
enum Character { kade, aria }

/// A character (or narrator) who can speak a [DialogueLine].
@immutable
class Speaker {
  const Speaker(this.name, {this.color = NeonPalette.textBright, this.italic = false});

  final String name;
  final Color color;

  /// Narration / internal-thought speakers render in italics.
  final bool italic;
}

/// Pre-defined speakers used across the screenplay.
abstract final class Speakers {
  static const Speaker narrator = Speaker('', color: NeonPalette.textDim, italic: true);
  static const Speaker kade = Speaker('KADE', color: NeonPalette.kadePrimary);
  static const Speaker aria = Speaker('ARIA', color: NeonPalette.ariaPrimary);
  static const Speaker youngAria = Speaker('ARIA (young)', color: NeonPalette.ariaSecondary);
  static const Speaker youngKade = Speaker('KADE (young)', color: NeonPalette.kadeSecondary);
  static const Speaker echo = Speaker('ECHO', color: NeonPalette.signalGreen);
  static const Speaker pix = Speaker('PIX', color: NeonPalette.amber);
  static const Speaker vex = Speaker('VEX', color: NeonPalette.hollowRed);
}

/// A single line of spoken or narrated text.
@immutable
class DialogueLine {
  const DialogueLine(this.speaker, this.text);
  final Speaker speaker;
  final String text;
}

/// The visual / emotional register of a cutscene, used by the overlay to pick
/// its background treatment.
enum CutsceneMood {
  /// Present-day, tense, blue/cyan.
  present,

  /// Warm magenta flashback to the happy past.
  flashback,

  /// Red, high-tension cliffhanger ending.
  cliffhanger,

  /// Golden dawn resolution.
  victory,
}

/// A scripted, non-interactive story beat shown as a Flutter overlay.
@immutable
class Cutscene {
  const Cutscene({
    required this.title,
    required this.location,
    required this.mood,
    this.narration = const [],
    this.lines = const [],
    this.continueLabel = 'CONTINUE',
  });

  /// e.g. `EPISODE 1` or `FLASHBACK`.
  final String title;

  /// e.g. `LOWTOWN · RAIN`.
  final String location;

  final CutsceneMood mood;

  /// Narration paragraphs shown above the dialogue.
  final List<String> narration;

  /// Spoken lines, revealed one at a time.
  final List<DialogueLine> lines;

  final String continueLabel;
}
