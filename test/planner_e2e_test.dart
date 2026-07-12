import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uni_verse/core/errors/failures.dart';
import 'package:uni_verse/core/theme/app_colors.dart';
import 'package:uni_verse/features/planner/domain/entities/planner_settings_entity.dart';
import 'package:uni_verse/features/planner/domain/entities/schedule_item_entity.dart';
import 'package:uni_verse/features/planner/domain/repositories/planner_repository.dart';
import 'package:uni_verse/features/planner/presentation/pages/month_calendar_page.dart';
import 'package:uni_verse/features/planner/presentation/pages/planner_page.dart';
import 'package:uni_verse/features/planner/presentation/providers/planner_provider.dart';
import 'package:uni_verse/features/planner/presentation/utils/timeline_math.dart';
import 'package:uni_verse/features/planner/presentation/widgets/duplicate_day_sheet.dart';
import 'package:uni_verse/features/planner/presentation/widgets/task_timeline_block.dart';
import 'package:uni_verse/features/tasks/domain/entities/task_entity.dart';
import 'package:uni_verse/features/tasks/presentation/pages/task_detail_page.dart';
import 'package:uni_verse/features/tasks/presentation/providers/task_provider.dart';

class FakePlannerRepository implements PlannerRepository {
  final items = <ScheduleItemEntity>[];
  final _itemsController = StreamController<List<ScheduleItemEntity>>.broadcast();
  var settings = const PlannerSettingsEntity();
  final _settingsController = StreamController<PlannerSettingsEntity>.broadcast();
  var _dupCounter = 0;

  bool _sameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
  void _emitItems() => _itemsController.add(List.unmodifiable(items));
  void _emitSettings() => _settingsController.add(settings);

  @override
  Stream<List<ScheduleItemEntity>> watchItemsForDate(DateTime date) {
    Future.microtask(_emitItems);
    return _itemsController.stream.map((all) => all.where((i) => _sameDate(i.date, date)).toList());
  }

  @override
  Stream<List<ScheduleItemEntity>> watchItemsInRange(DateTime start, DateTime end) {
    Future.microtask(_emitItems);
    return _itemsController.stream
        .map((all) => all.where((i) => !i.date.isBefore(start) && !i.date.isAfter(end)).toList());
  }

