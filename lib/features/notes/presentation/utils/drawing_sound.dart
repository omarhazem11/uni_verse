import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

/// SFX for drawing actions.
///
/// Pen/highlighter: a random ~4s natural texture clip plays once per stroke
/// and is cut off immediately when the pen lifts, like real pen-on-paper.
///
/// Eraser: intentionally NOT tied to the pan gesture's lifecycle. Erasing is
/// often a very brief tap — playing then stopping almost immediately (tied
/// to onPanStart/onPanEnd) risks the platform's playback start latency
/// swallowing the sound before it's ever audible. Instead, each actual
/// stroke deletion fires a short one-shot clip (~0.2-0.26s) that always
/// plays to completion, via a small round-robin player pool so rapid
/// deletions during a fast drag can overlap instead of cutting each other
/// off.
///
/// Expects `assets/sounds/pen_texture_1..3.mp3`, `highlighter_texture_1..2.mp3`,
/// and `erase_1..4.mp3` (see assets/sounds/README.txt). Missing files fail
/// silently.
class DrawingSound {
  DrawingSound._();

  static const _penFiles = ['pen_texture_1.mp3', 'pen_texture_2.mp3', 'pen_texture_3.mp3'];
  static const _highlighterFiles = ['highlighter_texture_1.mp3', 'highlighter_texture_2.mp3'];
  static const _eraseFiles = ['erase_1.mp3', 'erase_2.mp3', 'erase_3.mp3', 'erase_4.mp3'];

  static final _random = Random();
  static int? _lastPenIndex;
  static int? _lastHighlighterIndex;
  static int? _lastEraseIndex;

  // One reused player for pen/highlighter (only one stroke is ever active
  // at a time). Erase gets a small round-robin pool instead, since multiple
  // deletions in quick succession are meant to be able to overlap.
  static final _strokePlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final _erasePool = List.generate(4, (_) => AudioPlayer()..setReleaseMode(ReleaseMode.stop));
  static int _erasePoolIndex = 0;

  static bool _strokePlaying = false;

  /// Starts the pen/highlighter texture for a new stroke — call once at
  /// gesture start; picks a random variant (not repeating the last one).
  static Future<void> startStroke({required bool isHighlighter}) async {
    final files = isHighlighter ? _highlighterFiles : _penFiles;
    final index = _pickIndex(files.length, isHighlighter ? _lastHighlighterIndex : _lastPenIndex);
    if (isHighlighter) {
      _lastHighlighterIndex = index;
    } else {
      _lastPenIndex = index;
    }
    _strokePlaying = true;
    try {
      await _strokePlayer.stop();
      await _strokePlayer.play(AssetSource('sounds/${files[index]}'), volume: 0.6);
    } catch (_) {
      // Asset not present or failed to load — drawing still works silently.
    }
  }

  /// Call on gesture end for a clean, immediate cut the moment the pen
  /// lifts, even if the ~4s clip hasn't finished playing yet.
  static Future<void> stopStroke() async {
    if (!_strokePlaying) return;
    _strokePlaying = false;
    try {
      await _strokePlayer.stop();
    } catch (_) {}
  }

  /// Call exactly once per stroke actually deleted by the eraser. Always
  /// plays its short clip to completion regardless of gesture duration —
  /// deliberately independent of onPanEnd.
  static Future<void> eraseDeleted() async {
    final index = _pickIndex(_eraseFiles.length, _lastEraseIndex);
    _lastEraseIndex = index;
    final player = _erasePool[_erasePoolIndex];
    _erasePoolIndex = (_erasePoolIndex + 1) % _erasePool.length;
    try {
      await player.stop();
      await player.play(AssetSource('sounds/${_eraseFiles[index]}'), volume: 0.6);
    } catch (_) {}
  }

  // Avoids repeating the same clip twice in a row when there's more than
  // one to choose from.
  static int _pickIndex(int length, int? last) {
    if (length <= 1) return 0;
    var index = _random.nextInt(length);
    if (index == last) index = (index + 1) % length;
    return index;
  }
}
