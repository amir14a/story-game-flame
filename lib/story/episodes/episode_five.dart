import '../level_builders.dart';
import '../models/cutscene_config.dart';
import '../models/dialogue.dart';
import '../models/episode.dart';
import '../models/level_config.dart';

/// Episode 5 — "Crown of Stars" (the finale).
/// The Apex · climb/parkour/shoot, then swim/run escape · James finds Millie.
Episode buildEpisodeFive() {
  return Episode(
    number: 5,
    title: 'Crown of Stars',
    tagline: 'THE APEX · CLIMB · PARKOUR · SHOOT · SWIM',
    theme: DistrictTheme.spire,
    phases: [
      CutscenePhase(CutsceneConfig(
        title: 'EPISODE 5',
        location: 'THE APEX · THE ONLY REAL SKY LEFT',
        mood: CutsceneMood.present,
        theme: DistrictTheme.spire,
        worldWidth: 30,
        beats: [
          PlaceCharacterBeat(Character.james, x: 8, y: 8.3, facing: 1, pose: CharacterPose.idle),
          NarrationBeat('There is one way to stop the cycle: the override at the crown of the Apex, '
              'where Saint sits beneath the last real sky in Verge City. James climbs.'),
          PauseBeat(0.6),
          DialogueBeat(DialogueLine(Speakers.books, '(comm) I\'ll hold the lifts and the doors for you. Whatever it costs.')),
          PauseBeat(0.8),
          DialogueBeat(DialogueLine(Speakers.james, '(comm) Books—')),
          PauseBeat(0.8),
          DialogueBeat(DialogueLine(Speakers.books, '(comm) Climb, son. Go get your sister.')),
          PoseBeat(Character.james, pose: CharacterPose.climb),
          LookAtBeat(Character.james, facing: 1),
          MoveCharacterBeat(Character.james, targetX: 26, targetY: 8.3, speed: 4.0, pose: CharacterPose.climb),
        ],
        continueLabel: 'CLIMB TO THE TOP OF THE WORLD',
      )),
      LevelPhase(_apexAscent()),
      CutscenePhase(CutsceneConfig(
        title: 'FLASHBACK',
        location: 'A SINK ROOFTOP · THE LULLABY',
        mood: CutsceneMood.flashback,
        theme: DistrictTheme.lowtownNight,
        worldWidth: 30,
        props: const [PropPlacement(CutscenePropKind.windowLights, x: 22, y: 5)],
        beats: [
          PlaceCharacterBeat(Character.millie, x: 14, y: 8.3, facing: 1, pose: CharacterPose.seated),
          NarrationBeat('As he climbs, the oldest memory surfaces — Mara at the window, the two of '
              'them counting lit windows like a sky.'),
          PauseBeat(0.6),
          DialogueBeat(DialogueLine(Speakers.mara, 'Count the stars with me. I\'ll always be one of them.')),
          PauseBeat(0.6),
          DialogueBeat(DialogueLine(Speakers.narrator, 'You are Millie. Walk out to the edge and count them.')),
        ],
        continueLabel: 'PLAY AS MILLIE',
      )),
      LevelPhase(_countingStarsFlashback()),
      CutscenePhase(CutsceneConfig(
        title: 'THE CROWN',
        location: 'THE SUMMIT DATA-CORE · DAWN BREAKING',
        mood: CutsceneMood.present,
        theme: DistrictTheme.spire,
        worldWidth: 32,
        props: const [PropPlacement(CutscenePropKind.dataShard, x: 16, y: 8.0)],
        beats: [
          PlaceCharacterBeat(Character.james, x: 10, y: 8.3, facing: 1, pose: CharacterPose.idle),
          PlaceCharacterBeat(Character.millie, x: 16, y: 8.3, facing: -1, pose: CharacterPose.idle),
          NarrationBeat('James reaches the crown, frees Millie from the core, and together they '
              'finish what she started — her exploit and the wall of evidence, '
              'broadcast to every screen in the city at once.'),
          PauseBeat(0.6),
          NarrationBeat('The lights of Verge City flicker — and come up like stars. Then the '
              'wounded spire begins to flood and fall.'),
          PauseBeat(0.6),
          DialogueBeat(DialogueLine(Speakers.millie, 'It\'s uploading. It\'s actually— James, it\'s working.')),
          PauseBeat(0.6),
          DialogueBeat(DialogueLine(Speakers.james, 'Then we don\'t stay to watch. Move — the whole crown\'s coming down.')),
          MoveCharacterBeat(Character.james, targetX: 26, targetY: 8.3, speed: 5.0),
          MoveCharacterBeat(Character.millie, targetX: 24, targetY: 8.3, speed: 5.0),
        ],
        continueLabel: 'GET HER OUT',
      )),
      LevelPhase(_apexEscape()),
      CutscenePhase(CutsceneConfig(
        title: 'THE TOP OF THE WORLD',
        location: 'THE BROKEN LIP OF THE APEX · SUNRISE',
        mood: CutsceneMood.victory,
        theme: DistrictTheme.spire,
        worldWidth: 30,
        props: const [PropPlacement(CutscenePropKind.paperCrane, x: 15, y: 8.1)],
        beats: [
          PlaceCharacterBeat(Character.james, x: 10, y: 8.3, facing: 1, pose: CharacterPose.idle),
          PlaceCharacterBeat(Character.millie, x: 20, y: 8.3, facing: -1, pose: CharacterPose.idle),
          NarrationBeat('Dawn, on the broken edge of the Apex, the city laid out below and — for '
              'the first time in years — actually visible. Millie is alive: thinner, '
              'scarred, changed. But hers.'),
          PauseBeat(0.6),
          MoveCharacterBeat(Character.james, targetX: 14, targetY: 8.3, speed: 3.0),
          MoveCharacterBeat(Character.millie, targetX: 16, targetY: 8.3, speed: 3.0),
          DialogueBeat(DialogueLine(Speakers.millie, 'You climbed to the top of the world.')),
          PauseBeat(0.6),
          DialogueBeat(DialogueLine(Speakers.james, 'You said you\'d find me here. Figured I\'d save you the walk.')),
          PauseBeat(0.6),
          DialogueBeat(DialogueLine(Speakers.narrator, 'She presses the last crane into his scarred hand and finishes the lullaby.')),
          PauseBeat(0.6),
          DialogueBeat(DialogueLine(Speakers.millie, 'Count the stars with me, big brother.')),
          PauseBeat(0.6),
          DialogueBeat(DialogueLine(Speakers.james, 'All of them. We\'ve got time.')),
        ],
        continueLabel: 'THE END',
      )),
    ],
  );
}

