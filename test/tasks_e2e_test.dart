import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uni_verse/core/errors/failures.dart';
import 'package:uni_verse/features/achievements/presentation/providers/achievements_provider.dart';
import 'package:uni_verse/features/notes/presentation/providers/note_provider.dart';
import 'package:uni_verse/features/tasks/domain/entities/task_entity.dart';
import 'package:uni_verse/features/tasks/domain/repositories/task_repository.dart';
import 'package:uni_verse/features/tasks/presentation/pages/task_detail_page.dart';
import 'package:uni_verse/features/tasks/presentation/pages/tasks_page.dart';
import 'package:uni_verse/features/tasks/presentation/providers/task_provider.dart';
import 'package:uni_verse/features/tasks/presentation/utils/task_date_format.dart';
import 'package:uni_verse/features/tasks/presentation/widgets/task_checkbox.dart';
import 'package:uni_verse/features/tasks/presentation/widgets/task_reminder_section.dart';
import 'package:uni_verse/features/tasks/presentation/widgets/task_save_button.dart';
import 'fakes/fake_achievements_datasource.dart';
import 'fakes/fake_note_datasource.dart';

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
      overrides: [
        taskRepositoryProvider.overrideWithValue(fake),
        achievementsRemoteDataSourceProvider.overrideWithValue(FakeAchievementsDataSource()),
        noteRemoteDataSourceProvider.overrideWithValue(FakeNoteRemoteDataSource()),
      ],
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

  testWidgets('tapping a task opens the detail view, not the edit sheet', (tester) async {
    final fake = await _pumpTasksPage(tester);
    await fake.addTask(TaskEntity(id: 't1', title: 'Original', createdAt: DateTime.now()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Original'));
    await tester.pumpAndSettle();

    expect(find.byType(TaskDetailPage), findsOneWidget);
    expect(find.text('Save Task'), findsNothing); // edit sheet did NOT open directly
    expect(find.text('Delete Task'), findsOneWidget);
  });

  testWidgets('edit icon on detail page opens the pre-filled edit sheet, then stays on detail',
      (tester) async {
    final fake = await _pumpTasksPage(tester);
    await fake.addTask(TaskEntity(id: 't1', title: 'Original', createdAt: DateTime.now()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Original'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Edit Task'), findsOneWidget);
    final titleField = tester.widget<TextField>(find.widgetWithText(TextField, 'Task name'));
    expect(titleField.controller?.text, 'Original');

    await tester.enterText(find.widgetWithText(TextField, 'Task name'), 'Updated title');
    await tester.pump();
    await tester.tap(find.text('Save Task'));
    await tester.pumpAndSettle();

    expect(fake._tasks.first.title, 'Updated title');
    // Stays on the detail page (not popped back to the list) with fresh
    // data — both the app bar title and the header title reflect it.
    expect(find.byType(TaskDetailPage), findsOneWidget);
    expect(find.text('Updated title'), findsWidgets);
  });

  testWidgets('checkbox on the list toggles completion without navigating', (tester) async {
    final fake = await _pumpTasksPage(tester);
    await fake.addTask(TaskEntity(id: 't1', title: 'Do laundry', createdAt: DateTime.now()));
    await tester.pumpAndSettle();

    expect(fake._tasks.first.isCompleted, isFalse);
    await tester.tap(find.byType(TaskCheckbox));
    await tester.pumpAndSettle();

    expect(fake._tasks.first.isCompleted, isTrue);
    expect(find.byType(TaskDetailPage), findsNothing); // still on the list
    final text = tester.widget<Text>(find.text('Do laundry'));
    expect(text.style?.decoration, TextDecoration.lineThrough);
  });

  testWidgets('delete works from the detail page and returns to the list', (tester) async {
    final fake = await _pumpTasksPage(tester);
    await fake.addTask(TaskEntity(id: 't1', title: 'Delete me', createdAt: DateTime.now()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete me'));
    await tester.pumpAndSettle();
    expect(find.byType(TaskDetailPage), findsOneWidget);

    await tester.tap(find.text('Delete Task'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this task?'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(fake._tasks, isEmpty);
    expect(find.byType(TaskDetailPage), findsNothing);
    expect(find.text('No tasks yet'), findsOneWidget);
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

  group('customReminderIsValid', () {
    final dueDate = DateTime(2026, 1, 20);

    test('a custom reminder before the due date is valid', () {
      final result = customReminderIsValid(
        isCustom: true,
        customReminderDateTime: DateTime(2026, 1, 15, 9),
        dueDate: dueDate,
      );
      expect(result, isTrue);
    });

    test('a custom reminder after the due date is invalid', () {
      final result = customReminderIsValid(
        isCustom: true,
        customReminderDateTime: DateTime(2026, 1, 25, 9),
        dueDate: dueDate,
      );
      expect(result, isFalse);
    });

    test('custom mode with no date/time picked yet is invalid', () {
      final result = customReminderIsValid(
        isCustom: true,
        customReminderDateTime: null,
        dueDate: dueDate,
      );
      expect(result, isFalse);
    });

    test('same day as a time-less due date is valid at any time', () {
      // dueDate has no time component (always midnight in this app), so a
      // same-day reminder at any hour must not be rejected just for being
      // "after midnight".
      final result = customReminderIsValid(
        isCustom: true,
        customReminderDateTime: DateTime(2026, 1, 20, 23, 59),
        dueDate: dueDate,
      );
      expect(result, isTrue);
    });

    test('same day as a due date WITH a time component, before that time, is valid', () {
      final dueDateWithTime = DateTime(2026, 1, 20, 14, 0);
      final result = customReminderIsValid(
        isCustom: true,
        customReminderDateTime: DateTime(2026, 1, 20, 10, 0),
        dueDate: dueDateWithTime,
      );
      expect(result, isTrue);
    });

    test('same day as a due date WITH a time component, after that time, is invalid', () {
      final dueDateWithTime = DateTime(2026, 1, 20, 14, 0);
      final result = customReminderIsValid(
        isCustom: true,
        customReminderDateTime: DateTime(2026, 1, 20, 18, 0),
        dueDate: dueDateWithTime,
      );
      expect(result, isFalse);
    });

    test('preset mode is always valid regardless of dates', () {
      final result = customReminderIsValid(
        isCustom: false,
        customReminderDateTime: DateTime(2026, 1, 25, 9),
        dueDate: dueDate,
      );
      expect(result, isTrue);
    });
  });

  testWidgets('a valid custom reminder set before the due date displays correctly on the detail page',
      (tester) async {
    final fake = await _pumpTasksPage(tester);
    final dueDate = DateTime.now().add(const Duration(days: 10));
    final reminderTime = DateTime.now().add(const Duration(days: 5, hours: 3));
    await fake.addTask(TaskEntity(
      id: 't1',
      title: 'Study for exam',
      dueDate: dueDate,
      reminderOffset: null,
      customReminderDateTime: reminderTime,
      createdAt: DateTime.now(),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Study for exam'));
    await tester.pumpAndSettle();

    expect(find.text('Reminder: ${shortDateTimeLabel(reminderTime)}'), findsOneWidget);
  });

  testWidgets('editing a task with a valid custom reminder shows it pre-selected and Save works',
      (tester) async {
    final fake = await _pumpTasksPage(tester);
    final dueDate = DateTime.now().add(const Duration(days: 10));
    final reminderTime = DateTime.now().add(const Duration(days: 5, hours: 3));
    await fake.addTask(TaskEntity(
      id: 't1',
      title: 'Study for exam',
      dueDate: dueDate,
      reminderOffset: null,
      customReminderDateTime: reminderTime,
      createdAt: DateTime.now(),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Study for exam'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Custom...'), findsOneWidget);
    expect(find.text(shortDateLabel(reminderTime)), findsOneWidget);
    expect(find.text(shortTimeLabel(reminderTime)), findsOneWidget);
    expect(find.text('Reminder must be before the due date'), findsNothing);

    final saveButton = tester.widget<TaskSaveButton>(find.byType(TaskSaveButton));
    expect(saveButton.enabled, isTrue);

    await tester.tap(find.text('Save Task'));
    await tester.pumpAndSettle();

    expect(fake._tasks.first.customReminderDateTime, reminderTime);
    expect(find.byType(TaskDetailPage), findsOneWidget); // stayed on detail after save
  });

  testWidgets('a custom reminder after the due date shows an inline error and disables Save',
      (tester) async {
    final fake = await _pumpTasksPage(tester);
    final dueDate = DateTime.now().add(const Duration(days: 5));
    final invalidReminder = DateTime.now().add(const Duration(days: 10)); // after due date
    await fake.addTask(TaskEntity(
      id: 't1',
      title: 'Bad reminder task',
      dueDate: dueDate,
      reminderOffset: null,
      customReminderDateTime: invalidReminder,
      createdAt: DateTime.now(),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bad reminder task'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Reminder must be before the due date'), findsOneWidget);
    final saveButton = tester.widget<TaskSaveButton>(find.byType(TaskSaveButton));
    expect(saveButton.enabled, isFalse);

    // Tapping a disabled button is a no-op — the task stays unchanged.
    await tester.tap(find.text('Save Task'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(fake._tasks.first.customReminderDateTime, invalidReminder);
    expect(find.text('Save Task'), findsOneWidget); // sheet is still open
  });

  testWidgets('a custom reminder on the same day as the due date is accepted, not blocked',
      (tester) async {
    final fake = await _pumpTasksPage(tester);
    // Construct a midnight due date directly (bypassing the picker UI) to
    // exercise the legacy "due date with no time component" branch of
    // customReminderIsValid — still reachable for older records even
    // though the picker now always attaches a real time.
    final tenDaysOut = DateTime.now().add(const Duration(days: 10));
    final dueDate = DateTime(tenDaysOut.year, tenDaysOut.month, tenDaysOut.day);
    final sameDayReminder = DateTime(dueDate.year, dueDate.month, dueDate.day, 15, 0);
    await fake.addTask(TaskEntity(
      id: 't1',
      title: 'Same day reminder',
      dueDate: dueDate,
      reminderOffset: null,
      customReminderDateTime: sameDayReminder,
      createdAt: DateTime.now(),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Same day reminder'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Reminder must be before the due date'), findsNothing);
    final saveButton = tester.widget<TaskSaveButton>(find.byType(TaskSaveButton));
    expect(saveButton.enabled, isTrue);
  });

  testWidgets('selecting Custom... and confirming the time picker updates the time button',
      (tester) async {
    final fake = await _pumpTasksPage(tester);
    await fake.addTask(TaskEntity(
      id: 't1',
      title: 'Pick a custom time',
      dueDate: DateTime.now().add(const Duration(days: 10)),
      reminderOffset: const Duration(days: 1),
      createdAt: DateTime.now(),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pick a custom time'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.text('1 day before'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Custom...').last);
    await tester.pumpAndSettle();

    expect(find.text('Pick date'), findsOneWidget);
    expect(find.text('Pick time'), findsOneWidget);

    await tester.tap(find.text('Pick time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // The time button no longer shows the placeholder — a real time got wired through.
    expect(find.text('Pick time'), findsNothing);
  });
}
