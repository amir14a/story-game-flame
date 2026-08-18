import '../level_builders.dart';
import '../models/cutscene_config.dart';
import '../models/dialogue.dart';
import '../models/episode.dart';
import '../models/level_config.dart';

/// Episode 2 — "The Loop".
/// The Loop · driving + shooting, then on-foot parkour/climb/shoot · teen Millie (flashback).
Episode buildEpisodeTwo() {
  return Episode(
    number: 2,
    title: 'The Loop',
    tagline: 'THE LOOP · DRIVE · SHOOT · PARKOUR · CLIMB',
    theme: DistrictTheme.skyway,
    phases: [
      CutscenePhase(CutsceneConfig(
        title: 'EPISODE 2',
        location: 'A LOOP ON-RAMP · SOAKED AND BLEEDING',
        mood: CutsceneMood.present,
        theme: DistrictTheme.skyway,
        beats: [
          NarrationBeat('James drags himself out of the Sink\'s black water onto the ring-road. '
              'The only way across to the Floodworks is the Loop — and tonight Cray\'s '
              'people own it.'),
          PauseBeat(1.0),
          DialogueBeat(DialogueLine(Speakers.books, '(comm) Find a car, James. Don\'t stop for anything that\'s shooting at you.')),
          PauseBeat(0.8),
          DialogueBeat(DialogueLine(Speakers.james, '(comm) That\'s everything, Books.')),
          PauseBeat(0.8),
          DialogueBeat(DialogueLine(Speakers.books, '(comm) Then don\'t stop.')),
        ],
        continueLabel: 'HIT THE LOOP',
      )),
      LevelPhase(_loopDrive()),
      CutscenePhase(CutsceneConfig(
        title: 'THE WRECK-JAM',
        location: 'THE LOOP · A SEIZED TOLL-GATE',
        mood: CutsceneMood.present,
        theme: DistrictTheme.skyway,
        beats: [
          NarrationBeat('A rammed interceptor folds the hauler into the barrier. James bails out '
              'and goes the rest of the way on foot, over the wreckage.'),
          PauseBeat(1.0),
          DialogueBeat(DialogueLine(Speakers.narrator, 'Vault the wreck-jam, climb the toll-gate, and fight to the descent.')),
        ],
        continueLabel: 'ON FOOT',
      )),
      LevelPhase(_loopWreckage()),
      CutscenePhase(CutsceneConfig(
        title: 'FLASHBACK',
        location: 'THE OLD LOOP · 3 A.M., SIX YEARS AGO',
        mood: CutsceneMood.flashback,
        theme: DistrictTheme.skyway,
        beats: [
          NarrationBeat('A borrowed car on an empty ring-road. Teenage Millie at the wheel, James '
              'white-knuckled beside her, both of them laughing at nothing.'),
          PauseBeat(1.0),
          DialogueBeat(DialogueLine(Speakers.millie, 'Relax! I\'ve done this once. Twice if you count the wall.')),
          PauseBeat(0.8),
          DialogueBeat(DialogueLine(Speakers.narrator, 'You are Millie. Take the empty Loop to the overlook.')),
        ],
        continueLabel: 'PLAY AS MILLIE',
      )),
      LevelPhase(_firstLightFlashback()),
      CutscenePhase(CutsceneConfig(
        title: 'EPISODE 2 — ENDING',
        location: 'THE FLOODWORKS DESCENT',
        mood: CutsceneMood.cliffhanger,
        theme: DistrictTheme.skyway,
        beats: [
          NarrationBeat('At the descent, the distorted channel that\'s haunted the comm all night '
              'finally clears. It is unmistakably her.'),
          PauseBeat(1.0),
          DialogueBeat(DialogueLine(Speakers.millie, '(comm) James. Stop. If you come down here, you undo everything I\'ve bled for.')),
          PauseBeat(0.8),
          DialogueBeat(DialogueLine(Speakers.millie, '(comm) Please. Go home.')),
          PauseBeat(0.8),
          DialogueBeat(DialogueLine(Speakers.narrator, 'A charge blows the ramp out from under him. He falls toward the flooded dark.')),
          PauseBeat(0.8),
          DialogueBeat(DialogueLine(Speakers.james, '(falling) Millie—!')),
        ],
        continueLabel: 'EPISODE 3 ▶',
      )),
    ],
  );
}