LevelConfig _apexAscent() {
  return LevelConfig(
    id: 'ep5_apex_ascent',
    character: Character.james,
    theme: DistrictTheme.spire,
    mechanics: const {MechanicType.climb, MechanicType.parkour, MechanicType.shoot},
    objective: 'Ascend the Apex to the summit data-core',
    bannerLine: 'Climb the rigging · wall-jump the shafts · shoot through',
    worldWidth: 66,
    worldHeight: 128,
    killY: 126,
    start: const Pt(8, 112),
    goal: const Pt(30, 9),
    goalLabel: 'THE CROWN',
    platforms: const [
      Platform(x: 0, y: 116, width: 66, height: 12), // ground floor
      Platform(x: 0, y: 98, width: 28, height: 2),
      Platform(x: 34, y: 80, width: 32, height: 2),
      Platform(x: 36, y: 60, width: 30, height: 2),
      Platform(x: 6, y: 50, width: 18, height: 2),
      Platform(x: 0, y: 38, width: 22, height: 2),
      Platform(x: 30, y: 26, width: 30, height: 2),
      Platform(x: 0, y: 12, width: 66, height: 2), // summit
    ],
    ladders: [
      Build.ladder(x: 10, topY: 96, bottomY: 116),
      Build.ladder(x: 54, topY: 58, bottomY: 80),
      Build.ladder(x: 14, topY: 24, bottomY: 38),
    ],
    walls: const [
      Wall(x: 36, y: 60, width: 1.6, height: 20), // wall-jump shaft between floors
      Wall(x: 44, y: 60, width: 1.6, height: 20),
    ],
    enemies: [
      ...Build.enemiesAt(EnemyKind.grunt, [18, 50, 40], 98, patrol: 6),
      ...Build.enemiesAt(EnemyKind.drone, [40, 10], 62),
      ...Build.enemiesAt(EnemyKind.grunt, [40], 12, patrol: 8),
    ],
    checkpoints: const [Pt(8, 112), Pt(8, 96), Pt(50, 78), Pt(40, 58), Pt(8, 36)],
    pickups: const [
      PickupSpawn(PickupKind.marker, x: 50, y: 78, note: 'Saint-Cloud logs — every crime, time-stamped. She was right about all of it.'),
    ],
    npcs: const [
      NpcSpawn(NpcKind.saint, x: 46, y: 12, facing: -1, lines: [
        DialogueLine(Speakers.saint, 'The devoted brother. You climbed my whole tower for her.'),
        DialogueLine(Speakers.saint, 'She is a resource, James. They all are. The city runs on what we render down.'),
        DialogueLine(Speakers.james, 'Not anymore. Step away from the core.'),
        DialogueLine(Speakers.saint, 'You won\'t reach the override in time. No one ever does.'),
        DialogueLine(Speakers.james, 'She already did. I\'m just here to press the last key.'),
      ]),
      NpcSpawn(NpcKind.millie, x: 22, y: 12, facing: 1, lines: [
        DialogueLine(Speakers.millie, 'James? You\'re— of course you are. You absolute idiot.'),
        DialogueLine(Speakers.james, 'Took the words right out of my mouth. Can you stand?'),
        DialogueLine(Speakers.millie, 'Plug me into the core. We finish this together or not at all.'),
      ]),
    ],
    dialogueTriggers: const [
      DialogueTrigger(x: 8, lines: [DialogueLine(Speakers.james, 'All the way up. For her.')]),
    ],
  );
}

