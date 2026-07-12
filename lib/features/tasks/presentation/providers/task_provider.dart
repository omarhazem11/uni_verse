import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/task_remote_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';

final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  return TaskRemoteDataSourceImpl();
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(
    remoteDataSource: ref.watch(taskRemoteDataSourceProvider),
  );
});

// Live task list — the dashboard and TasksPage both watch this.
final tasksStreamProvider = StreamProvider<List<TaskEntity>>((ref) {
  return ref.watch(taskRepositoryProvider).watchTasks();
});

class TaskActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final TaskRepository _repository;

  TaskActionsNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> addTask({
    required String title,
    String? description,
    required TaskPriority priority,
    required TaskCategory category,
    DateTime? dueDate,
    Duration? reminderOffset,
  }) async {
    final task = TaskEntity(
      id: const Uuid().v4(),
      title: title,
      description: description,
      priority: priority,
      category: category,
      dueDate: dueDate,
      reminderOffset: reminderOffset,
      createdAt: DateTime.now(),
    );
    return _run(() => _repository.addTask(task));
  }

  Future<bool> updateTask(TaskEntity task) {
    return _run(() => _repository.updateTask(task));
  }

  Future<bool> toggleComplete(String taskId, bool isCompleted) {
    return _run(() => _repository.toggleComplete(taskId, isCompleted));
  }

  Future<bool> deleteTask(String taskId) {
    return _run(() => _repository.deleteTask(taskId));
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

final taskActionsProvider =
    StateNotifierProvider<TaskActionsNotifier, AsyncValue<void>>((ref) {
  return TaskActionsNotifier(ref.watch(taskRepositoryProvider));
});
