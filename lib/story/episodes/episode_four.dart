import '../models/dialogue.dart';
import '../models/episode.dart';
import '../models/level_config.dart';

/// Episode 4 — "Steel Veins".
/// The Steel Veins · Riding + Shooting · Kade, then Aria (the night she vanished).
Episode buildEpisodeFour() {
  return const Episode(
    number: 4,
    title: 'Steel Veins',
    tagline: 'THE STEEL VEINS · RIDE · SHOOT',
    theme: DistrictTheme.steelVeins,
    phases: [
      CutscenePhase(
        Cutscene(
          title: 'EPISODE 4',
          location: 'THE STEEL VEINS',
          mood: CutsceneMood.present,
          narration: [
            'The only fast road from the Sunken District to the Spire runs through '
                'the Steel Veins — Halcyon’s industrial spine, crawling with Hollow '
                'riders hunting the fugitive “Echo.”',
            'Kade hot-wires a courier motorcycle.',
          ],
          lines: [
            DialogueLine(Speakers.kade,
                'Hold on, Aria. For once, let me be the one who finds you.'),
            DialogueLine(Speakers.narrator,
                'Ride fast. Use B (or J) to shoot the riders off your tail.'),
          ],
          continueLabel: 'RIDE',
        ),
      ),
      LevelPhase(_steelVeinsRide),
      CutscenePhase(
        Cutscene(
          title: 'FLASHBACK',
          location: 'THE LOWTOWN APARTMENT · FOUR MONTHS AGO',
          mood: CutsceneMood.flashback,
          narration: [
            'The night everything broke. It starts the way every night did — the '
                'two of them home, safe.',
            'Then Aria’s deck finishes decrypting the file. She understands what '
                'it means. And she makes the hardest choice: leave, before they '
                'trace it to Kade.',
          ],
          lines: [
            DialogueLine(Speakers.aria, '(reading) …the transit accident wasn’t an accident. Halcyon. It was Halcyon.'),
            DialogueLine(Speakers.aria, 'If they find this on me, they leave him alone. That’s the deal I make. Right now.'),
            DialogueLine(Speakers.narrator, 'You are Aria. Slip out of the apartment without waking your brother.'),
          ],
          continueLabel: 'PLAY AS ARIA',
        ),
      ),
      LevelPhase(_theNightFlashback),
      CutscenePhase(
        Cutscene(
          title: 'EPISODE 4 — ENDING',
          location: 'THE FOOT OF THE SPIRE',
          mood: CutsceneMood.cliffhanger,
          narration: [
            'Kade rides straight into a trap. Floodlights. His bike skids out '
                'beneath him. Vex Mercer stands waiting, calm in the rain.',
          ],
          lines: [
            DialogueLine(Speakers.vex,
                'Kade Vance. The devoted brother. We let you live this long '
                'because you make excellent bait.'),
            DialogueLine(Speakers.vex,
                '“Echo” is upstairs right now, walking into my building of her own '
                'free will to play hero. She’ll reach the data-core in minutes.'),
            DialogueLine(Speakers.vex, 'And then we’ll have you both.'),
            DialogueLine(Speakers.narrator,
                'Kade looks up the impossible height of the Spire — the top of the '
                'world — kicks the downed bike into a guard, and breaks for the doors.'),
            DialogueLine(Speakers.kade, 'She kept the promise. Now I climb.'),
          ],
          continueLabel: 'EPISODE 5 ▶',
        ),
      ),
    ],
  );
}

const LevelConfig _steelVeinsRide = LevelConfig(
  id: 'ep4_steel_veins_ride',
  character: Character.kade,
  theme: DistrictTheme.steelVeins,
  vehicle: VehicleKind.bike,
  mechanics: {MechanicType.bike, MechanicType.shoot},
  objective: 'Ride to the Spire — shoot the Hollow riders off your tail',
  bannerLine: 'Right pedal rides · A hops · B / J shoots forward.',
  worldWidth: 208,
  worldHeight: 30,
  start: Pt(6, 14),
  goal: Pt(200, 15),
  goalLabel: 'THE SPIRE BASE',
  hazards: [
    Hazard(x: 0, y: 28, width: 208, height: 2),
    Hazard(x: 52, y: 16, width: 1.6, height: 4),
    Hazard(x: 132, y: 15, width: 1.6, height: 4),
  ],
  grounds: [
    GroundProfile([
      Pt(-4, 20), Pt(22, 19), Pt(40, 21), Pt(56, 18), Pt(70, 20),
    ]),
    GroundProfile([
      Pt(80, 20), Pt(100, 17), Pt(120, 20), Pt(140, 19), Pt(160, 21),
      Pt(182, 18), Pt(208, 18),
    ]),
  ],
  enemies: [
    EnemySpawn(EnemyKind.rider, x: 34, y: 16),
    EnemySpawn(EnemyKind.drone, x: 64, y: 9),
    EnemySpawn(EnemyKind.rider, x: 104, y: 14),
    EnemySpawn(EnemyKind.drone, x: 124, y: 9),
    EnemySpawn(EnemyKind.rider, x: 168, y: 16),
    EnemySpawn(EnemyKind.drone, x: 188, y: 9),
  ],
  pickups: [
    PickupSpawn(PickupKind.marker, x: 44, y: 16, note: 'A gantry sign: HALCYON DYNAMICS — RESTRICTED.'),
  ],
);

const LevelConfig _theNightFlashback = LevelConfig(
  id: 'ep4_the_night_flashback',
  character: Character.aria,
  theme: DistrictTheme.lowtownNight,
  mechanics: {MechanicType.run, MechanicType.parkour},
  flashback: true,
  objective: 'Slip out without waking Kade',
  bannerLine: 'One last quiet walk through home.',
  worldWidth: 92,
  worldHeight: 24,
  start: Pt(4, 12),
  goal: Pt(86, 12),
  goalLabel: 'THE DOOR',
  hazards: [
    Hazard(x: 0, y: 22, width: 92, height: 2),
  ],
  platforms: [
    Platform(x: 0, y: 15, width: 28, height: 9), // the apartment floor
    Platform(x: 34, y: 15, width: 22, height: 9), // hallway
    Platform(x: 62, y: 15, width: 30, height: 9), // the landing
    Platform(x: 24, y: 9, width: 8, height: 1.2), // a shelf to vault
  ],
  pickups: [
    PickupSpawn(PickupKind.coin, x: 18, y: 14, note: 'The lucky coin, on the shelf by Kade’s door. Aria leaves it. For luck.'),
    PickupSpawn(PickupKind.marker, x: 48, y: 14, note: 'A note on the table: “Climb to the top of the world. I’ll find you there. — A.”'),
    PickupSpawn(PickupKind.marker, x: 86, y: 12, note: 'She pauses at his door, then steps into the dark.'),
  ],
);
