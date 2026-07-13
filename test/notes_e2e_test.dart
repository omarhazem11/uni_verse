import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uni_verse/core/errors/failures.dart';
import 'package:uni_verse/features/notes/presentation/pages/note_editor_page.dart';
import 'package:uni_verse/features/notes/presentation/pages/notes_page.dart';
import 'package:uni_verse/features/notes/presentation/providers/note_provider.dart';
import 'package:uni_verse/features/notes/presentation/widgets/note_card.dart';
import 'package:uni_verse/features/tasks/domain/entities/task_entity.dart';
import 'package:uni_verse/features/tasks/domain/repositories/task_repository.dart';
import 'package:uni_verse/features/tasks/presentation/providers/task_provider.dart';
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
  Future<Either<Failure, void>> updateTask(TaskEntity task) async => const Right(null);

  @override
  Future<Either<Failure, void>> toggleComplete(String taskId, bool isCompleted) async => const Right(null);

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async => const Right(null);
}

Future<FakeNoteRemoteDataSource> _pumpNotesPage(WidgetTester tester, {FakeTaskRepository? taskRepo}) async {
  tester.view.physicalSize = const Size(400, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final fake = FakeNoteRemoteDataSource();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        noteRemoteDataSourceProvider.overrideWithValue(fake),
        taskRepositoryProvider.overrideWithValue(taskRepo ?? FakeTaskRepository()),
      ],
      child: const MaterialApp(home: NotesPage()),
    ),
  );
  await tester.pumpAndSettle();
  return fake;
}

Future<void> _fillAndSave(WidgetTester tester, {required String title, String body = ''}) async {
  await tester.enterText(find.byType(TextField).at(0), title);
  if (body.isNotEmpty) {
    await tester.enterText(find.byType(TextField).at(1), body);
  }
  await tester.tap(find.byKey(const Key('noteEditorSaveButton')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('empty state shows and creating a note adds it to the list', (tester) async {
    await _pumpNotesPage(tester);
    expect(find.textContaining('No notes yet'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(NoteEditorPage), findsOneWidget);

    await _fillAndSave(tester, title: 'Chem notes', body: 'Covalent bonds share electrons.');
    expect(find.byType(NotesPage), findsOneWidget);
    expect(find.text('Chem notes'), findsOneWidget);
  });

  testWidgets('editing a note updates it in the list', (tester) async {
    await _pumpNotesPage(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await _fillAndSave(tester, title: 'Original title');
    expect(find.text('Original title'), findsOneWidget);

    await tester.tap(find.byType(NoteCard));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Updated title');
    await tester.tap(find.byKey(const Key('noteEditorSaveButton')));
    await tester.pumpAndSettle();

    expect(find.text('Updated title'), findsOneWidget);
    expect(find.text('Original title'), findsNothing);
  });

  testWidgets('tagging a note shows the tag on the card and in the filter row, and filters by it',
      (tester) async {
    await _pumpNotesPage(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Math notes');

    await tester.tap(find.text('+ New tag'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Math');
    await tester.tap(find.widgetWithText(TextButton, 'Add'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('noteEditorSaveButton')));
    await tester.pumpAndSettle();

    // Tag appears on the card and as a filter chip ("Math" shows up twice:
    // once on the card, once in the filter row).
    expect(find.text('Math'), findsNWidgets(2));

    await tester.tap(find.text('Math').last);
    await tester.pumpAndSettle();
    expect(find.text('Math notes'), findsOneWidget);
  });

  testWidgets('linking a note to a task shows the link indicator and the task chip', (tester) async {
    final taskRepo = FakeTaskRepository();
    await taskRepo.addTask(TaskEntity(id: 't1', title: 'Finish essay', createdAt: DateTime.now()));
    await _pumpNotesPage(tester, taskRepo: taskRepo);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Essay ideas');

    await tester.tap(find.text('Link to a task'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish essay'));
    await tester.pumpAndSettle();

    expect(find.text('Finish essay'), findsOneWidget);

    await tester.tap(find.byKey(const Key('noteEditorSaveButton')));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.link_rounded), findsOneWidget);
  });

  testWidgets('searching filters the list by title/body/tag match', (tester) async {
    await _pumpNotesPage(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await _fillAndSave(tester, title: 'Physics recap', body: 'Newtons laws');

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await _fillAndSave(tester, title: 'Grocery list', body: 'Milk and eggs');

    await tester.tap(find.byIcon(Icons.search_rounded));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'newton');
    await tester.pumpAndSettle();

    expect(find.text('Physics recap'), findsOneWidget);
    expect(find.text('Grocery list'), findsNothing);
  });

  testWidgets('deleting a note removes it from the list', (tester) async {
    await _pumpNotesPage(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await _fillAndSave(tester, title: 'Temporary note');
    expect(find.text('Temporary note'), findsOneWidget);

    await tester.tap(find.byType(NoteCard));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.byType(NotesPage), findsOneWidget);
    expect(find.text('Temporary note'), findsNothing);
    expect(find.textContaining('No notes yet'), findsOneWidget);
  });
}
