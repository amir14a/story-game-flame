import 'package:flutter/material.dart';

import '../../core/palette.dart';

/// Which sibling a piece of content belongs to (drives art + colour).
enum Character { james, millie }

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
  static const Speaker james = Speaker('JAMES', color: NeonPalette.jamesPrimary);
  static const Speaker millie = Speaker('MILLIE', color: NeonPalette.milliePrimary);
  static const Speaker youngMillie = Speaker('MILLIE (young)', color: NeonPalette.millieSecondary);
  static const Speaker youngJames = Speaker('JAMES (young)', color: NeonPalette.jamesSecondary);
  static const Speaker books = Speaker('BOOKS', color: NeonPalette.books);
  static const Speaker cray = Speaker('CRAY', color: NeonPalette.cray);
  static const Speaker saint = Speaker('SAINT', color: NeonPalette.saint);
  static const Speaker mara = Speaker('MARA', color: NeonPalette.millieSecondary, italic: true);
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

/// A scripted, full-screen story beat shown as a Flutter overlay between
/// playable phases (episode intro / flashback intro / cliffhanger / finale).
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

  final String title;
  final String location;
  final CutsceneMood mood;
  final List<String> narration;
  final List<DialogueLine> lines;
  final String continueLabel;
}
