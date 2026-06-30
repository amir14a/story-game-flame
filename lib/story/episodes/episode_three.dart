import '../level_builders.dart';
import '../models/dialogue.dart';
import '../models/episode.dart';
import '../models/level_config.dart';

/// Episode 3 — "Drowned Light" (the reversal).
/// The Floodworks · swim/climb/shoot/run · the first real meeting with Millie.
Episode buildEpisodeThree() {
  return Episode(
    number: 3,
    title: 'Drowned Light',
    tagline: 'THE FLOODWORKS · SWIM · CLIMB · SHOOT · RUN',
    theme: DistrictTheme.sunken,
    phases: [
      const CutscenePhase(Cutscene(
        title: 'EPISODE 3',
        location: 'THE FLOODWORKS · A DROWNED AVENUE',
        mood: CutsceneMood.present,
        narration: [
          'James surfaces where streets have become canals and a cathedral stands '
              'up to its shoulders in black water. Somewhere in here is the sister '
              'who begged him not to come.',
        ],
        lines: [
          DialogueLine(Speakers.james, 'Hold on, Mil. I\'m already here.'),
          DialogueLine(Speakers.narrator, 'Swim the flooded streets, climb the rigging, fight through to the cathedral.'),
        ],
        continueLabel: 'DIVE',
      )),
      LevelPhase(_floodworks()),
      const CutscenePhase(Cutscene(
        title: 'FLASHBACK',
        location: 'THE SINK · THE NIGHT OF THE COLLAPSE',
        mood: CutsceneMood.flashback,
        narration: [
          'The memory she never speaks of. Twelve years old, searching the rubble '
              'where the transit line came down — where their parents were.',
        ],
        lines: [
          DialogueLine(Speakers.narrator, 'You are Millie. Search the wreckage.'),
        ],
        continueLabel: 'PLAY AS MILLIE',
      )),
      LevelPhase(_questionFlashback()),
      const CutscenePhase(Cutscene(
        title: 'EPISODE 3 — ENDING',
        location: 'THE COMMAND POST',
        mood: CutsceneMood.cliffhanger,
        narration: [
          'Before James can say half of what he came to say, the wall comes down — '
              'Cray\'s strike team, breaching the post. They followed James here. His '
              'search is the thing that finally found her.',
        ],
        lines: [
          DialogueLine(Speakers.millie, 'No—no, you led them straight to— get DOWN—'),
          DialogueLine(Speakers.narrator,
              'Millie doesn\'t fight; fighting would expose what she\'s hidden in their '
              'network. She presses one last crane into James\'s hand.'),
          DialogueLine(Speakers.millie, 'The Foundry. Finish it for me.'),
          DialogueLine(Speakers.james, '(reaching) MILLIE—'),
        ],
        continueLabel: 'EPISODE 4 ▶',
      )),
    ],
  );
}

