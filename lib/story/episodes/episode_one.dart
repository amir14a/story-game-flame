import '../models/dialogue.dart';
import '../models/episode.dart';
import '../models/level_config.dart';

/// Episode 1 — "Signal in the Rain".
/// Lowtown rooftops · Running + Parkour · Kade, then young Aria (flashback).
Episode buildEpisodeOne() {
  return const Episode(
    number: 1,
    title: 'Signal in the Rain',
    tagline: 'LOWTOWN ROOFTOPS · RUN · PARKOUR',
    theme: DistrictTheme.rooftops,
    phases: [
      // --- Intro cutscene -------------------------------------------------
      CutscenePhase(
        Cutscene(
          title: 'EPISODE 1',
          location: 'LOWTOWN · RAIN',
          mood: CutsceneMood.present,
          narration: [
            'Rain has been falling on Lowtown for four months. About as long as '
                'Aria has been gone.',
            'Kade Vance still checks his wrist-deck every night. Tonight, for the '
                'first time, it answers.',
          ],
          lines: [
            DialogueLine(Speakers.echo,
                'She’s alive, Kade. The courier on Rivet Row is carrying proof. '
                'Catch him before The Hollow does.'),
            DialogueLine(Speakers.echo, 'RUN.'),
            DialogueLine(Speakers.kade,
                'Four months of nothing. And now a ghost tells me to run.'),
            DialogueLine(Speakers.kade, '…Fine. I run.'),
          ],
          continueLabel: 'CHASE THE COURIER',
        ),
      ),

      // --- Main level: rooftop chase -------------------------------------
      LevelPhase(_rooftopChase),

      // --- Flashback intro -----------------------------------------------
      CutscenePhase(
        Cutscene(
          title: 'FLASHBACK',
          location: 'LOWTOWN ROOFTOPS · SIX YEARS AGO',
          mood: CutsceneMood.flashback,
          narration: [
            'Before the silence. Before The Hollow. Two kids and a whole sky of '
                'neon to run under.',
          ],
          lines: [
            DialogueLine(Speakers.youngAria, 'Can’t catch me, slowpoke!'),
            DialogueLine(Speakers.youngKade, 'Aria, the gap’s too — ARIA!'),
            DialogueLine(Speakers.narrator, 'You are Aria. Chase your brother across the rooftops.'),
          ],
          continueLabel: 'PLAY AS ARIA',
        ),
      ),

      // --- Flashback level: tag on the rooftops --------------------------
      LevelPhase(_tagFlashback),

      // --- Cliffhanger ----------------------------------------------------
      CutscenePhase(
        Cutscene(
          title: 'EPISODE 1 — ENDING',
          location: 'RIVET ROW · THE WATER TOWER',
          mood: CutsceneMood.cliffhanger,
          narration: [
            'Kade corners the courier on the old water tower. The kid is shaking.',
          ],
          lines: [
            DialogueLine(Speakers.pix,
                'I never saw your face, okay? She’s in the Sunken District. '
                'The Hollow’s got her at the Drowned Cathedral.'),
            DialogueLine(Speakers.pix, 'Echo said you’d —'),
            DialogueLine(Speakers.narrator,
                'A red targeting laser blooms across Pix’s chest. A drone-sniper '
                'on a far roof fires once. Pix drops.'),
            DialogueLine(Speakers.narrator,
                'The laser swings up and finds KADE. Alarms tear across Lowtown.'),
            DialogueLine(Speakers.kade,
                '(pockets the shard) Sunken District. Hold on, Aria.'),
          ],
          continueLabel: 'EPISODE 2 ▶',
        ),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Levels
// ---------------------------------------------------------------------------

const LevelConfig _rooftopChase = LevelConfig(
  id: 'ep1_rooftop_chase',
  character: Character.kade,
  theme: DistrictTheme.rooftops,
  mechanics: {MechanicType.run, MechanicType.parkour},
  objective: 'Chase the courier across the Lowtown rooftops',
  bannerLine: 'Catch the courier — don’t let The Hollow reach him first.',
  worldWidth: 142,
  worldHeight: 28,
  start: Pt(4, 9),
  goal: Pt(127, 7),
  goalLabel: 'THE WATER TOWER',
  hazards: [
    Hazard(x: 0, y: 26, width: 142, height: 4), // the fall
  ],
  platforms: [
    Platform(x: 0, y: 12, width: 16, height: 14),
    Platform(x: 22, y: 11, width: 11, height: 15),
    Platform(x: 38, y: 13, width: 9, height: 13),
    Platform(x: 52, y: 10, width: 9, height: 16),
    Platform(x: 67, y: 8, width: 11, height: 18),
    Platform(x: 83, y: 12, width: 13, height: 14),
    Platform(x: 101, y: 10, width: 10, height: 16),
    Platform(x: 116, y: 9, width: 20, height: 17),
  ],
  walls: [
    Wall(x: 64.0, y: 1, width: 1.6, height: 9), // parkour pillar before the high roof
    Wall(x: 99.0, y: 2, width: 1.6, height: 8),
  ],
  enemies: [
    EnemySpawn(EnemyKind.drone, x: 30, y: 6),
    EnemySpawn(EnemyKind.grunt, x: 88, y: 11, patrol: 4),
    EnemySpawn(EnemyKind.drone, x: 108, y: 5),
  ],
  pickups: [
    PickupSpawn(PickupKind.marker, x: 40, y: 11,
        note: 'A dropped data-chip. Echo’s signature is all over it.'),
    PickupSpawn(PickupKind.marker, x: 92, y: 10,
        note: 'Hollow tag sprayed on a vent: a hollow circle. They were here.'),
  ],
);

const LevelConfig _tagFlashback = LevelConfig(
  id: 'ep1_tag_flashback',
  character: Character.aria,
  theme: DistrictTheme.lowtownNight,
  mechanics: {MechanicType.run, MechanicType.parkour},
  flashback: true,
  objective: 'Catch up to your brother',
  bannerLine: 'Tag, you’re it. Chase Kade across the rooftops.',
  worldWidth: 86,
  worldHeight: 26,
  start: Pt(4, 10),
  goal: Pt(78, 8),
  goalLabel: 'CATCH KADE',
  hazards: [
    Hazard(x: 0, y: 24, width: 86, height: 4),
  ],
  platforms: [
    Platform(x: 0, y: 13, width: 14, height: 13),
    Platform(x: 19, y: 12, width: 10, height: 14),
    Platform(x: 33, y: 14, width: 9, height: 12),
    Platform(x: 47, y: 11, width: 10, height: 15),
    Platform(x: 62, y: 13, width: 9, height: 13),
    Platform(x: 74, y: 10, width: 12, height: 16),
  ],
  walls: [
    Wall(x: 59.5, y: 3, width: 1.6, height: 8),
  ],
  pickups: [
    PickupSpawn(PickupKind.coin, x: 36, y: 12, note: 'A bottle-cap “coin.” Kade always kept the shiny ones.'),
    PickupSpawn(PickupKind.marker, x: 78, y: 8, note: 'Gotcha! “Tag — you’re it!”'),
  ],
);