LevelConfig _loopDrive() {
  return LevelConfig(
    id: 'ep2_loop_drive',
    character: Character.james,
    theme: DistrictTheme.skyway,
    vehicle: VehicleKind.car,
    mechanics: const {MechanicType.drive, MechanicType.shoot},
    objective: 'Outrun the Loop — the car leans into the hills; B / J shoots',
    bannerLine: 'Right pedal drives · B / J shoots forward · no jumping, just drive',
    worldWidth: 268,
    worldHeight: 30,
    start: const Pt(8, 14),
    goal: const Pt(258, 16),
    goalLabel: 'THE DESCENT',
    grounds: [Build.road(x0: -6, x1: 270, y: 20, amp: 1.9, wavelength: 58)],
    enemies: [
      ...Build.enemiesAt(EnemyKind.rider, [60, 120, 196], 18),
      ...Build.enemiesAt(EnemyKind.drone, [40, 96, 150, 210, 244], 9),
    ],
    pickups: const [
      PickupSpawn(PickupKind.marker, x: 30, y: 16, note: 'Loop sign: FLOODWORKS DESCENT — CLOSED.'),
    ],
    dialogueTriggers: const [
      DialogueTrigger(x: 6, lines: [DialogueLine(Speakers.james, 'Old hauler. Bald tyres. Perfect.')]),
      DialogueTrigger(x: 70, lines: [
        DialogueLine(Speakers.books, '(comm) Riders on your tail. Shoot \'em or lose \'em on the hills.'),
      ]),
      DialogueTrigger(x: 150, blocking: true, lines: [
        DialogueLine(Speakers.narrator, '(comm — distorted) …James… turn back… you don\'t…'),
        DialogueLine(Speakers.james, '(comm) Who is this? Say again!'),
        DialogueLine(Speakers.narrator, 'The channel dissolves into static.'),
      ]),
    ],
  );
}

LevelConfig _loopWreckage() {
  return LevelConfig(
    id: 'ep2_loop_wreckage',
    character: Character.james,
    theme: DistrictTheme.skyway,
    mechanics: const {MechanicType.run, MechanicType.parkour, MechanicType.climb, MechanicType.shoot},
    objective: 'Cross the wreck-jam and the toll-gate on foot',
    bannerLine: 'Vault the wrecks · climb the gate · shoot through',
    worldWidth: 170,
    worldHeight: 30,
    killY: 25,
    start: const Pt(4, 8),
    goal: const Pt(160, 7),
    goalLabel: 'THE DESCENT RAMP',
    platforms: [
      ...Build.roofRun(x0: 0, count: 5, width: 8, gap: 3.5, baseY: 13, vary: 1.8), // wreck-jam (vault)
      Build.floor(x: 64, width: 20, y: 18, depth: 12), // gate base
      Platform(x: 70, y: 5, width: 16, height: 2), // top of the toll-gate
      Build.floor(x: 92, width: 76, y: 18, depth: 12), // run to the ramp
    ],
    walls: const [Wall(x: 30, y: 4, width: 1.6, height: 8)],
    ladders: [Build.ladder(x: 74, topY: 3, bottomY: 18)],
    enemies: [
      ...Build.enemiesAt(EnemyKind.grunt, [104, 124, 146], 18, patrol: 5),
      ...Build.enemiesAt(EnemyKind.drone, [40, 130], 8),
    ],
    checkpoints: const [Pt(40, 11), Pt(72, 15), Pt(110, 15), Pt(140, 15)],
    dialogueTriggers: const [
      DialogueTrigger(x: 2, lines: [DialogueLine(Speakers.james, 'On foot it is.')]),
      DialogueTrigger(x: 64, lines: [DialogueLine(Speakers.books, '(comm) Toll-gate\'s welded. Go over the top.')]),
      DialogueTrigger(x: 120, blocking: true, lines: [
        DialogueLine(Speakers.books, '(comm) Descent\'s just ahead. James… that voice on the channel. You heard it too.'),
        DialogueLine(Speakers.james, '(comm) I heard it.'),
      ]),
    ],
  );
}

LevelConfig _firstLightFlashback() {
  return LevelConfig(
    id: 'ep2_first_light_flashback',
    character: Character.millie,
    theme: DistrictTheme.skyway,
    vehicle: VehicleKind.car,
    companion: Character.james, // James rides shotgun
    mechanics: const {MechanicType.drive},
    flashback: true,
    objective: 'Cruise the empty Loop to the overlook',
    bannerLine: 'No rush tonight. Just drive.',
    worldWidth: 180,
    worldHeight: 30,
    start: const Pt(8, 14),
    goal: const Pt(170, 16),
    goalLabel: 'THE OVERLOOK',
    grounds: [Build.road(x0: -6, x1: 182, y: 20, amp: 1.5, wavelength: 52)],
    pickups: const [
      PickupSpawn(PickupKind.coin, x: 50, y: 16, note: 'Millie cranks the radio. A song they both half-remember.'),
      PickupSpawn(PickupKind.coin, x: 120, y: 16, note: 'James hangs his arm out the window and whoops at the skyline.'),
    ],
    dialogueTriggers: const [
      DialogueTrigger(x: 8, lines: [DialogueLine(Speakers.youngJames, 'Both hands, Mil. BOTH hands.')]),
      DialogueTrigger(x: 90, lines: [
        DialogueLine(Speakers.millie, 'Watch this.'),
        DialogueLine(Speakers.narrator, 'Every camera on the overlook lights up at once — her little program.'),
        DialogueLine(Speakers.millie, 'The whole city. Seen, just for a second. They can\'t hide all of it.'),
      ]),
    ],
  );
}
