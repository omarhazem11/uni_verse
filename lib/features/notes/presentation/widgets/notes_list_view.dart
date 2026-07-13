import 'package:flutter/material.dart';
import '../../domain/entities/note_entity.dart';
import '../pages/note_editor_page.dart';
import 'note_card.dart';

class NotesListView extends StatelessWidget {
  final List<NoteEntity> notes;

  const NotesListView({super.key, required this.notes});

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
        );
      },
    );
  }
}
