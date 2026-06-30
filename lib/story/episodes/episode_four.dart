import '../level_builders.dart';
import '../models/dialogue.dart';
import '../models/episode.dart';
import '../models/level_config.dart';

/// Episode 4 — "The Foundry" (all is lost).
/// The Foundry · riding + shooting, then climbing/running/shooting · the Cray confrontation.
Episode buildEpisodeFour() {
  return Episode(
    number: 4,
    title: 'The Foundry',
    tagline: 'THE FOUNDRY · RIDE · SHOOT · CLIMB · RUN',
    theme: DistrictTheme.steelVeins,
    phases: [
      const CutscenePhase(Cutscene(
        title: 'EPISODE 4',
        location: 'THE FOUNDRY GATES · RAIN AND SODIUM LIGHT',
        mood: CutsceneMood.present,
        narration: [
          'Guilt is the engine now. They took Millie because James led them to her. '
              'The only thing left is to finish what she started — at Saint-Cloud\'s '
              'processing plant, deep in the Foundry.',
        ],
        lines: [
          DialogueLine(Speakers.books, '(comm) This isn\'t your fault, James.'),
          DialogueLine(Speakers.james, '(comm) It\'s exactly my fault. Find me a way in.'),
        ],
        continueLabel: 'RIDE',
      )),
      LevelPhase(_foundryRide()),
      const CutscenePhase(Cutscene(
        title: 'INSIDE THE PLANT',
        location: 'SAINT-CLOUD PROCESSING · THE CATWALKS',
        mood: CutsceneMood.present,
        narration: [
          'James ditches the bike at the loading dock and climbs into the plant — '
              'and sees plainly what "processing" means here.',
        ],
        lines: [
          DialogueLine(Speakers.narrator, 'Climb the rigging, run the catwalks, and fight to the core.'),
        ],
        continueLabel: 'CLIMB IN',
      )),
      LevelPhase(_foundryPlant()),
      const CutscenePhase(Cutscene(
        title: 'FLASHBACK',
        location: 'SAINT-CLOUD INTAKE · WEEKS AGO',
        mood: CutsceneMood.flashback,
        narration: [
          'How the Ghost got inside. Millie, walking willingly into the intake — '
              'choosing capture to plant her exploit at the core, knowing the cost.',
        ],
        lines: [
          DialogueLine(Speakers.millie, 'One way in that they\'ll never expect. The front door.'),
          DialogueLine(Speakers.narrator, 'You are Millie. Walk in, and leave the next crane on the threshold.'),
        ],
        continueLabel: 'PLAY AS MILLIE',
      )),
      LevelPhase(_bargainFlashback()),
      const CutscenePhase(Cutscene(
        title: 'EPISODE 4 — ENDING',
        location: 'THE PROCESSING CORE',
        mood: CutsceneMood.cliffhanger,
        narration: [
          'James reaches the core a breath too late. The cycle has started — and '
              'Millie is inside it. Every screen blooms with a calm, kind voice.',
        ],
        lines: [
          DialogueLine(Speakers.saint, 'You brought her home to me, James. Thank you.'),
          DialogueLine(Speakers.saint, 'Now stand very still, and watch.'),
          DialogueLine(Speakers.narrator, 'The core seals. The lights go red.'),
          DialogueLine(Speakers.james, 'No. NO — the Apex. The override\'s at the top. I\'m coming up.'),
        ],
        continueLabel: 'EPISODE 5 ▶',
      )),
    ],
  );
}

LevelConfig _foundryRide() {
  return LevelConfig(
    id: 'ep4_foundry_ride',
    character: Character.james,
    theme: DistrictTheme.steelVeins,
    vehicle: VehicleKind.bike,
    mechanics: const {MechanicType.bike, MechanicType.shoot},
    objective: 'Ride the Foundry arteries — shoot Cray\'s riders off your tail',
    bannerLine: 'Right pedal rides · the bike leans into the hills · B / J shoots',
    worldWidth: 262,
    worldHeight: 30,
    start: const Pt(8, 14),
    goal: const Pt(252, 16),
    goalLabel: 'THE LOADING DOCK',
    grounds: [Build.road(x0: -6, x1: 264, y: 20, amp: 2.0, wavelength: 50)],
    enemies: [
      ...Build.enemiesAt(EnemyKind.rider, [50, 110, 170, 220], 18),
      ...Build.enemiesAt(EnemyKind.drone, [34, 90, 150, 206], 9),
    ],
    dialogueTriggers: const [
      DialogueTrigger(x: 8, lines: [DialogueLine(Speakers.james, 'Hold on, Mil. Let me be the one who finds you, just once.')]),
      DialogueTrigger(x: 80, lines: [DialogueLine(Speakers.books, '(comm) Riders inbound. Don\'t let them box you in.')]),
      DialogueTrigger(x: 180, lines: [DialogueLine(Speakers.books, '(comm) Dock\'s ahead. After that I can\'t follow you in.')]),
    ],
  );
}

