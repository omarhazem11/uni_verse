import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<TaskEntity>> watchTasks() {
    return remoteDataSource.watchTasks();
  }

  @override
  Future<Either<Failure, void>> addTask(TaskEntity task) async {
    try {
      await remoteDataSource.addTask(TaskModel.fromEntity(task));
      return const Right(null);
    } catch (e) {
      return Left(TaskFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTask(TaskEntity task) async {
    try {
      await remoteDataSource.updateTask(TaskModel.fromEntity(task));
      return const Right(null);
    } catch (e) {
      return Left(TaskFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleComplete(
    String taskId,
    bool isCompleted,
  ) async {
    try {
      await remoteDataSource.toggleComplete(taskId, isCompleted);
      return const Right(null);
    } catch (e) {
      return Left(TaskFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async {
    try {
      await remoteDataSource.deleteTask(taskId);
      return const Right(null);
    } catch (e) {
      return Left(TaskFailure(e.toString()));
    }
  }
}
