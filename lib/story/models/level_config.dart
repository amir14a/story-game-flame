import 'dialogue.dart';

/// A 2D point in world metres. A tiny value type so the story package stays
/// independent of Flame's `Vector2`.
class Pt {
  const Pt(this.x, this.y);
  final double x;
  final double y;
}

/// The set of mechanics a level enables. An on-foot actor turns the matching
/// locomotion mixins on/off from this set; vehicles are chosen via [VehicleKind].
enum MechanicType { run, parkour, drive, bike, swim, climb, shoot }

/// What body the player drives in a level.
enum VehicleKind { onFoot, car, bike }

/// District look used by the backdrop / parallax painter.
enum DistrictTheme { rooftops, skyway, sunken, steelVeins, spire, reservoir, lowtownNight }

// ---------------------------------------------------------------------------
// Terrain features — declarative building blocks turned into static bodies.
// ---------------------------------------------------------------------------

/// A continuous ground profile (turned into a Forge2D chain shape). Points run
/// left→right; great for hills and gaps in driving / riding levels.
class GroundProfile {
  const GroundProfile(this.points, {this.friction = 0.7});
  final List<Pt> points;
  final double friction;
}

/// A solid rectangular platform. [x],[y] is the top-left corner; the top
/// surface sits at [y].
class Platform {
  const Platform({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.friction = 0.8,
  });
  final double x;
  final double y;
  final double width;
  final double height;
  final double friction;
}

/// A vertical surface the player can wall-slide / wall-jump against.
class Wall {
  const Wall({required this.x, required this.y, required this.width, required this.height});
  final double x;
  final double y;
  final double width;
  final double height;
}

/// A climbable zone (ladder, rigging, vines). Sensor only.
class Ladder {
  const Ladder({required this.x, required this.y, required this.width, required this.height});
  final double x;
  final double y;
  final double width;
  final double height;
}

/// A body of water. [y] is the surface height; the zone extends down by
/// [height]. Sensor that enables swimming.
class WaterZone {
  const WaterZone({required this.x, required this.y, required this.width, required this.height});
  final double x;
  final double y;
  final double width;
  final double height;
}

/// A deadly region (electrified pool, exposed gap, crusher). Touching it costs a
/// life / restarts the checkpoint.
class Hazard {
  const Hazard({required this.x, required this.y, required this.width, required this.height});
  final double x;
  final double y;
  final double width;
  final double height;
}

// ---------------------------------------------------------------------------
// Entities.
// ---------------------------------------------------------------------------

enum EnemyKind {
  /// Walks a patrol on the ground, melee on contact.
  grunt,

  /// Hovers and fires the occasional shot; appears in chases.
  drone,

  /// A Hollow motorcyclist that chases in the bike level.
  rider,
}

class EnemySpawn {
  const EnemySpawn(this.kind, {required this.x, required this.y, this.patrol = 4.0});
  final EnemyKind kind;
  final double x;
  final double y;

  /// Horizontal patrol half-range in metres (for grunts).
  final double patrol;
}

enum PickupKind {
  /// Refills the breath meter while swimming.
  air,

  /// Aria's "lucky coin" — the Episode 3 flashback collectible.
  coin,

  /// A glowing objective marker / clue.
  marker,
}

class PickupSpawn {
  const PickupSpawn(this.kind, {required this.x, required this.y, this.note});
  final PickupKind kind;
  final double x;
  final double y;

  /// Optional one-line story note shown when collected.
  final String? note;
}

// ---------------------------------------------------------------------------
// In-game narrative.
// ---------------------------------------------------------------------------

/// A story character the player can meet inside a level (Books, Cray, Saint, or
/// Millie). Drives the figure's art and the face-to-face exchange.
enum NpcKind { books, cray, saint, millie }

/// An invisible zone that fires a dialogue sequence the first time the player
/// crosses it. Non-[blocking] lines show as ambient subtitles while play
/// continues; [blocking] lines pop up a comm card and soft-pause the action.
class DialogueTrigger {
  const DialogueTrigger({
    required this.x,
    required this.lines,
    this.width = 2.5,
    this.blocking = false,
  });
  final double x;
  final double width;
  final List<DialogueLine> lines;
  final bool blocking;
}

/// A character standing in the level. Reaching them triggers a (blocking)
/// face-to-face meeting.
class NpcSpawn {
  const NpcSpawn(
    this.kind, {
    required this.x,
    required this.y,
    this.lines = const [],
    this.facing = -1,
  });
  final NpcKind kind;
  final double x;
  final double y;
  final List<DialogueLine> lines;
  final int facing;
}

// ---------------------------------------------------------------------------
// The level itself.
// ---------------------------------------------------------------------------

/// A fully declarative description of one playable level. The engine's
/// `LevelScene` knows how to render and simulate any [LevelConfig]; the story
/// package only describes them.
class LevelConfig {
  const LevelConfig({
    required this.id,
    required this.character,
    required this.theme,
    required this.mechanics,
    required this.objective,
    required this.worldWidth,
    required this.worldHeight,
    required this.start,
    required this.goal,
    this.vehicle = VehicleKind.onFoot,
    this.flashback = false,
    this.goalLabel = 'GOAL',
    this.grounds = const [],
    this.platforms = const [],
    this.walls = const [],
    this.ladders = const [],
    this.waters = const [],
    this.hazards = const [],
    this.enemies = const [],
    this.pickups = const [],
    this.checkpoints = const [],
    this.dialogueTriggers = const [],
    this.npcs = const [],
    this.killY,
    this.bannerLine,
  });

  final String id;
  final Character character;
  final DistrictTheme theme;
  final Set<MechanicType> mechanics;
  final VehicleKind vehicle;

  /// HUD objective text.
  final String objective;

  /// Whether this level is a memory (changes lighting + HUD tint).
  final bool flashback;

  /// World extents in metres (camera bounds; water depth uses [worldHeight]).
  final double worldWidth;
  final double worldHeight;

  final Pt start;

  /// Centre of the goal trigger box the player must reach to clear the level.
  final Pt goal;
  final String goalLabel;

  final List<GroundProfile> grounds;
  final List<Platform> platforms;
  final List<Wall> walls;
  final List<Ladder> ladders;
  final List<WaterZone> waters;
  final List<Hazard> hazards;
  final List<EnemySpawn> enemies;
  final List<PickupSpawn> pickups;

  /// Respawn points (metres). On death the player returns to the last one
  /// passed, instead of restarting the whole — possibly 10-minute — level.
  final List<Pt> checkpoints;

  /// In-game dialogue zones and meet-able characters.
  final List<DialogueTrigger> dialogueTriggers;
  final List<NpcSpawn> npcs;

  /// Anything that falls below this world-Y is reliably killed (a death plane).
  /// Defaults to a little past [worldHeight] when null.
  final double? killY;

  /// Optional short line shown on the in-level intro banner.
  final String? bannerLine;

  double get deathPlaneY => killY ?? worldHeight + 6;

  bool has(MechanicType m) => mechanics.contains(m);
}
