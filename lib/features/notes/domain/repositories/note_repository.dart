import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/note_entity.dart';

abstract class NoteRepository {
  Stream<List<NoteEntity>> watchNotes();
  Future<Either<Failure, void>> addNote(NoteEntity note);
  Future<Either<Failure, void>> updateNote(NoteEntity note);
  Future<Either<Failure, void>> deleteNote(String noteId);
}
