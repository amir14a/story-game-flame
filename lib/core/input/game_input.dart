/// A single mutable snapshot of player intent.
///
/// Both input sources write here and actors only read from it:
///   * the keyboard handler on [NeonEchoGame] (desktop / web), and
///   * the on-screen joystick + buttons (touch / mouse).
///
/// Keeping one aggregated model means actors never care whether a key, a thumb
/// or a mouse is driving them.
class GameInput {
  // --- keyboard contributions ---
  double _kbX = 0;
  bool _kbUp = false;
  bool _kbDown = false;
  bool _kbFire = false;
  bool _kbJumpHeld = false;

  // --- touch / pointer contributions ---
  double _touchX = 0;
  bool _touchUp = false;
  bool _touchDown = false;
  bool _touchFire = false;
  bool _touchJumpHeld = false;

  // --- jump edge detection (a press, not a hold) ---
  bool _jumpEdge = false;

  // ------------------------------------------------------------------ reads
  /// Horizontal intent in the range [-1, 1].
  double get moveX => (_kbX + _touchX).clamp(-1.0, 1.0);
  bool get up => _kbUp || _touchUp;
  bool get down => _kbDown || _touchDown;
  bool get fireHeld => _kbFire || _touchFire;
  bool get jumpHeld => _kbJumpHeld || _touchJumpHeld;

  /// Returns true exactly once per jump press, then clears the edge.
  bool consumeJump() {
    final wasPressed = _jumpEdge;
    _jumpEdge = false;
    return wasPressed;
  }

  // ----------------------------------------------------------- keyboard writes
  void setKeyboard({
    required double x,
    required bool up,
    required bool down,
    required bool fire,
    required bool jump,
  }) {
    if (jump && !_kbJumpHeld) {
      _jumpEdge = true;
    }
    _kbX = x;
    _kbUp = up;
    _kbDown = down;
    _kbFire = fire;
    _kbJumpHeld = jump;
  }

  // -------------------------------------------------------------- touch writes
  void setTouchMove(double x, {bool up = false, bool down = false}) {
    _touchX = x;
    _touchUp = up;
    _touchDown = down;
  }

  void setTouchJump(bool pressed) {
    if (pressed && !_touchJumpHeld) {
      _jumpEdge = true;
    }
    _touchJumpHeld = pressed;
  }

  void setTouchFire(bool pressed) => _touchFire = pressed;

  /// Clears every contribution. Used when swapping scenes so a held key from a
  /// cutscene cannot leak into the next level.
  void clear() {
    _kbX = _touchX = 0;
    _kbUp = _kbDown = _kbFire = _kbJumpHeld = false;
    _touchUp = _touchDown = _touchFire = _touchJumpHeld = false;
    _jumpEdge = false;
  }
}
