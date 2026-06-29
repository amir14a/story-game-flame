/// Lightweight tag objects assigned to Forge2D bodies' `userData` so that
/// [ContactCallbacks] can identify what was touched with a simple `is` check.
///
/// These are intentionally *not* [ContactCallbacks] themselves — only the actor,
/// enemies, bullets and pickups react to contacts; terrain is passive.
class SolidTerrain {
  const SolidTerrain();
}

/// A body of water. Carries its [surfaceY] (world metres) so the swimmer can
/// tell when its head breaks the surface to breathe.
class WaterMarker {
  const WaterMarker(this.surfaceY);
  final double surfaceY;
}

/// A climbable rigging / ladder zone.
class LadderMarker {
  const LadderMarker();
}

/// A deadly region — touching it fails the level.
class HazardMarker {
  const HazardMarker();
}

/// The level-completion trigger.
class GoalMarker {
  const GoalMarker();
}
