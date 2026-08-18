# NEON ECHO

A 2D cyberpunk **story game** built with **Flutter**, **Flame**, and **Forge2D**.
A brother — **James Vance** — hunts the drowned neon sprawl of **Verge City** for
his missing sister **Millie**, across five continuous episodes, each ending on a
cliffhanger that opens the next — and the closer he gets, the less she is the
person he came to save. The story is told **inside the levels** (subtitles, comm
pop-ups and face-to-face meetings), and in the **flashbacks** you play as Millie.

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

Every episode combines **several** mechanics across long, checkpointed, sectioned
levels, and opens exactly where the last one cut away.

| # | Title | District | Mechanics combined | Playable |
| - | --- | --- | --- | --- |
| 1 | Breadcrumbs | The Sink | Run · Parkour · Climb · Shoot | James · Millie (FB) |
| 2 | The Loop | The Loop | Drive · Shoot · Parkour · Climb | James · Millie (FB) |
| 3 | Drowned Light | The Floodworks | Swim · Climb · Shoot · Run | James · Millie (FB) |
| 4 | The Foundry | The Foundry | Ride · Shoot · Climb · Run | James · Millie (FB) |
| 5 | Crown of Stars | The Apex | Climb · Parkour · Shoot · Swim | James · Millie (FB) |

*(FB = flashback. Millie is playable only in flashbacks; James finds her, alive,
at the very end of Episode 5.)*

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
| Advance dialogue | `Enter` / `Space` / `J` | Tap |
| Navigate menus | `↑` `↓` then `Enter` | Tap |

**Everything is keyboard-friendly:** menus, the episode-select screen and
cutscenes are all driven with the arrow keys + Enter (and still work with mouse /
touch). In-game story arrives as **ambient subtitles** while you play and **comm
pop-ups / meetings** that soft-pause the action until you advance them.

Death is forgiving on the long levels: falling off the world or hitting a hazard
costs one health point and respawns you at the **last checkpoint** (a reliable
death-plane, so a fall can never get stuck).

### Debug cheat

In **debug builds only**, the classic Konami code unlocks every episode:
`↑ ↑ ↓ ↓ ← → ← → B A`. The menu and episode-select screens show a hint for it.
It is compiled out of release builds (`kDebugMode`).

Typing `DEBUG` on the keyboard unlocks the hidden cutscene test menu — a
devtools screen for jumping straight into any cutscene in any episode. Unlike
the Konami code above, this one works in **release builds too**, since it's
the only way to reach the devtools outside of a debug build.

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

## Deploy to GitHub Pages

The web build is auto-published to GitHub Pages on every push to `main`.

* **Workflow:** [`.github/workflows/deploy-web.yml`](.github/workflows/deploy-web.yml)
  installs Flutter, runs `analyze` + `test`, builds
  `flutter build web --release --base-href "/<repo>/"`, and publishes the output
  to the **`gh-pages`** branch.
* **One-time setup:** in the repository's **Settings → Pages**, set
  *Source* to **Deploy from a branch**, branch **`gh-pages`**, folder **`/ (root)`**.
  The site then serves at `https://<owner>.github.io/<repo>/`
  (for this repo: `https://amir14a.github.io/story-game-flame/`).
* The `gh-pages` branch already contains an initial export so Pages can be
  configured immediately; the workflow keeps it up to date.
* Serving from a **custom domain at the root** instead? Change the build's
  `--base-href` to `"/"` in the workflow.

## Notes

* No image or audio files are bundled. All visuals are procedural vector art, so
  the game is razor-sharp at any resolution and the download is tiny.
* All dialogue and narration are presented as text, per the brief.
* Built and verified with Flutter 3.44 / Dart 3.12, `flame` 1.37, `flame_forge2d`
  0.19.
