import '../../domain/entities/drawing_stroke_entity.dart';
import '../../domain/entities/note_entity.dart';
import '../providers/note_provider.dart';

/// Extracted out of NoteEditorPage purely to keep that file under the
/// 150-line limit — builds and dispatches the add/update call.
/// Accepts the notifier directly so callers can capture it before
/// Navigator.pop() — WidgetRef is invalidated after the widget disposes.
Future<bool> saveNoteFromEditor({
  required NoteActionsNotifier notifier,
  required NoteEntity? existingNote,
  required String title,
  required String body,
  required List<String> tags,
  required String? linkedTaskId,
  required String colorHex,
  required List<DrawingStrokeEntity> strokes,
}) {
  if (existingNote != null) {
    return notifier.updateNote(existingNote.copyWith(
      title: title,
      body: body,
      tags: tags,
      linkedTaskId: linkedTaskId,
      clearLinkedTaskId: linkedTaskId == null,
      colorHex: colorHex,
      strokes: strokes,
    ));
  }

  return notifier.addNote(
    title: title,
    body: body,
    tags: tags,
    linkedTaskId: linkedTaskId,
    colorHex: colorHex,
    strokes: strokes,
  );
}
