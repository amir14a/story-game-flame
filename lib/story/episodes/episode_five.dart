import '../models/dialogue.dart';
import '../models/episode.dart';
import '../models/level_config.dart';

/// Episode 5 — "The Spire".
/// The Spire · Climbing + Parkour + Shooting · Kade (with a brief Aria flashback).
Episode buildEpisodeFive() {
  return const Episode(
    number: 5,
    title: 'The Spire',
    tagline: 'THE SPIRE · CLIMB · PARKOUR · SHOOT',
    theme: DistrictTheme.spire,
    phases: [
      CutscenePhase(
        Cutscene(
          title: 'EPISODE 5',
          location: 'INSIDE THE SPIRE',
          mood: CutsceneMood.present,
          narration: [
            'Every floor is a war. Aria is somewhere above, racing the same clock, '
                'trying to reach the data-core at the summit before The Hollow stops her.',
          ],
          lines: [
            DialogueLine(Speakers.aria,
                'Kade?? You’re IN the building? You absolute — okay. OKAY. Get to '
                'the top. The core’s at the summit.'),
            DialogueLine(Speakers.aria, 'We finish this together or not at all.'),
            DialogueLine(Speakers.kade, 'Took the words right out of my mouth. Don’t you dare move.'),
          ],
          continueLabel: 'REMEMBER',
        ),
      ),
      CutscenePhase(
        Cutscene(
          title: 'FLASHBACK',
          location: 'LOWTOWN ROOFTOP · THE PROMISE',
          mood: CutsceneMood.flashback,
          narration: [
            'As he climbs, the old promise flickers through — two kids, legs over '
                'the edge of Lowtown.',
          ],
          lines: [
            DialogueLine(Speakers.youngAria,
                'If we ever get lost — really lost — climb to the top of the world. '
                'The Spire. I’ll find you there.'),
            DialogueLine(Speakers.youngKade, 'That’s the dumbest plan I ever heard.'),
            DialogueLine(Speakers.youngAria, 'It’s a great plan. Pinky. Promise.'),
            DialogueLine(Speakers.narrator, 'You are Aria. Walk out to the edge and seal the promise.'),
          ],
          continueLabel: 'PLAY AS ARIA',
        ),
      ),
      LevelPhase(_promiseFlashback),
      CutscenePhase(
        Cutscene(
          title: 'THE CLIMB',
          location: 'THE SPIRE · ASCENDING',
          mood: CutsceneMood.present,
          narration: [
            'Back to now. The promise and the climb become the same motion. The '
                'city falls away beneath you into a sea of light.',
          ],
          lines: [
            DialogueLine(Speakers.narrator,
                'Climb the rigging, wall-jump the shafts, and shoot through The '
                'Hollow. Reach the summit.'),
          ],
          continueLabel: 'CLIMB TO THE TOP OF THE WORLD',
        ),
      ),
      LevelPhase(_spireAscent),
      CutscenePhase(
        Cutscene(
          title: 'THE TOP OF THE WORLD',
          location: 'THE SUMMIT DATA-CORE · DAWN',
          mood: CutsceneMood.victory,
          narration: [
            'Kade reaches the summit as dawn cracks the horizon. And there she is. '
                'Aria. Thinner, scarred — alive. For a moment, neither of them moves.',
          ],
          lines: [
            DialogueLine(Speakers.aria, '…You actually climbed to the top of the world.'),
            DialogueLine(Speakers.kade, 'You said you’d find me here. Figured I’d save you the walk.'),
            DialogueLine(Speakers.narrator,
                'Together they hold Vex off long enough to slam the upload home. '
                'Halcyon’s crimes flood every screen in Nyx City at once. The '
                'Hollow’s grip breaks.'),
            DialogueLine(Speakers.aria, 'Mom and Dad. Everyone. They’ll know now.'),
            DialogueLine(Speakers.kade, 'Yeah. They will. …Don’t ever disappear on me again.'),
            DialogueLine(Speakers.aria, 'Deal. Pinky promise.'),
          ],
          continueLabel: 'THE END',
        ),
      ),
    ],
  );
}

const LevelConfig _promiseFlashback = LevelConfig(
  id: 'ep5_promise_flashback',
  character: Character.aria,
  theme: DistrictTheme.lowtownNight,
  mechanics: {MechanicType.run},
  flashback: true,
  objective: 'Walk out to the edge',
  bannerLine: 'No rush. Some promises you walk to.',
  worldWidth: 44,
  worldHeight: 22,
  start: Pt(4, 11),
  goal: Pt(38, 11),
  goalLabel: 'THE EDGE',
  hazards: [
    Hazard(x: 0, y: 21, width: 44, height: 1),
  ],
  platforms: [
    Platform(x: 0, y: 14, width: 40, height: 8),
  ],
  pickups: [
    PickupSpawn(PickupKind.marker, x: 38, y: 11, note: '“Pinky. Promise.” Two small hands hook together over a sea of neon.'),
  ],
);

const LevelConfig _spireAscent = LevelConfig(
  id: 'ep5_spire_ascent',
  character: Character.kade,
  theme: DistrictTheme.spire,
  mechanics: {MechanicType.climb, MechanicType.parkour, MechanicType.shoot},
  objective: 'Ascend the Spire to the summit data-core',
  bannerLine: 'Climb ladders · wall-jump the shafts · B / J shoots.',
  worldWidth: 60,
  worldHeight: 122,
  start: Pt(8, 107),
  goal: Pt(30, 9),
  goalLabel: 'THE SUMMIT',
  platforms: [
    Platform(x: 0, y: 110, width: 60, height: 12), // ground floor
    Platform(x: 0, y: 92, width: 26, height: 2),
    Platform(x: 30, y: 72, width: 30, height: 2),
    Platform(x: 34, y: 52, width: 26, height: 2),
    Platform(x: 6, y: 44, width: 16, height: 2),
    Platform(x: 0, y: 34, width: 20, height: 2),
    Platform(x: 0, y: 12, width: 60, height: 2), // summit
  ],
  ladders: [
    Ladder(x: 10, y: 91, width: 2.6, height: 21),
    Ladder(x: 50, y: 51, width: 2.6, height: 23),
    Ladder(x: 14, y: 13, width: 2.6, height: 23),
  ],
  walls: [
    Wall(x: 34, y: 72, width: 1.6, height: 20), // wall-jump shaft between F1 and F2
    Wall(x: 42, y: 72, width: 1.6, height: 20),
  ],
  enemies: [
    EnemySpawn(EnemyKind.grunt, x: 18, y: 90, patrol: 6),
    EnemySpawn(EnemyKind.drone, x: 40, y: 62),
    EnemySpawn(EnemyKind.grunt, x: 46, y: 50, patrol: 6),
    EnemySpawn(EnemyKind.drone, x: 10, y: 26),
    EnemySpawn(EnemyKind.grunt, x: 40, y: 10, patrol: 8),
  ],
  pickups: [
    PickupSpawn(PickupKind.marker, x: 46, y: 70, note: 'Halcyon security logs — every crime, time-stamped. Aria was right.'),
    PickupSpawn(PickupKind.marker, x: 30, y: 10, note: 'The summit. The data-core. And a silhouette you’d know anywhere.'),
  ],
);
