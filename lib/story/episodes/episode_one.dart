import '../level_builders.dart';
import '../models/cutscene_config.dart';
import '../models/dialogue.dart';
import '../models/episode.dart';
import '../models/level_config.dart';

/// Episode 1 — "Breadcrumbs".
/// The Sink · James (run/parkour/climb/shoot), then young Millie (flashback).
Episode buildEpisodeOne() {
  return Episode(
    number: 1,
    title: 'Breadcrumbs',
    tagline: 'THE SINK · RUN · PARKOUR · CLIMB · SHOOT',
    theme: DistrictTheme.rooftops,
    phases: [
      CutscenePhase(CutsceneConfig(
        title: 'EPISODE 1',
        location: 'THE SINK · A FIRE-ESCAPE · NIGHT',
        mood: CutsceneMood.present,
        theme: DistrictTheme.rooftops,
        beats: [
          NarrationBeat('Six months of silence. Then a paper crane on the doorstep, folded in '
              'Millie\'s hand, with three words inside: "Don\'t look for me."'),
          PauseBeat(1.0),
          NarrationBeat('A second crane is already gone — a street-kid is running with the chip '
              'that was folded inside it. James goes after them.'),
          PauseBeat(1.0),
          DialogueBeat(DialogueLine(Speakers.james, 'Six months. And now a paper bird.')),
          PauseBeat(0.8),
          DialogueBeat(DialogueLine(Speakers.james, '…Not this time, Mil. This time I follow the trail.')),
        ],
        continueLabel: 'CHASE THE COURIER',
      )),
      LevelPhase(_sinkChase()),
      CutscenePhase(CutsceneConfig(
        title: 'FLASHBACK',
        location: 'A SINK ROOFTOP · SIXTEEN YEARS AGO',
        mood: CutsceneMood.flashback,
        theme: DistrictTheme.lowtownNight,
        beats: [
          NarrationBeat('Before the silence. Before any of it. Just two kids and a sky made of '
              'other people\'s windows.'),
          PauseBeat(1.0),
          DialogueBeat(DialogueLine(Speakers.youngMillie, 'Can\'t catch me, slow-bones!')),
          PauseBeat(0.8),
          DialogueBeat(DialogueLine(Speakers.narrator, 'You are Millie. Chase James across the rooftops to the washing-lines.')),
        ],
        continueLabel: 'PLAY AS MILLIE',
      )),
      LevelPhase(_craneFlashback()),
      CutscenePhase(CutsceneConfig(
        title: 'EPISODE 1 — ENDING',
        location: 'RIVET ROW · THE HIGH ROOF',
        mood: CutsceneMood.cliffhanger,
        theme: DistrictTheme.rooftops,
        beats: [
          NarrationBeat('James corners the courier — a terrified kid, maybe ten.'),
          PauseBeat(1.0),
          DialogueBeat(DialogueLine(Speakers.narrator, 'KID: "She paid me to slow you down! That\'s all, I swear—"')),
          PauseBeat(0.8),
          DialogueBeat(DialogueLine(Speakers.narrator,
              'A red dot finds the kid\'s chest. A Mire sniper fires once. The roof '
              'gives way under the impact and the fight.')),
          PauseBeat(0.8),
          DialogueBeat(DialogueLine(Speakers.james, '(falling) Floodworks. She\'s in the Floodworks—')),
        ],
        continueLabel: 'EPISODE 2 ▶',
      )),
    ],
  );
}

