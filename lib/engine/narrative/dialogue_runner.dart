import 'package:flutter/foundation.dart';

import '../../story/models/dialogue.dart';

/// Drives in-game storytelling. Two registers:
///
/// * **Subtitles** — non-blocking ambient lines that auto-advance on a reading
///   timer while the player keeps playing.
/// * **Comm / meetings** — blocking exchanges that soft-pause the action and
///   wait for the player to press the action key (or tap) to advance.
///
/// A [ChangeNotifier] so the dialogue overlay rebuilds reactively.
class DialogueRunner extends ChangeNotifier {
  final List<DialogueLine> _queue = [];
  DialogueLine? _current;
  bool _blocking = false;
  double _timer = 0;

  /// Hooks the engine uses to soft-pause/resume during blocking dialogue.
  VoidCallback? onBlockingStart;
  VoidCallback? onBlockingEnd;

  DialogueLine? get current => _current;
  bool get isActive => _current != null;
  bool get isBlocking => _blocking && _current != null;

  /// Queue a sequence. Blocking sequences (meetings, key comms) take over and
  /// pause play; non-blocking subtitles are ignored while a blocking sequence
  /// runs, otherwise they append.
  void play(List<DialogueLine> lines, {required bool blocking}) {
    if (lines.isEmpty) {
      return;
    }
    if (blocking) {
      _queue
        ..clear()
        ..addAll(lines);
      final wasBlocking = _blocking;
      _blocking = true;
      _current = null;
      _step();
      if (!wasBlocking) {
        onBlockingStart?.call();
      }
    } else {
      if (_blocking) {
        return; // don't interrupt an important exchange with ambient chatter
      }
      _queue.addAll(lines);
      if (_current == null) {
        _step();
      }
    }
    notifyListeners();
  }

  /// Advance a blocking exchange (from the action key / tap).
  void advance() {
    if (_current == null) {
      return;
    }
    _step();
    notifyListeners();
  }

  /// Called each frame; advances non-blocking subtitles on their reading timer.
  void tick(double dt) {
    if (_current == null || _blocking) {
      return;
    }
    _timer -= dt;
    if (_timer <= 0) {
      _step();
      notifyListeners();
    }
  }

  void _step() {
    if (_queue.isEmpty) {
      _current = null;
      if (_blocking) {
        _blocking = false;
        onBlockingEnd?.call();
      }
      return;
    }
    _current = _queue.removeAt(0);
    _timer = (_current!.text.length / 24.0).clamp(2.4, 7.0);
  }

  /// Hard reset (used when a level unloads).
  void reset() {
    final wasBlocking = _blocking;
    _queue.clear();
    _current = null;
    _blocking = false;
    _timer = 0;
    if (wasBlocking) {
      onBlockingEnd?.call();
    }
    notifyListeners();
  }
}
