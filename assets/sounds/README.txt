Pen/highlighter: a random ~4s natural texture clip plays once per stroke
and cuts off immediately when the pen lifts (no looping, like real
pen-on-paper):

  pen_texture_1.mp3 .. pen_texture_3.mp3
  highlighter_texture_1.mp3 .. highlighter_texture_2.mp3

Eraser: NOT tied to the pan gesture — erasing is often a very brief tap,
too short for a "play then stop on release" clip to reliably be heard due
to platform playback start latency. Instead, each actual stroke deletion
fires one short one-shot clip that always plays to completion:

  erase_1.mp3 .. erase_4.mp3  (~0.2-0.26s each)

Wired up in lib/features/notes/presentation/utils/drawing_sound.dart via
the audioplayers package. Missing files fail silently — drawing still
works normally without them.

Unused leftovers from earlier iterations (erase_texture_1-3.mp3,
erase_loop_1-3.mp3, pen_loop_1-3.mp3, highlighter_loop_1-2.mp3) are
harmless to leave in this folder.