LevelConfig _sinkChase() {
  return LevelConfig(
    id: 'ep1_sink_chase',
    character: Character.james,
    theme: DistrictTheme.rooftops,
    mechanics: const {MechanicType.run, MechanicType.parkour, MechanicType.climb, MechanicType.shoot},
    objective: 'Chase the courier across the Sink — run, climb, fight through',
    bannerLine: 'Run · vault · climb the tenement · shoot the Mire',
    worldWidth: 214,
    worldHeight: 32,
    killY: 26,
    start: const Pt(4, 7),
    goal: const Pt(198, 7),
    goalLabel: 'THE HIGH ROOF',
    platforms: [
      ...Build.roofRun(x0: 0, count: 6, width: 9, gap: 3.5, baseY: 11, vary: 2.0),
      Build.floor(x: 72, width: 24, y: 19, depth: 13), // alley base
      Platform(x: 76, y: 6, width: 20, height: 2), // tenement ledge (climb up to it)
      Build.floor(x: 100, width: 64, y: 19, depth: 13), // the street (shoot)
      ...Build.roofRun(x0: 168, count: 4, width: 10, gap: 4, baseY: 9, vary: 1.4),
    ],
    walls: const [
      Wall(x: 34, y: 2, width: 1.6, height: 9), // parkour pillar
      Wall(x: 60, y: 3, width: 1.6, height: 8),
    ],
    ladders: [
      Build.ladder(x: 82, topY: 4, bottomY: 19), // up to the tenement ledge
    ],
    enemies: [
      ...Build.enemiesAt(EnemyKind.grunt, [114, 132, 150], 19, patrol: 5),
      ...Build.enemiesAt(EnemyKind.drone, [56, 120, 178], 9),
    ],
    checkpoints: const [Pt(38, 8), Pt(80, 16), Pt(108, 16), Pt(150, 16), Pt(180, 6)],
    pickups: const [
      PickupSpawn(PickupKind.marker, x: 78, y: 5, note: 'A paper crane, snagged on an aerial. She came this way.'),
      PickupSpawn(PickupKind.marker, x: 160, y: 18, note: 'Mire tag, fresh paint. They\'re hunting her too.'),
    ],
    npcs: const [
      NpcSpawn(NpcKind.books, x: 128, y: 19, facing: -1, lines: [
        DialogueLine(Speakers.books, 'James Vance. Knew you\'d come down here swinging.'),
        DialogueLine(Speakers.james, 'Where is she, Books?'),
        DialogueLine(Speakers.books,
            'Floodworks, last anyone saw. But listen to me — Millie\'s not who you '
            'remember. She walked away from you on purpose, son.'),
        DialogueLine(Speakers.books, 'Whatever she\'s into, it\'s bigger than a kid sister in trouble.'),
        DialogueLine(Speakers.james, 'Then I\'d better catch up.'),
      ]),
    ],
    dialogueTriggers: const [
      DialogueTrigger(x: 2, lines: [
        DialogueLine(Speakers.james, 'Stay on the roofs. Don\'t lose the kid.'),
      ]),
      DialogueTrigger(x: 24, lines: [
        DialogueLine(Speakers.books, '(comm) That you on the Row, James? You\'re making noise.'),
        DialogueLine(Speakers.james, '(comm) Found one of her cranes. Following the next.'),
      ]),
      DialogueTrigger(x: 76, lines: [
        DialogueLine(Speakers.books, '(comm) Tenement\'s rotted through. Climb it, don\'t trust the stairs.'),
      ]),
      DialogueTrigger(x: 104, blocking: true, lines: [
        DialogueLine(Speakers.books, '(comm) Mire on the street ahead — the old crew. They\'ll know your face.'),
        DialogueLine(Speakers.james, '(comm) Then they know to get out of my way.'),
      ]),
      DialogueTrigger(x: 170, lines: [
        DialogueLine(Speakers.james, 'There — the courier. End of the Row.'),
      ]),
    ],
  );
}

LevelConfig _craneFlashback() {
  return LevelConfig(
    id: 'ep1_crane_flashback',
    character: Character.millie,
    theme: DistrictTheme.lowtownNight,
    mechanics: const {MechanicType.run, MechanicType.parkour},
    flashback: true,
    objective: 'Catch up to James at the washing-lines',
    bannerLine: 'Tag — chase James down. He always stops to gloat.',
    worldWidth: 116,
    worldHeight: 28,
    killY: 24,
    start: const Pt(4, 9),
    goal: const Pt(106, 8),
    goalLabel: 'THE WASHING-LINES',
    platforms: [
      ...Build.roofRun(x0: 0, count: 7, width: 9, gap: 4, baseY: 12, vary: 2.4),
      Platform(x: 96, y: 10, width: 18, height: 16),
    ],
    walls: const [Wall(x: 58, y: 3, width: 1.6, height: 8)],
    checkpoints: const [Pt(36, 10), Pt(72, 10)],
    pickups: const [
      PickupSpawn(PickupKind.coin, x: 40, y: 11, note: 'A folded crane on the ledge. Mara taught her these.'),
    ],
    npcs: const [
      NpcSpawn(NpcKind.james, x: 102, y: 10, facing: -1, lines: [
        DialogueLine(Speakers.youngJames, 'Beat you AGAIN. Told you. Okay, okay — show me the bird thing.'),
        DialogueLine(Speakers.youngMillie, 'Give me your hands. Fold here… and here… see? A crane.'),
        DialogueLine(Speakers.youngMillie, 'If we ever get lost, leave a trail of these. I\'ll always find the next one.'),
        DialogueLine(Speakers.youngJames, 'That\'s a dumb plan.'),
        DialogueLine(Speakers.youngMillie, 'It\'s a great plan. Pinky promise.'),
      ]),
    ],
    dialogueTriggers: const [
      DialogueTrigger(x: 2, lines: [DialogueLine(Speakers.youngJames, '(ahead) Can\'t catch me, slow-bones!')]),
      DialogueTrigger(x: 48, lines: [
        DialogueLine(Speakers.youngJames, '(ahead) Mind the gap, Mil — or don\'t, ha!'),
        DialogueLine(Speakers.youngMillie, 'Trust the jump. Always trust the jump.'),
      ]),
      DialogueTrigger(x: 88, lines: [DialogueLine(Speakers.mara, '(distant) Come in, you two. Count the stars with me.')]),
    ],
  );
}
