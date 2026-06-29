# NEON ECHO

A 2D cyberpunk **story game** built with **Flutter**, **Flame**, and **Forge2D**.
A brother — **Kade Vance** — hunts the neon-drowned sprawl of Nyx City for his
missing sister, **Aria**, across five continuous episodes, each ending on a
cliffhanger that opens the next. Between chapters the story falls back into the
happy past, where you play as Aria herself.

* **Display:** Landscape
* **Framework:** Flutter + Flame (`flame_forge2d` for 2D physics)
* **Language:** Dart
* **Platforms:** Android & Web
* **Art:** 100% vector — every character, vehicle, building and effect is drawn at
  runtime with Flutter `Canvas`/`CustomPaint` (no bitmap/image assets, no audio).

> The full narrative, all dialogue, and every flashback are written out in
> [`STORY.md`](STORY.md). The technical architecture is documented in
> [`DESIGN.md`](DESIGN.md).

---

## The five episodes

| # | Title | District | Mechanics | Playable |
| - | --- | --- | --- | --- |
| 1 | Signal in the Rain | Lowtown rooftops | Running, Parkour | Kade · Aria (FB) |
| 2 | Neon Highway | The Skyway | Driving | Kade · Aria (FB) |
| 3 | The Drowned District | The Sunken District | Swimming, Climbing | Kade · Aria (FB) |
| 4 | Steel Veins | The Steel Veins | Riding, Shooting | Kade · Aria (FB) |
| 5 | The Spire | The Spire | Climbing, Parkour, Shooting | Kade |

*(FB = flashback. Aria is playable only in flashbacks.)*

## Controls

The game reads **keyboard** (desktop/web) and **on-screen touch controls**
(rendered into the game HUD, for Android & web touch) simultaneously.

| Action | Keyboard | Touch |
| --- | --- | --- |
| Move / steer | `A` `D` or `←` `→` | Left joystick |
| Up / climb / swim up / accelerate | `W` or `↑` | Joystick up |
| Down / swim down / brake | `S` or `↓` | Joystick down |
| Jump / vault | `Space` | **A** button |
| Fire (shooting levels) | `J` / `K` / `Enter` | **B** button |
| Pause | `Esc` / `P` | Pause icon |

Cutscenes, dialogue, the menu and the episode-select screen are Flutter overlays —
tap / click **Continue** to advance.

---

## Running the project

```bash
# Fetch dependencies
flutter pub get

# Run on web (Chrome), forced landscape
flutter run -d chrome

# Run on a connected Android device / emulator
flutter run -d android

# Build a release web bundle
flutter build web --release

# Build a release Android APK
flutter build apk --release
```

The app locks to landscape on startup (`SystemChrome` on Android; CSS + a rotate
hint on web).

## Project layout

```
lib/
  main.dart                  App entry, landscape lock
  app.dart                   MaterialApp + GameWidget + overlay map
  core/                      Palette, config constants, input model
  story/                     Episode/cutscene/level DATA (the screenplay as code)
  engine/                    Forge2DGame, game state, scene base + level scenes
  actors/                    Players (Kade/Aria), vehicles, enemies, projectiles
  art/                       Vector drawing: characters, city, water, rain, FX
  ui/                        Flutter overlays (menu, cutscenes, HUD, endings)
```

See [`DESIGN.md`](DESIGN.md) for how these fit together.

## Notes

* No image or audio files are bundled. All visuals are procedural vector art, so
  the game is razor-sharp at any resolution and the download is tiny.
* All dialogue and narration are presented as text, per the brief.
* Built and verified with Flutter 3.44 / Dart 3.12, `flame` 1.37, `flame_forge2d`
  0.19.
