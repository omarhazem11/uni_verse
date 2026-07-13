import 'dart:async';

import 'package:uni_verse/features/notes/data/datasources/note_remote_datasource.dart';
import 'package:uni_verse/features/notes/data/models/note_model.dart';

/// Shared in-memory notes datasource for tests that pump DashboardPage /
/// DashboardTileGrid — those now watch notesStreamProvider for the tile
/// subtitle, which otherwise hits real Firestore/Auth in a test environment.
class FakeNoteRemoteDataSource implements NoteRemoteDataSource {
  final _notes = <String, NoteModel>{};
  final _controller = StreamController<List<NoteModel>>.broadcast();

  void _emit() {
    final list = _notes.values.toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _controller.add(list);
  }

  @override
  Stream<List<NoteModel>> watchNotes() {
    Future.microtask(_emit);
    return _controller.stream;
  }

  @override
  Future<void> addNote(NoteModel note) async {
    _notes[note.id] = note;
    _emit();
  }

  @override
  Future<void> updateNote(NoteModel note) async {
    _notes[note.id] = note;
    _emit();
  }

  @override
  Future<void> deleteNote(String noteId) async {
    _notes.remove(noteId);
    _emit();
  }
}