LevelConfig _foundryPlant() {
  return LevelConfig(
    id: 'ep4_foundry_plant',
    character: Character.james,
    theme: DistrictTheme.steelVeins,
    mechanics: const {MechanicType.climb, MechanicType.run, MechanicType.parkour, MechanicType.shoot},
    objective: 'Climb the rigging and fight to the processing core',
    bannerLine: 'Climb · wall-jump the shafts · shoot through',
    worldWidth: 180,
    worldHeight: 34,
    killY: 30,
    start: const Pt(4, 9),
    goal: const Pt(172, 7),
    goalLabel: 'THE CORE',
    platforms: [
      Build.floor(x: 0, width: 26, y: 16, depth: 14),
      const Platform(x: 22, y: 6, width: 18, height: 2), // first catwalk
      Build.floor(x: 44, width: 24, y: 18, depth: 12),
      const Platform(x: 64, y: 8, width: 16, height: 2),
      Build.floor(x: 86, width: 30, y: 16, depth: 14),
      ...Build.roofRun(x0: 120, count: 4, width: 9, gap: 3.5, baseY: 10, vary: 1.6), // collapsing floors (parkour)
      Build.floor(x: 162, width: 18, y: 12, depth: 12),
    ],
    walls: const [
      Wall(x: 80, y: 4, width: 1.6, height: 10),
      Wall(x: 88, y: 4, width: 1.6, height: 10), // wall-jump shaft
    ],
    ladders: [
      Build.ladder(x: 26, topY: 5, bottomY: 16),
      Build.ladder(x: 68, topY: 7, bottomY: 18),
    ],
    enemies: [
      ...Build.enemiesAt(EnemyKind.grunt, [50, 96, 108], 16, patrol: 5),
      ...Build.enemiesAt(EnemyKind.drone, [30, 130, 150], 7),
    ],
    checkpoints: const [Pt(24, 5), Pt(56, 15), Pt(96, 13), Pt(150, 9)],
    pickups: const [
      PickupSpawn(PickupKind.marker, x: 92, y: 15, note: 'Intake manifests. Names. So many names from the Sink.'),
    ],
    npcs: const [
      NpcSpawn(NpcKind.cray, x: 166, y: 12, facing: -1, lines: [
        DialogueLine(Speakers.cray, 'James Vance. Right on schedule.'),
        DialogueLine(Speakers.james, 'Where is she?'),
        DialogueLine(Speakers.cray, 'Below you. In the cycle. And you put her there, in a way.'),
        DialogueLine(Speakers.cray, 'Mother wanted you found so the Ghost would surface to save you. You\'re the bait, James.'),
        DialogueLine(Speakers.cray, 'You\'ve always been the bait.'),
        DialogueLine(Speakers.james, 'Then I\'m a lousy one. Move.'),
      ]),
    ],
    dialogueTriggers: const [
      DialogueTrigger(x: 2, lines: [DialogueLine(Speakers.james, 'Up. Always up in this city.')]),
      DialogueTrigger(x: 118, lines: [DialogueLine(Speakers.books, '(comm) Floor\'s giving way ahead — keep moving, don\'t stand still.')]),
    ],
  );
}

LevelConfig _bargainFlashback() {
  return LevelConfig(
    id: 'ep4_bargain_flashback',
    character: Character.millie,
    theme: DistrictTheme.steelVeins,
    mechanics: const {MechanicType.run},
    flashback: true,
    objective: 'Walk into the intake — and leave the crane',
    bannerLine: 'The hardest door she ever opened.',
    worldWidth: 90,
    worldHeight: 24,
    killY: 20,
    start: const Pt(4, 11),
    goal: const Pt(84, 11),
    goalLabel: 'THE THRESHOLD',
    platforms: [Build.floor(x: 0, width: 90, y: 15, depth: 9)],
    checkpoints: const [Pt(30, 11), Pt(60, 11)],
    pickups: const [
      PickupSpawn(PickupKind.coin, x: 24, y: 14, note: 'She folds a crane, slow and careful, the way Mum taught her.'),
      PickupSpawn(PickupKind.marker, x: 84, y: 11, note: 'She sets the crane on the threshold. Then she raises her hands and walks in.'),
    ],
    dialogueTriggers: const [
      DialogueTrigger(x: 2, lines: [DialogueLine(Speakers.millie, 'They take what they think is weak. So I\'ll be the weakest thing they\'ve ever seen.')]),
      DialogueTrigger(x: 56, lines: [DialogueLine(Speakers.millie, 'Climb to the top of the world, James. I\'ll find you there. I promise.')]),
    ],
  );
}