LevelConfig _floodworks() {
  return LevelConfig(
    id: 'ep3_floodworks',
    character: Character.james,
    theme: DistrictTheme.sunken,
    mechanics: const {MechanicType.swim, MechanicType.climb, MechanicType.shoot, MechanicType.run},
    objective: 'Swim the nave, climb out, fight to the command post',
    bannerLine: 'Mind your breath · climb the rigging · then run the nave',
    worldWidth: 206,
    worldHeight: 42,
    killY: 46,
    start: const Pt(6, 11),
    goal: const Pt(200, 13),
    goalLabel: 'THE COMMAND POST',
    waters: const [WaterZone(x: 0, y: 8, width: 122, height: 32)],
    platforms: [
      const Platform(x: 0, y: 37, width: 122, height: 5), // drowned street floor
      const Platform(x: 28, y: 14, width: 4, height: 23), // submerged pillars
      const Platform(x: 54, y: 10, width: 4, height: 27),
      const Platform(x: 84, y: 16, width: 4, height: 21),
      const Platform(x: 106, y: 4, width: 20, height: 2), // climb-out ledge (dry)
      Build.floor(x: 126, width: 80, y: 14, depth: 10), // the nave (run/shoot)
      const Platform(x: 152, y: 8, width: 10, height: 2),
    ],
    ladders: [Build.ladder(x: 110, topY: 3, bottomY: 32)],
    hazards: const [
      Hazard(x: 40, y: 31, width: 10, height: 3), // electrified wreck
      Hazard(x: 70, y: 25, width: 8, height: 3),
    ],
    enemies: [
      ...Build.enemiesAt(EnemyKind.drone, [40, 76, 98], 14),
      ...Build.enemiesAt(EnemyKind.grunt, [140, 166, 186], 14, patrol: 5),
    ],
    pickups: const [
      PickupSpawn(PickupKind.air, x: 22, y: 12),
      PickupSpawn(PickupKind.air, x: 52, y: 14),
      PickupSpawn(PickupKind.air, x: 82, y: 12),
      PickupSpawn(PickupKind.air, x: 100, y: 10),
      PickupSpawn(PickupKind.marker, x: 132, y: 13, note: 'Paper cranes, strung like prayer flags. This is no prison.'),
    ],
    checkpoints: const [Pt(6, 10), Pt(108, 3), Pt(140, 12), Pt(180, 12)],
    npcs: const [
      NpcSpawn(NpcKind.millie, x: 194, y: 14, facing: -1, lines: [
        DialogueLine(Speakers.millie, 'You shouldn\'t be here. You of all people.'),
        DialogueLine(Speakers.james, 'They TOOK you. I came to—'),
        DialogueLine(Speakers.millie, 'Nobody took me, James. I walked in. I\'m the Ghost the whole city whispers about.'),
        DialogueLine(Speakers.millie, 'The transit collapse? Saint-Cloud clearing a harvest site. Mum and Dad were the first.'),
        DialogueLine(Speakers.millie, 'They strip the dead and dying of the Undercity for bio-data. I\'m days from burning it all down.'),
        DialogueLine(Speakers.james, '…Six months. You let me think you were—'),
        DialogueLine(Speakers.millie, 'I kept you out of it to keep you ALIVE. Go home. Please.'),
      ]),
    ],
    dialogueTriggers: const [
      DialogueTrigger(x: 6, lines: [DialogueLine(Speakers.james, 'Breath first. Then down.')]),
      DialogueTrigger(x: 60, lines: [DialogueLine(Speakers.james, 'Surface when the lungs burn. Grab the air pockets.')]),
      DialogueTrigger(x: 108, lines: [DialogueLine(Speakers.james, 'Out of the water. Climb.')]),
      DialogueTrigger(x: 130, blocking: true, lines: [
        DialogueLine(Speakers.james, 'These cranes… she made these. She\'s not locked up in here.'),
        DialogueLine(Speakers.james, 'She lives here.'),
      ]),
    ],
  );
}

LevelConfig _questionFlashback() {
  return LevelConfig(
    id: 'ep3_question_flashback',
    character: Character.millie,
    theme: DistrictTheme.lowtownNight,
    mechanics: const {MechanicType.run, MechanicType.climb},
    flashback: true,
    objective: 'Search the wreckage for Mum and Dad',
    bannerLine: 'The night everything changed.',
    worldWidth: 96,
    worldHeight: 28,
    killY: 24,
    start: const Pt(4, 10),
    goal: const Pt(88, 7),
    goalLabel: 'THE SALVAGE TAG',
    platforms: [
      Build.floor(x: 0, width: 40, y: 15, depth: 10),
      const Platform(x: 30, y: 9, width: 8, height: 1.4), // rubble to climb
      Build.floor(x: 46, width: 50, y: 13, depth: 12),
      const Platform(x: 70, y: 7, width: 10, height: 1.4),
    ],
    ladders: [Build.ladder(x: 42, topY: 8, bottomY: 15)],
    checkpoints: const [Pt(24, 11), Pt(60, 11)],
    pickups: const [
      PickupSpawn(PickupKind.marker, x: 88, y: 7,
          note: 'Not bodies. A Saint-Cloud salvage tag, where they should have been. She doesn\'t cry. She decides.'),
    ],
    dialogueTriggers: const [
      DialogueTrigger(x: 2, lines: [DialogueLine(Speakers.youngMillie, 'Mum? …Dad? Anyone—')]),
      DialogueTrigger(x: 60, lines: [
        DialogueLine(Speakers.youngMillie, 'There\'s a tag here. A company tag. Why is there a company tag…'),
      ]),
      DialogueTrigger(x: 84, blocking: true, lines: [
        DialogueLine(Speakers.youngMillie, 'Saint-Cloud. I\'ll remember that name. I\'ll remember it forever.'),
      ]),
    ],
  );
}
