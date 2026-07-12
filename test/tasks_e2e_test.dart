import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uni_verse/core/errors/failures.dart';
import 'package:uni_verse/features/tasks/domain/entities/task_entity.dart';
import 'package:uni_verse/features/tasks/domain/repositories/task_repository.dart';
import 'package:uni_verse/features/tasks/presentation/pages/tasks_page.dart';
import 'package:uni_verse/features/tasks/presentation/providers/task_provider.dart';
import 'package:uni_verse/features/tasks/presentation/widgets/task_checkbox.dart';

class FakeTaskRepository implements TaskRepository {
  final _tasks = <TaskEntity>[];
  final _controller = StreamController<List<TaskEntity>>.broadcast();

  void _emit() => _controller.add(List.unmodifiable(_tasks));

  @override
  Stream<List<TaskEntity>> watchTasks() {
    Future.microtask(_emit);
    return _controller.stream;
  }

  @override
  Future<Either<Failure, void>> addTask(TaskEntity task) async {
    _tasks.add(task);
    _emit();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateTask(TaskEntity task) async {
    final i = _tasks.indexWhere((t) => t.id == task.id);
    if (i != -1) _tasks[i] = task;
    _emit();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> toggleComplete(String taskId, bool isCompleted) async {
    final i = _tasks.indexWhere((t) => t.id == taskId);
    if (i != -1) _tasks[i] = _tasks[i].copyWith(isCompleted: isCompleted);
    _emit();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    _emit();
    return const Right(null);
  }
}

Future<FakeTaskRepository> _pumpTasksPage(WidgetTester tester) async {
  tester.view.physicalSize = const Size(400, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final fake = FakeTaskRepository();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [taskRepositoryProvider.overrideWithValue(fake)],
      child: const MaterialApp(home: TasksPage()),
    ),
  );
  await tester.pumpAndSettle();
  return fake;
}

void main() {
  testWidgets('empty state renders with Add Task button', (tester) async {
    await _pumpTasksPage(tester);
    expect(find.text('No tasks yet'), findsOneWidget);
    expect(find.text('Add your first one to get started! ✏️'), findsOneWidget);
    expect(find.text('Add Task'), findsOneWidget);
  });

  testWidgets('adding a task shows it in the list', (tester) async {
    final fake = await _pumpTasksPage(tester);

    await tester.tap(find.text('Add Task'));
    await tester.pumpAndSettle();
    expect(find.text('Add Task'), findsWidgets); // sheet header + empty-state button

    await tester.enterText(find.widgetWithText(TextField, 'Task name'), 'Finish essay');
    await tester.pump(); // let the title-listener setState (button enabled) settle
    await tester.tap(find.text('Save Task'));
    await tester.pumpAndSettle();

    expect(fake._tasks.length, 1);
    expect(fake._tasks.first.title, 'Finish essay');
    expect(find.text('Finish essay'), findsOneWidget);
    expect(find.text('No tasks yet'), findsNothing);
  });

  testWidgets('editing a task updates its title', (tester) async {
    final fake = await _pumpTasksPage(tester);
    await fake.addTask(TaskEntity(id: 't1', title: 'Original', createdAt: DateTime.now()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Original'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Task'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Task name'), 'Updated title');
    await tester.tap(find.text('Save Task'));
    await tester.pumpAndSettle();

    expect(fake._tasks.first.title, 'Updated title');
    expect(find.text('Updated title'), findsOneWidget);
    expect(find.text('Original'), findsNothing);
  });

  testWidgets('completing a task marks it done and dims it', (tester) async {
    final fake = await _pumpTasksPage(tester);
    await fake.addTask(TaskEntity(id: 't1', title: 'Do laundry', createdAt: DateTime.now()));
    await tester.pumpAndSettle();

    expect(fake._tasks.first.isCompleted, isFalse);
    await tester.tap(find.byType(TaskCheckbox));
    await tester.pumpAndSettle();

    expect(fake._tasks.first.isCompleted, isTrue);
    final text = tester.widget<Text>(find.text('Do laundry'));
    expect(text.style?.decoration, TextDecoration.lineThrough);
  });

  testWidgets('deleting a task via swipe + confirm removes it', (tester) async {
    final fake = await _pumpTasksPage(tester);
    await fake.addTask(TaskEntity(id: 't1', title: 'Delete me', createdAt: DateTime.now()));
    await tester.pumpAndSettle();

    await tester.drag(find.text('Delete me'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('Delete this task?'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(fake._tasks, isEmpty);
    expect(find.text('Delete me'), findsNothing);
    expect(find.text('No tasks yet'), findsOneWidget);
  });
}