  @override
  Future<Either<Failure, void>> addItem(ScheduleItemEntity item) async {
    items.add(item);
    _emitItems();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateItem(ScheduleItemEntity item) async {
    final i = items.indexWhere((x) => x.id == item.id);
    if (i != -1) items[i] = item;
    _emitItems();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteItem(String itemId) async {
    items.removeWhere((x) => x.id == itemId);
    _emitItems();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> duplicateItemsToDate(
    DateTime sourceDate,
    List<DateTime> targetDates,
  ) async {
    final sourceItems = items.where((i) => _sameDate(i.date, sourceDate)).toList();
    for (final target in targetDates) {
      final offset = DateTime(target.year, target.month, target.day)
          .difference(DateTime(sourceDate.year, sourceDate.month, sourceDate.day));
      for (final item in sourceItems) {
        items.add(ScheduleItemEntity(
          id: 'dup-${_dupCounter++}',
          title: item.title,
          description: item.description,
          date: DateTime(target.year, target.month, target.day),
          startTime: item.startTime.add(offset),
          endTime: item.endTime.add(offset),
          colorHex: item.colorHex,
          emoji: item.emoji,
          createdAt: DateTime.now(),
        ));
      }
    }
    _emitItems();
    return const Right(null);
  }

  @override
  Stream<PlannerSettingsEntity> watchSettings() {
    Future.microtask(_emitSettings);
    return _settingsController.stream;
  }

  @override
  Future<Either<Failure, void>> updateSettings(PlannerSettingsEntity newSettings) async {
    settings = newSettings;
    _emitSettings();
    return const Right(null);
  }
}

Future<FakePlannerRepository> _pumpPlannerPage(WidgetTester tester, {List<TaskEntity>? tasks}) async {
  tester.view.physicalSize = const Size(400, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final fake = FakePlannerRepository();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        plannerRepositoryProvider.overrideWithValue(fake),
        tasksStreamProvider.overrideWith((ref) => Stream.value(tasks ?? <TaskEntity>[])),
      ],
      child: const MaterialApp(home: PlannerPage()),
    ),
  );
  await tester.pumpAndSettle();
  return fake;
}

void main() {
  testWidgets('empty day shows the encouraging empty state', (tester) async {
    await _pumpPlannerPage(tester);
    expect(find.textContaining('Nothing planned yet'), findsOneWidget);
  });

  testWidgets('adding an item to the timeline shows it', (tester) async {
    final fake = await _pumpPlannerPage(tester);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Study session');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(fake.items.length, 1);
    expect(fake.items.first.title, 'Study session');
    expect(find.textContaining('Study session'), findsOneWidget);
  });

  testWidgets('editing an item updates its title on the timeline', (tester) async {
    final fake = await _pumpPlannerPage(tester);
    final today = DateTime.now();
    await fake.addItem(ScheduleItemEntity(
      id: 'i1',
      title: 'Original block',
      date: DateTime(today.year, today.month, today.day),
      startTime: DateTime(today.year, today.month, today.day, 9),
      endTime: DateTime(today.year, today.month, today.day, 10),
      colorHex: '#6C3BFF',
      emoji: '📚',
      createdAt: today,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Original block'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Schedule Item'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Updated block');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(fake.items.first.title, 'Updated block');
    expect(find.textContaining('Updated block'), findsOneWidget);
    expect(find.textContaining('Original block'), findsNothing);
  });

  testWidgets('long-press and confirm deletes an item', (tester) async {
    final fake = await _pumpPlannerPage(tester);
    final today = DateTime.now();
    await fake.addItem(ScheduleItemEntity(
      id: 'i1',
      title: 'Delete me block',
      date: DateTime(today.year, today.month, today.day),
      startTime: DateTime(today.year, today.month, today.day, 9),
      endTime: DateTime(today.year, today.month, today.day, 10),
      colorHex: '#6C3BFF',
      emoji: '📚',
      createdAt: today,
    ));
    await tester.pumpAndSettle();

    await tester.longPress(find.textContaining('Delete me block'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this item?'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(fake.items, isEmpty);
    expect(find.textContaining('Delete me block'), findsNothing);
  });

  testWidgets('tapping a different day in the date strip shows the Today pill', (tester) async {
    await _pumpPlannerPage(tester);
    expect(find.text('Today'), findsNothing); // starts on today, no pill

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    await tester.tap(find.text('${tomorrow.day}').first);
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('tapping Today after navigating away returns to today', (tester) async {
    await _pumpPlannerPage(tester);
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    await tester.tap(find.text('${tomorrow.day}').first);
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsOneWidget);

    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsNothing);
  });

  testWidgets('opening month calendar and tapping a date navigates back with it selected',
      (tester) async {
    await _pumpPlannerPage(tester);

    await tester.tap(find.byIcon(Icons.calendar_month_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(MonthCalendarPage), findsOneWidget);

    final targetDay = DateTime.now().add(const Duration(days: 2));
    // The calendar and date strip could show overlapping day numbers, so
    // scope the tap to the calendar's grid specifically.
    await tester.tap(find.descendant(
      of: find.byType(MonthCalendarPage),
      matching: find.text('${targetDay.day}'),
    ).first);
    await tester.pumpAndSettle();

    expect(find.byType(MonthCalendarPage), findsNothing); // back on PlannerPage
    expect(find.text('Today'), findsOneWidget); // selection moved off today
  });

  testWidgets('setting day boundaries persists through the settings sheet', (tester) async {
    final fake = await _pumpPlannerPage(tester);
    // Go through the public updateSettings() call (not the raw field) so
    // it actually emits on the stream the sheet is watching.
    await fake.updateSettings(const PlannerSettingsEntity(dayStartMinutes: 480, dayEndMinutes: 1200));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Day settings'));
    await tester.pumpAndSettle();

    expect(find.text('8:00 AM'), findsOneWidget); // 480 minutes
    expect(find.text('8:00 PM'), findsOneWidget); // 1200 minutes

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(fake.settings.dayStartMinutes, 480);
    expect(fake.settings.dayEndMinutes, 1200);
  });

  testWidgets('duplicate day opens a navigable calendar and duplicating shows a success SnackBar',
      (tester) async {
    final fake = await _pumpPlannerPage(tester);
    final today = DateTime.now();
    await fake.addItem(ScheduleItemEntity(
      id: 'i1',
      title: 'Gym',
      date: DateTime(today.year, today.month, today.day),
      startTime: DateTime(today.year, today.month, today.day, 7),
      endTime: DateTime(today.year, today.month, today.day, 8),
      colorHex: '#00D4A0',
      emoji: '🏋️',
      createdAt: today,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Duplicate this day'));
    await tester.pumpAndSettle();
    expect(find.byType(DuplicateDaySheet), findsOneWidget);

    // Today's own cell is disabled (it's the duplication source) — confirm
    // it can't be selected.
    await tester.tap(find.descendant(
      of: find.byType(DuplicateDaySheet),
      matching: find.text('${today.day}'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Select dates to duplicate to'), findsOneWidget);

    // Navigate to next month, where day 1 and 2 are always in the future
    // relative to the source day regardless of what "today" is — avoids
    // any month-boundary edge cases in this test.
    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await tester.pumpAndSettle();

    final targetsFinder = find.descendant(
      of: find.byType(DuplicateDaySheet),
      matching: find.byWidgetPredicate((w) => w is Text && (w.data == '1' || w.data == '2')),
    );
    for (final target in targetsFinder.evaluate().toList()) {
      await tester.tap(find.byWidget(target.widget));
      await tester.pumpAndSettle();
    }

    expect(find.text('Duplicate to 2 days'), findsOneWidget);
    await tester.tap(find.text('Duplicate to 2 days'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Schedule copied to 2 days'), findsOneWidget);
    expect(fake.items.length, 3); // original + 2 duplicates
  });

  testWidgets('a task with a specific due time is positioned and colored correctly on the timeline',
      (tester) async {
    final today = DateTime.now();
    final dueTime = DateTime(today.year, today.month, today.day, 14, 30); // 2:30 PM
    final task = TaskEntity(
      id: 't1',
      title: 'Submit report',
      priority: TaskPriority.high,
      category: TaskCategory.assignment,
      dueDate: dueTime,
      createdAt: today,
    );
    await _pumpPlannerPage(tester, tasks: [task]);

    expect(find.byType(TaskTimelineBlock), findsOneWidget);
    expect(find.textContaining('Submit report'), findsOneWidget);
    expect(find.textContaining('📝'), findsOneWidget); // assignment category emoji

    final blockContainer = tester.widget<Container>(
      find.descendant(of: find.byType(TaskTimelineBlock), matching: find.byType(Container)).first,
    );
    final decoration = blockContainer.decoration as BoxDecoration;
    expect(decoration.color, AppColors.coral); // high priority

    final positioned = tester.widget<Positioned>(
      find.ancestor(of: find.byType(TaskTimelineBlock), matching: find.byType(Positioned)).first,
    );
    // Default settings start the day at 7:00 AM (420 minutes); 2:30 PM is
    // 450 minutes into the visible window.
    expect(positioned.top, timelineTop(dueTime, 420));
  });

  testWidgets('tapping a task block on the timeline opens the task detail page', (tester) async {
    final today = DateTime.now();
    final task = TaskEntity(
      id: 't1',
      title: 'Read chapter 4',
      priority: TaskPriority.low,
      category: TaskCategory.exam,
      dueDate: DateTime(today.year, today.month, today.day, 16, 0),
      createdAt: today,
    );
    await _pumpPlannerPage(tester, tasks: [task]);

    await tester.tap(find.textContaining('Read chapter 4'));
    await tester.pumpAndSettle();

    expect(find.byType(TaskDetailPage), findsOneWidget);
  });

  testWidgets('a task defaulted to 11:59 PM still appears on the timeline like any other task',
      (tester) async {
    final today = DateTime.now();
    final task = TaskEntity(
      id: 't1',
      title: 'No explicit time picked',
      priority: TaskPriority.medium,
      category: TaskCategory.other,
      dueDate: DateTime(today.year, today.month, today.day, 23, 59),
      createdAt: today,
    );
    await _pumpPlannerPage(tester, tasks: [task]);

    // No separate "all-day" section exists any more — it renders as an
    // ordinary positioned block, same as every other task.
    expect(find.text('All-day'), findsNothing);
    expect(find.byType(TaskTimelineBlock), findsOneWidget);
    expect(find.textContaining('No explicit time picked'), findsOneWidget);

    final blockContainer = tester.widget<Container>(
      find.descendant(of: find.byType(TaskTimelineBlock), matching: find.byType(Container)).first,
    );
    final decoration = blockContainer.decoration as BoxDecoration;
    expect(decoration.color, AppColors.amber); // medium priority
  });
}
