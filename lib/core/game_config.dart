import 'package:flame/components.dart';

/// Central tuning constants for the physics and gameplay.
///
/// All gameplay values live here so balancing never requires hunting through
/// the actor code. Distances are in Forge2D **metres**; the camera zoom maps
/// metres to on-screen pixels.
abstract final class GameConfig {
  // ---- World / camera ----------------------------------------------------
  /// Pixels per metre. Forge2D bodies are sized in metres; the camera applies
  /// this zoom so a 1m body is [zoom] pixels tall.
  static const double zoom = 32.0;

  /// Default downward gravity (m/s^2) for on-foot / vehicle levels.
  static final Vector2 gravity = Vector2(0, 30);

  /// Reduced effective gravity feel while submerged (handled via buoyancy).
  static const double waterGravityScale = 0.12;

  // ---- On-foot locomotion ------------------------------------------------
  static const double runSpeed = 9.0; // m/s target horizontal speed
  static const double runAccel = 60.0; // how fast we reach runSpeed
  static const double jumpImpulse = 11.5; // upward impulse on jump
  static const double doubleJumpImpulse = 9.5;
  static const double coyoteTime = 0.12; // seconds of post-ledge jump grace
  static const double airControl = 0.55; // horizontal control fraction in air

  // ---- Parkour -----------------------------------------------------------
  static const double wallSlideSpeed = 3.0; // max downward speed while clinging
  static const double wallJumpX = 9.0;
  static const double wallJumpY = 11.0;

  // ---- Swimming ----------------------------------------------------------
  static const double swimSpeed = 6.0;
  static const double swimAccel = 24.0;
  static const double buoyancy = 26.0; // upward accel applied in water
  static const double maxBreath = 14.0; // seconds underwater before drowning
  static const double breathRefill = 6.0; // breath/sec regained at surface

  // ---- Climbing ----------------------------------------------------------
  static const double climbSpeed = 4.5;

  // ---- Driving (car) -----------------------------------------------------
  static const double carMaxSpeed = 26.0;
  static const double carAccel = 18.0;
  static const double carBrake = 30.0;
  static const double carTurnImpulse = 7.5; // hop/dodge sideways

  // ---- Riding (bike) -----------------------------------------------------
  static const double bikeMaxSpeed = 22.0;
  static const double bikeAccel = 16.0;
  static const double bikeJumpImpulse = 10.5;

  // ---- Shooting ----------------------------------------------------------
  static const double fireCooldown = 0.22; // seconds between shots
  static const double bulletSpeed = 34.0;
  static const double bulletLife = 1.4; // seconds before despawn
  static const int bulletDamage = 1;

  // ---- Combat / health ---------------------------------------------------
  static const int playerMaxHealth = 5;
  static const double hitInvulnerability = 1.0; // i-frames after taking a hit
  static const int contactDamage = 1;

  // ---- Camera framing ----------------------------------------------------
  static const double cameraLeadY = -2.0; // look slightly above the actor
  static const double cameraMaxSpeed = 40.0;
}
