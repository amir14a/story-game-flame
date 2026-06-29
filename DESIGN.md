# NEON ECHO — Technical Design

This document describes how the code is organised and why. The guiding principles
are **clean OOP** and **data-driven content**: the *engine* knows how to play a
level, the *story package* describes *which* levels exist and what they contain,
and the two never bleed into each other.

## High-level flow

```
main.dart ─ lock landscape ─▶ NeonEchoApp (MaterialApp)
                                   │
                                   ▼
                           GameWidget<NeonEchoGame>
                          ┌────────┴─────────┐
                          │   overlays map   │  Flutter widgets:
                          │  (ui/overlays)   │  menu, cutscene, HUD,
                          └────────┬─────────┘  pause, endings
                                   ▼
                           NeonEchoGame  (Forge2DGame)
                          ┌────────┴───────────────────────┐
                          │ GameState   – progress/health   │
                          │ GameInput   – keyboard + touch  │
                          │ StoryDirector – runs the script │
                          └────────┬───────────────────────┘
                                   ▼
                       active Forge2DWorld == a LevelScene
                          (built from a LevelConfig)
                          ┌────────┴───────────────────────┐
                          │ terrain bodies · actor · enemies│
                          │ pickups · goal · backdrop · FX  │
                          └─────────────────────────────────┘
```

## Packages / folders

### `core/`
Pure, dependency-light foundations.

* `palette.dart` — the neon colour system (`NeonPalette`) used everywhere.
* `game_config.dart` — tuning constants: gravity, pixels-per-metre/zoom, movement
  speeds, jump impulses, buoyancy, breath, fire-rate, etc.
* `input/game_input.dart` — `GameInput`, a single mutable input snapshot
  (`moveX`, `up`, `down`, `jumpPressed`, `firePressed`, …). Both the keyboard
  handler and the on-screen joystick/buttons write into it; actors only read it.
  This decouples *how* input arrives from *what* the actor does.

### `story/` — the screenplay, as data
No Flame/physics imports. This is the script.

* `models/` — immutable data classes:
  * `Speaker`, `DialogueLine`
  * `CutsceneBeat`, `Cutscene` (a titled sequence of narration + dialogue + a mood)
  * `MechanicType` (`run`, `parkour`, `drive`, `bike`, `swim`, `climb`, `shoot`)
  * `Character` (`kade` / `aria`) and `DistrictTheme`
  * `LevelConfig` — a fully declarative level: terrain features, entities, the
    playable character, enabled mechanics, start/goal, theme and a HUD objective.
  * `Episode`, `StoryPhase` (`CutscenePhase` | `LevelPhase`) — an episode is just
    an ordered list of phases.
* `story_repository.dart` + `episodes/episode_one..five.dart` — the actual content:
  every cutscene, every line of dialogue, and every `LevelConfig` for the present
  and flashback levels.

Because levels are *data*, adding or tuning a level never touches engine code.

### `engine/`
The Flame runtime.

* `neon_echo_game.dart` — `NeonEchoGame extends Forge2DGame`. Owns `GameState`,
  `GameInput`, the `StoryDirector`, and the on-screen controls. Routes keyboard
  events into `GameInput`. Exposes `startEpisode`, `advance`, `restartLevel`.
* `game_state.dart` — progress (episode/phase index, unlocked episodes), the active
  character, and the player's health/breath for the HUD.
* `story_director.dart` — interprets the current `StoryPhase`: shows the right
  cutscene overlay, or swaps in a `LevelScene` for a `LevelPhase`, and advances
  when a phase reports completion.
* `controls.dart` — builds the in-engine joystick + A/B/pause buttons into the
  camera viewport and feeds `GameInput`.
* `scenes/level_scene.dart` — `LevelScene extends Forge2DWorld`. Given a
  `LevelConfig` it builds the terrain bodies, the actor (on foot / car / bike),
  enemies, pickups and the goal sensor, then wires the camera to follow and
  bounds it. The `CityBackdrop` is owned by the camera and just re-themed per
  scene.
* `scenes/terrain.dart` — the static terrain bodies: `PlatformBody`/walls,
  `GroundBody` (chain), `LadderBody`, `WaterBody`, `HazardBody` and `GoalBody`,
  each rendering its own neon vector art.

