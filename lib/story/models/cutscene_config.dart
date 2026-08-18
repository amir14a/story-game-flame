import 'dialogue.dart';
import 'level_config.dart';

// ---------------------------------------------------------------------------
// Beat types — the scripted actions that play out inside a CutsceneScene.
// ---------------------------------------------------------------------------

/// A single scripted action within an in-game cutscene. Beats are played in
/// order; each beat completes (either by finishing its animation or by its
/// duration elapsing) before the next one starts.
sealed class CutsceneBeat {
  const CutsceneBeat();
}

/// Show a dialogue line as a subtitle at the bottom of the screen.
class DialogueBeat extends CutsceneBeat {
  const DialogueBeat(this.line);
  final DialogueLine line;
}

/// Show a narration / internal-thought line as an italic subtitle.
class NarrationBeat extends CutsceneBeat {
  const NarrationBeat(this.text);
  final String text;
}

/// Pause for a fixed number of seconds before the next beat.
class PauseBeat extends CutsceneBeat {
  const PauseBeat(this.duration);
  final double duration;
}

/// Move a character to a target position with a given pose. The character
/// walks/runs there; the beat completes when the character arrives.
class MoveCharacterBeat extends CutsceneBeat {
  const MoveCharacterBeat(
    this.character, {
    required this.targetX,
    required this.targetY,
    this.pose = CharacterPose.run,
    this.speed = 6.0,
  });
  final Character character;
  final double targetX;
  final double targetY;
  final CharacterPose pose;
  final double speed;
}

/// Make a character face a direction without moving.
class LookAtBeat extends CutsceneBeat {
  const LookAtBeat(this.character, {required this.facing});
  final Character character;
  final int facing; // -1 = left, 1 = right
}

/// Change a character's pose (e.g. from run to idle, or to aim).
class PoseBeat extends CutsceneBeat {
  const PoseBeat(this.character, {required this.pose});
  final Character character;
  final CharacterPose pose;
}

// ---------------------------------------------------------------------------
// CutsceneConfig — the full description of an in-game cutscene.
// ---------------------------------------------------------------------------

/// A scripted, unplayable cutscene that renders characters and dialogue
/// inside the Flame game world (not as a Flutter overlay).
class CutsceneConfig {
  const CutsceneConfig({
    required this.title,
    required this.location,
    required this.mood,
    required this.theme,
    required this.beats,
    this.worldWidth = 40,
    this.continueLabel = 'CONTINUE',
  });

  final String title;
  final String location;
  final CutsceneMood mood;
  final DistrictTheme theme;

  /// The world width in metres (camera bounds). The height is derived to fill
  /// the viewport proportionally.
  final double worldWidth;

  /// The ordered sequence of beats that play out.
  final List<CutsceneBeat> beats;

  /// Label on the continue button shown after all beats finish.
  final String continueLabel;
}
