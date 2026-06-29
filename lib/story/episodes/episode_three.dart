import '../models/dialogue.dart';
import '../models/episode.dart';
import '../models/level_config.dart';

/// Episode 3 — "The Drowned District".
/// The Sunken District · Swimming + Climbing · Kade, then young Aria (flashback).
Episode buildEpisodeThree() {
  return const Episode(
    number: 3,
    title: 'The Drowned District',
    tagline: 'THE SUNKEN DISTRICT · SWIM · CLIMB',
    theme: DistrictTheme.sunken,
    phases: [
      CutscenePhase(
        Cutscene(
          title: 'EPISODE 3',
          location: 'THE SUNKEN DISTRICT · UNDERWATER',
          mood: CutsceneMood.present,
          narration: [
            'Kade surfaces in a drowned street, neon signs flickering underwater '
                'like dying fish. The Drowned Cathedral rises out of the flood '
                'ahead — The Hollow’s processing site.',
            'His shorted deck sputters one last line before it dies.',
          ],
          lines: [
            DialogueLine(Speakers.echo,
                'Almost here. The lab’s below the waterline — swim the nave, climb '
                'the bell-rigging to the cells. Hurry. They moved the clock up.'),
            DialogueLine(Speakers.kade, '(takes a breath) Don’t lose the coin, dummy. Down we go.'),
          ],
          continueLabel: 'DIVE',
        ),
      ),
      LevelPhase(_drownedNave),
      CutscenePhase(
        Cutscene(
          title: 'FLASHBACK',
          location: 'THE RESERVOIR · BEFORE THE DAM',
          mood: CutsceneMood.flashback,
          narration: [
            'Years ago, the water here was clean and blue. Aria — the better '
                'swimmer — is teaching a nervous little Kade to dive.',
          ],
          lines: [
            DialogueLine(Speakers.youngAria, 'See? The water’s not scary. It just wants you to trust it.'),
            DialogueLine(Speakers.youngKade, 'Easy for you. You’re part fish.'),
            DialogueLine(Speakers.youngAria, 'Dive for the lucky coin. Keep it. Don’t lose it, dummy.'),
            DialogueLine(Speakers.narrator, 'You are Aria. Dive deep and bring back the coin.'),
          ],
          continueLabel: 'PLAY AS ARIA',
        ),
      ),
      LevelPhase(_reservoirFlashback),
      CutscenePhase(
        Cutscene(
          title: 'EPISODE 3 — ENDING',
          location: 'THE HOLDING CELLS',
          mood: CutsceneMood.cliffhanger,
          narration: [
            'Aria’s cell door hangs open. Empty. Inside: her jacket, folded '
                'neatly, and a recorder still blinking. Kade plays it — and for '
                'the first time hears HER voice. Not Echo’s. They are the same.',
          ],
          lines: [
            DialogueLine(Speakers.aria,
                'Kade. If you’re hearing this, you got my messages. I’m “Echo.” '
                'It was always me.'),
            DialogueLine(Speakers.aria,
                'I didn’t run from you — I ran to keep them away from you. I found '
                'what really happened to Mom and Dad. Halcyon did it. And I can prove it.'),
            DialogueLine(Speakers.aria,
                'I broke out. I’m going to the Spire to upload everything and burn '
                'The Hollow to the ground. If I don’t make it — finish it for me. I lo—'),
            DialogueLine(Speakers.narrator, 'Static. A single gunshot. Then nothing.'),
            DialogueLine(Speakers.kade, 'Echo was you. It was always you. The Spire, then. The top of the world.'),
          ],
          continueLabel: 'EPISODE 4 ▶',
        ),
      ),
    ],
  );
}

const LevelConfig _drownedNave = LevelConfig(
  id: 'ep3_drowned_nave',
  character: Character.kade,
  theme: DistrictTheme.sunken,
  mechanics: {MechanicType.swim, MechanicType.climb},
  objective: 'Swim the flooded nave, then climb to the holding cells',
  bannerLine: 'Watch your breath — grab air pockets · climb the rigging up top.',
  worldWidth: 124,
  worldHeight: 40,
  start: Pt(6, 11),
  goal: Pt(110, 1),
  goalLabel: 'THE HOLDING CELLS',
  waters: [
    WaterZone(x: 0, y: 6, width: 124, height: 34),
  ],
  platforms: [
    Platform(x: 0, y: 36, width: 124, height: 4), // drowned street floor
    Platform(x: 26, y: 14, width: 4, height: 22), // submerged columns
    Platform(x: 48, y: 10, width: 4, height: 26),
    Platform(x: 72, y: 16, width: 4, height: 20),
    Platform(x: 96, y: 2, width: 22, height: 2), // the cells ledge (above water)
  ],
  ladders: [
    Ladder(x: 100, y: 1, width: 2.6, height: 27), // the bell-rigging up out of the water
  ],
  hazards: [
    Hazard(x: 36, y: 30, width: 10, height: 4), // electrified wreck on the floor
    Hazard(x: 60, y: 24, width: 8, height: 3),
  ],
  enemies: [
    EnemySpawn(EnemyKind.drone, x: 40, y: 14),
    EnemySpawn(EnemyKind.drone, x: 80, y: 13),
  ],
  pickups: [
    PickupSpawn(PickupKind.air, x: 20, y: 12),
    PickupSpawn(PickupKind.air, x: 56, y: 14),
    PickupSpawn(PickupKind.air, x: 84, y: 12),
    PickupSpawn(PickupKind.marker, x: 110, y: 1, note: 'Her cell. The door is already open…'),
  ],
);

const LevelConfig _reservoirFlashback = LevelConfig(
  id: 'ep3_reservoir_flashback',
  character: Character.aria,
  theme: DistrictTheme.reservoir,
  mechanics: {MechanicType.swim, MechanicType.climb},
  flashback: true,
  objective: 'Dive for the lucky coin, then climb out',
  bannerLine: 'Dive deep. Trust the water.',
  worldWidth: 76,
  worldHeight: 32,
  start: Pt(6, 9),
  goal: Pt(66, 7),
  goalLabel: 'THE JETTY',
  waters: [
    WaterZone(x: 0, y: 5, width: 76, height: 27),
  ],
  platforms: [
    Platform(x: 0, y: 28, width: 76, height: 4),
    Platform(x: 60, y: 9, width: 14, height: 2), // the jetty
  ],
  ladders: [
    Ladder(x: 62, y: 8, width: 2.4, height: 18),
  ],
  pickups: [
    PickupSpawn(PickupKind.coin, x: 38, y: 24, note: 'The lucky coin! Aria surfaces grinning, holding it high.'),
    PickupSpawn(PickupKind.air, x: 24, y: 11),
    PickupSpawn(PickupKind.air, x: 50, y: 12),
  ],
);