LevelConfig _countingStarsFlashback() {
  return LevelConfig(
    id: 'ep5_counting_stars_flashback',
    character: Character.millie,
    theme: DistrictTheme.lowtownNight,
    mechanics: const {MechanicType.run},
    flashback: true,
    objective: 'Walk out to the edge and count the stars',
    bannerLine: 'Some promises you walk to.',
    worldWidth: 54,
    worldHeight: 22,
    killY: 20,
    start: const Pt(4, 11),
    goal: const Pt(46, 11),
    goalLabel: 'THE EDGE',
    platforms: const [Platform(x: 0, y: 14, width: 52, height: 8)],
    npcs: const [
      NpcSpawn(NpcKind.james, x: 42, y: 14, facing: -1, lines: [
        DialogueLine(Speakers.youngJames, 'About time. Best seat in the Sink, right here. Budge in.'),
        DialogueLine(Speakers.youngMillie, 'One… two… three…'),
        DialogueLine(Speakers.youngJames, 'Mum says that bright stubborn one\'s yours.'),
        DialogueLine(Speakers.youngMillie, 'Then I\'ll always be up there. Even if I\'m not right here.'),
      ]),
    ],
    pickups: const [
      PickupSpawn(PickupKind.marker, x: 22, y: 11, note: 'Two small voices, counting other people\'s windows like a sky.'),
    ],
    dialogueTriggers: const [
      DialogueTrigger(x: 2, lines: [DialogueLine(Speakers.youngMillie, 'Wait up — I can\'t see the good ones from back here!')]),
      DialogueTrigger(x: 28, lines: [DialogueLine(Speakers.mara, '(from the window) Stay where I can see you both.')]),
    ],
  );
}

LevelConfig _apexEscape() {
  return LevelConfig(
    id: 'ep5_apex_escape',
    character: Character.james,
    theme: DistrictTheme.sunken,
    mechanics: const {MechanicType.run, MechanicType.swim, MechanicType.climb},
    objective: 'Get out before the crown floods and falls',
    bannerLine: 'Run the collapse · swim the flooded shaft · climb to the dawn',
    worldWidth: 176,
    worldHeight: 36,
    killY: 33,
    start: const Pt(4, 9),
    goal: const Pt(168, 7),
    goalLabel: 'THE BROKEN LIP',
    platforms: [
      ...Build.roofRun(x0: 0, count: 5, width: 9, gap: 3.5, baseY: 12, vary: 1.6), // collapsing floors (run)
      const Platform(x: 64, y: 30, width: 60, height: 6), // flooded shaft floor
      const Platform(x: 120, y: 6, width: 18, height: 2), // climb-out ledge
      Build.floor(x: 138, width: 38, y: 13, depth: 10), // final run to the lip
    ],
    waters: const [WaterZone(x: 60, y: 16, width: 66, height: 20)],
    ladders: [Build.ladder(x: 122, topY: 5, bottomY: 30)],
    checkpoints: const [Pt(4, 9), Pt(66, 14), Pt(124, 5), Pt(150, 11)],
    pickups: const [
      PickupSpawn(PickupKind.air, x: 78, y: 20),
      PickupSpawn(PickupKind.air, x: 104, y: 20),
      PickupSpawn(PickupKind.marker, x: 168, y: 7, note: 'Dawn. Real dawn. And Millie\'s hand in his.'),
    ],
    dialogueTriggers: const [
      DialogueTrigger(x: 2, lines: [
        DialogueLine(Speakers.millie, '(beside you) Go, go — I\'m right behind you!'),
      ]),
      DialogueTrigger(x: 58, lines: [DialogueLine(Speakers.james, 'Shaft\'s flooded. Big breath — we swim it.')]),
      DialogueTrigger(x: 140, blocking: true, lines: [
        DialogueLine(Speakers.millie, 'James. Look at the city.'),
        DialogueLine(Speakers.james, 'I see it, Mil. Everyone can see it now.'),
      ]),
    ],
  );
}
