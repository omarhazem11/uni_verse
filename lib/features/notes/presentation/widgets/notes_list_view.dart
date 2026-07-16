import 'package:flutter/material.dart';
import '../../domain/entities/note_entity.dart';
import '../pages/note_editor_page.dart';
import 'note_card.dart';

class NotesListView extends StatelessWidget {
  final List<NoteEntity> notes;
  final bool isSelectionMode;
  final Set<String> selectedIds;
  final void Function(String id) onEnterSelectionMode;
  final void Function(String id) onToggleSelect;

  const NotesListView({
    super.key,
    required this.notes,
    this.isSelectionMode = false,
    this.selectedIds = const {},
    this.onEnterSelectionMode = _noop,
    this.onToggleSelect = _noop,
  });

  static void _noop(String _) {}

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      itemCount: notes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final note = notes[i];
        return NoteCard(
          note: note,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => NoteEditorPage(existingNote: note)),
          ),
          isSelectionMode: isSelectionMode,
          isSelected: selectedIds.contains(note.id),
          onEnterSelectionMode: () => onEnterSelectionMode(note.id),
          onToggleSelect: () => onToggleSelect(note.id),
        );
      },
    );
  }
}
