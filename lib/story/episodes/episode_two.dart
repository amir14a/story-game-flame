import '../models/dialogue.dart';
import '../models/episode.dart';
import '../models/level_config.dart';

/// Episode 2 — "Neon Highway".
/// The Skyway · Driving · Kade, then teen Aria (flashback).
Episode buildEpisodeTwo() {
  return const Episode(
    number: 2,
    title: 'Neon Highway',
    tagline: 'THE SKYWAY · DRIVE',
    theme: DistrictTheme.skyway,
    phases: [
      CutscenePhase(
        Cutscene(
          title: 'EPISODE 2',
          location: 'LOWTOWN ON-RAMP · MINUTES LATER',
          mood: CutsceneMood.present,
          narration: [
            'Drone-spotlights rake the alleys behind Kade. The only road down to '
                'the Sunken District is the Skyway — and the only way to beat The '
                'Hollow there is to take it flat-out.',
            'He jacks an abandoned courier car at the on-ramp. The deck crackles.',
          ],
          lines: [
            DialogueLine(Speakers.echo,
                'They’ve made you. Skyway’s the only way down and they’re closing '
                'the ramps. Drive. Don’t stop for anything.'),
            DialogueLine(Speakers.kade, 'Talk later, ghost. Right pedal it is.'),
          ],
          continueLabel: 'HIT THE SKYWAY',
        ),
      ),
      LevelPhase(_skywayChase),
      CutscenePhase(
        Cutscene(
          title: 'FLASHBACK',
          location: 'THE OLD SKYWAY · THREE YEARS AGO',
          mood: CutsceneMood.flashback,
          narration: [
            'A warmer night. A borrowed car. The whole glittering Veil laid out '
                'below them, and nowhere they had to be.',
          ],
          lines: [
            DialogueLine(Speakers.aria, 'Tell me this isn’t the best view in the whole Veil.'),
            DialogueLine(Speakers.youngKade, 'Eyes on the road, you maniac!'),
            DialogueLine(Speakers.aria, 'I AM watching the road. Mostly.'),
            DialogueLine(Speakers.narrator, 'You are Aria. Take the empty Skyway and just… drive.'),
          ],
          continueLabel: 'PLAY AS ARIA',
        ),
      ),
      LevelPhase(_joyrideFlashback),
      CutscenePhase(
        Cutscene(
          title: 'EPISODE 2 — ENDING',
          location: 'THE BROKEN RAMP',
          mood: CutsceneMood.cliffhanger,
          narration: [
            'The Hollow has dropped a barricade across the ramp down. Kade floors '
                'it and crashes straight through.',
            'The car sails off the broken ramp and plunges into the black '
                'flood-water of the lower city. As it sinks, the shard finally '
                'decrypts on the dash.',
          ],
          lines: [
            DialogueLine(Speakers.narrator,
                'A photograph. Aria — gaunt, but ALIVE — timestamped YESTERDAY.'),
            DialogueLine(Speakers.narrator,
                'Below it, a Hollow manifest: “SUBJECT ECHO — DROWNED CATHEDRAL — '
                'PROCESSING IN 48:00:00.”'),
            DialogueLine(Speakers.kade,
                '(water at his chest) Yesterday. You were right here yesterday.'),
            DialogueLine(Speakers.kade, 'Hold your breath, Aria. I’m coming down.'),
          ],
          continueLabel: 'EPISODE 3 ▶',
        ),
      ),
    ],
  );
}

const LevelConfig _skywayChase = LevelConfig(
  id: 'ep2_skyway_chase',
  character: Character.kade,
  theme: DistrictTheme.skyway,
  vehicle: VehicleKind.car,
  mechanics: {MechanicType.drive},
  objective: 'Outrun The Hollow down the Skyway',
  bannerLine: 'Right pedal accelerates · A hops the car · don’t crash.',
  worldWidth: 196,
  worldHeight: 30,
  start: Pt(6, 14),
  goal: Pt(188, 15),
  goalLabel: 'THE RAMP DOWN',
  hazards: [
    Hazard(x: 0, y: 28, width: 196, height: 2), // the long fall off the Skyway
    // Barricades to hop / weave.
    Hazard(x: 44, y: 16, width: 1.6, height: 4),
    Hazard(x: 96, y: 13, width: 1.6, height: 4),
    Hazard(x: 150, y: 15, width: 1.6, height: 4),
  ],
  grounds: [
    GroundProfile([
      Pt(-4, 20), Pt(20, 19), Pt(36, 21), Pt(50, 18), Pt(62, 20),
    ]),
    GroundProfile([
      Pt(72, 20), Pt(92, 16), Pt(112, 20), Pt(128, 19), Pt(146, 21),
      Pt(166, 18), Pt(196, 18),
    ]),
  ],
  enemies: [
    EnemySpawn(EnemyKind.drone, x: 80, y: 9),
    EnemySpawn(EnemyKind.drone, x: 134, y: 9),
    EnemySpawn(EnemyKind.drone, x: 172, y: 9),
  ],
  pickups: [
    PickupSpawn(PickupKind.marker, x: 30, y: 16, note: 'Skyway sign: SUNKEN DISTRICT — RAMP CLOSED.'),
  ],
);

const LevelConfig _joyrideFlashback = LevelConfig(
  id: 'ep2_joyride_flashback',
  character: Character.aria,
  theme: DistrictTheme.skyway,
  vehicle: VehicleKind.car,
  mechanics: {MechanicType.drive},
  flashback: true,
  objective: 'Cruise the old Skyway',
  bannerLine: 'No rush tonight. Just drive.',
  worldWidth: 150,
  worldHeight: 30,
  start: Pt(6, 14),
  goal: Pt(142, 15),
  goalLabel: 'THE OVERLOOK',
  hazards: [
    Hazard(x: 0, y: 28, width: 150, height: 2),
  ],
  grounds: [
    GroundProfile([
      Pt(-4, 20), Pt(24, 18), Pt(48, 20), Pt(72, 17), Pt(96, 20),
      Pt(120, 18), Pt(150, 18),
    ]),
  ],
  pickups: [
    PickupSpawn(PickupKind.coin, x: 60, y: 16, note: 'Aria cranks the radio. Static, then a song they both know.'),
    PickupSpawn(PickupKind.coin, x: 108, y: 16, note: 'Kade hangs his arm out the window and whoops at the skyline.'),
  ],
);
