import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/note_remote_datasource.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/note_repository.dart';

final noteRemoteDataSourceProvider = Provider<NoteRemoteDataSource>((ref) {
  return NoteRemoteDataSourceImpl();
});

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(remoteDataSource: ref.watch(noteRemoteDataSourceProvider));
});

final notesStreamProvider = StreamProvider<List<NoteEntity>>((ref) {
  return ref.watch(noteRepositoryProvider).watchNotes();
});

final noteSearchQueryProvider = StateProvider<String>((ref) => '');

// null means "All" — no tag filter applied.
final noteTagFilterProvider = StateProvider<String?>((ref) => null);

// Most-recently-updated note linked to a given task, or null if none — lets
// task widgets show a "View notes" affordance without knowing anything
// about how notes are stored.
final noteForTaskProvider = Provider.family<NoteEntity?, String>((ref, taskId) {
  final notes = ref.watch(notesStreamProvider).value ?? [];
  final matches = notes.where((n) => n.linkedTaskId == taskId);
  return matches.isEmpty ? null : matches.first;
});

final filteredNotesProvider = Provider<List<NoteEntity>>((ref) {
  final notes = ref.watch(notesStreamProvider).value ?? [];
  final query = ref.watch(noteSearchQueryProvider).trim().toLowerCase();
  final tag = ref.watch(noteTagFilterProvider);

  return notes.where((note) {
    final matchesTag = tag == null || note.tags.contains(tag);
    if (!matchesTag) return false;
    if (query.isEmpty) return true;
    return note.title.toLowerCase().contains(query) ||
        note.body.toLowerCase().contains(query) ||
        note.tags.any((t) => t.toLowerCase().contains(query));
  }).toList();
});

class NoteActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final NoteRepository _repository;

  NoteActionsNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> addNote({
    required String title,
    required String body,
    List<String> tags = const [],
    String? linkedTaskId,
    required String colorHex,
  }) {
    final now = DateTime.now();
    final note = NoteEntity(
      id: const Uuid().v4(),
      title: title,
      body: body,
      tags: tags,
      linkedTaskId: linkedTaskId,
      colorHex: colorHex,
      createdAt: now,
      updatedAt: now,
    );
    return _run(() => _repository.addNote(note));
  }

  Future<bool> updateNote(NoteEntity note) {
    return _run(() => _repository.updateNote(note.copyWith(updatedAt: DateTime.now())));
  }

  Future<bool> deleteNote(String noteId) {
    return _run(() => _repository.deleteNote(noteId));
  }

  Future<bool> _run(Future<Either<Failure, void>> Function() action) async {
    state = const AsyncValue.loading();
    final result = await action();
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }
}

final noteActionsProvider = StateNotifierProvider<NoteActionsNotifier, AsyncValue<void>>((ref) {
  return NoteActionsNotifier(ref.watch(noteRepositoryProvider));
});