### `actors/`
Everything that has a physics `Body`.

* `player_actor.dart` — `PlayerActor`, the on-foot body (Kade or Aria). Its
  locomotion is split into clearly separated behaviours — ground running +
  jumping, parkour wall-slide/wall-jump, free-swim + breath, ladder climbing
  (velocity-driven so gravity is cancelled while gripping), and fire-rate-gated
  shooting. Which behaviours are *live* is decided by the `LevelConfig.mechanics`
  set, so the same body powers every on-foot level. Ground/wall detection uses
  three dedicated sensor fixtures (foot / left / right) and `ContactCallbacks`.
* `vehicles.dart` — `VehicleActor` (shared throttle/hop/contacts base) plus
  `CarActor` (driving) and `BikeActor` (riding + shooting). A rounded collider
  lets them roll smoothly over the ground chain.
* `markers.dart` — tiny tag types (`SolidTerrain`, `WaterMarker`, `LadderMarker`,
  `HazardMarker`, `GoalMarker`) used as body `userData` for `is`-based contacts.
* `projectile.dart` — `Bullet`, a fast sensor body that damages what it hits.
* `enemy.dart` — `Enemy` with three behaviours (ground grunt, hover drone, rider)
  selected by `EnemyKind`; simple AI + health; uses `ContactCallbacks`.
* `pickup.dart` — sensor pickups (breath/air, the "lucky coin", clue markers).

### `art/`
All visuals are vector, drawn directly to the `Canvas`.

* `neon.dart` — reusable neon primitives: glowing strokes, fills with bloom,
  gradient skies, scanlines.
* `character_art.dart` — `CharacterArtist` draws the figures as clean vector
  forms with neon rim-light, posed from a few animation params. Kade and Aria
  have **distinct silhouettes** (a per-character `_Build`): Kade is taller and
  broad-shouldered with cropped hair, a hood collar and a courier satchel; Aria
  is slighter with a pinched waist, a fringe, a long swaying ponytail, a tunic
  hem and a hip data-deck.
* `vehicle_art.dart` — car and motorcycle vector art.
* `lighting.dart` — the `LightEmitter` mixin and `LightingLayer`: a real 2D
  lighting pass. It lays a per-district ambient "night" veil over the visible
  world (lighter in flashbacks), carves soft pools of visibility out of it at
  every emitter via `BlendMode.dstOut`, then adds an additive coloured cast.
  The player, enemies, pickups, the goal beacon and vehicle headlamps all emit
  light.
* `city/` — `CityBackdrop` (multi-layer parallax skyline per `DistrictTheme`,
  plus rain, stars, underwater caustics/bubbles and a vignette).

Actors draw their own art in `render()` (the Forge2D `BodyComponent` canvas is in
world/metre units, centred on the body), so the figures track physics exactly.
The `LightingLayer` is added last in each scene so it composites over everything.

### `ui/`
Flutter overlays registered in `GameWidget.overlayBuilderMap`.

* `widgets/` — `NeonScaffold` (animated cyberpunk `CustomPaint` background used by
  every overlay), `NeonButton`, `TypingText` (typewriter dialogue), `GlitchTitle`.
* `screens/` — `MainMenuOverlay`, `EpisodeSelectOverlay`, `CutsceneOverlay`
  (intro / flashback / cliffhanger), `HudOverlay` (health, breath, objective,
  episode banner), `PauseOverlay`, `LevelClearedOverlay`, `GameOverOverlay`,
  `VictoryOverlay`.

## Coordinate system & camera

Forge2D works in metres; the camera zoom (`GameConfig.zoom`) maps metres to pixels.
Levels are laid out left-to-right in metres. The camera `follow`s the actor with a
small vertical lead and is `setBounds` to the level extents so it never shows past
the world edges.

## Why this shape

* **Separation of concerns** — story content has zero engine dependencies, so the
  whole game can be re-scripted by editing `story/`.
* **Open/closed** — new mechanics are new mixins; new levels are new `LevelConfig`s;
  neither forces edits to existing classes.
* **Single source of input truth** — `GameInput` means keyboard and touch are
  interchangeable and actors never care which one is driving.
* **No assets** — procedural vector art keeps the build tiny and crisp, and keeps
  art logic testable as plain Dart.
