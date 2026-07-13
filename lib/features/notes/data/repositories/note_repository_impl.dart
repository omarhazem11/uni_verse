import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/note_remote_datasource.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteRemoteDataSource remoteDataSource;

  NoteRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<NoteEntity>> watchNotes() {
    return remoteDataSource.watchNotes();
  }

  @override
  Future<Either<Failure, void>> addNote(NoteEntity note) async {
    try {
      await remoteDataSource.addNote(NoteModel.fromEntity(note));
      return const Right(null);
    } catch (e) {
      return Left(NoteFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateNote(NoteEntity note) async {
    try {
      await remoteDataSource.updateNote(NoteModel.fromEntity(note));
      return const Right(null);
    } catch (e) {
      return Left(NoteFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNote(String noteId) async {
    try {
      await remoteDataSource.deleteNote(noteId);
      return const Right(null);
    } catch (e) {
      return Left(NoteFailure(e.toString()));
    }
  }
}
