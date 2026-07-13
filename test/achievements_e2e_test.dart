import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_verse/core/errors/failures.dart';
import 'package:uni_verse/features/achievements/data/models/user_progress_model.dart';
import 'package:uni_verse/features/achievements/domain/badge_ids.dart';
import 'package:uni_verse/features/achievements/domain/badge_rules.dart';
import 'package:uni_verse/features/achievements/domain/entities/user_progress_entity.dart';
import 'package:uni_verse/features/achievements/domain/level_calculator.dart';
import 'package:uni_verse/features/achievements/domain/streak_calculator.dart';
import 'package:uni_verse/features/achievements/presentation/pages/achievements_page.dart';
import 'package:uni_verse/features/achievements/presentation/providers/achievements_provider.dart';
import 'package:uni_verse/features/auth/domain/entities/user_entity.dart';
import 'package:uni_verse/features/auth/presentation/providers/auth_provider.dart';
import 'package:uni_verse/features/home/presentation/pages/dashboard_page.dart';
import 'package:uni_verse/features/home/presentation/widgets/dashboard_bottom_nav.dart';
import 'package:uni_verse/features/notes/presentation/pages/notes_page.dart';
import 'package:uni_verse/features/notes/presentation/providers/note_provider.dart';
import 'package:uni_verse/features/planner/domain/entities/planner_settings_entity.dart';
import 'package:uni_verse/features/planner/domain/entities/schedule_item_entity.dart';
import 'package:uni_verse/features/planner/domain/repositories/planner_repository.dart';
import 'package:uni_verse/features/planner/presentation/pages/planner_page.dart';
import 'package:uni_verse/features/planner/presentation/providers/planner_provider.dart';
import 'package:uni_verse/features/tasks/domain/entities/task_entity.dart';
import 'package:uni_verse/features/tasks/domain/repositories/task_repository.dart';
import 'package:uni_verse/features/tasks/presentation/pages/tasks_page.dart';
import 'package:uni_verse/features/tasks/presentation/providers/task_provider.dart';
import 'package:uni_verse/features/tasks/presentation/widgets/task_checkbox.dart';
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
  Future<Either<Failure, void>> updateTask(TaskEntity task) async => const Right(null);

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

class FakePlannerRepository implements PlannerRepository {
  final items = <ScheduleItemEntity>[];
  final _itemsController = StreamController<List<ScheduleItemEntity>>.broadcast();
  final _settingsController = StreamController<PlannerSettingsEntity>.broadcast();

  bool _sameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
  void _emitItems() => _itemsController.add(List.unmodifiable(items));

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
  Future<Either<Failure, void>> updateItem(ScheduleItemEntity item) async => const Right(null);

  @override
  Future<Either<Failure, void>> deleteItem(String itemId) async => const Right(null);

  @override
  Future<Either<Failure, void>> duplicateItemsToDate(DateTime sourceDate, List<DateTime> targetDates) async {
    final sourceItems = items.where((i) => _sameDate(i.date, sourceDate)).toList();
    var counter = 0;
    for (final target in targetDates) {
      for (final item in sourceItems) {
        items.add(ScheduleItemEntity(
          id: 'dup-${counter++}',
          title: item.title,
          date: DateTime(target.year, target.month, target.day),
          startTime: item.startTime,
          endTime: item.endTime,
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
    Future.microtask(() => _settingsController.add(const PlannerSettingsEntity()));
    return _settingsController.stream;
  }

  @override
  Future<Either<Failure, void>> updateSettings(PlannerSettingsEntity settings) async => const Right(null);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('badgeRules', () {
    test('firstSteps unlocks after 1 completed task', () {
      const p = UserProgressEntity(tasksCompletedCount: 1);
      expect(badgeRules[BadgeIds.firstSteps]!(p), isTrue);
    });

    test('firstSteps stays locked with 0 completed tasks', () {
      const p = UserProgressEntity(tasksCompletedCount: 0);
      expect(badgeRules[BadgeIds.firstSteps]!(p), isFalse);
    });

    test('fullTour requires all 4 tabs', () {
      const three = UserProgressEntity(visitedTabs: {'home', 'planner', 'notes'});
      const four = UserProgressEntity(visitedTabs: {'home', 'planner', 'notes', 'analytics'});
      expect(badgeRules[BadgeIds.fullTour]!(three), isFalse);
      expect(badgeRules[BadgeIds.fullTour]!(four), isTrue);
    });

    test('repeatChampion requires hasUsedDuplicateDay', () {
      const p = UserProgressEntity(hasUsedDuplicateDay: true);
      expect(badgeRules[BadgeIds.repeatChampion]!(p), isTrue);
    });

    test('streak badges check longestStreak, not currentStreak', () {
      // A broken-but-previously-long streak should still count.
      const p = UserProgressEntity(currentStreak: 1, longestStreak: 7);
      expect(badgeRules[BadgeIds.weekWarrior]!(p), isTrue);
    });
  });

  group('level_calculator', () {
    test('level 1 spans 0-99 points', () {
      expect(levelForPoints(0), 1);
      expect(levelForPoints(99), 1);
    });

    test('level 2 starts at 100 points', () {
      expect(levelForPoints(100), 2);
      expect(levelForPoints(150), 2);
    });

    test('pointsToNextLevel counts down within a level', () {
      expect(pointsToNextLevel(150), 50);
      expect(pointsToNextLevel(100), 100);
    });

    test('levelProgress is a 0.0-1.0 fraction', () {
      expect(levelProgress(150), 0.5);
      expect(levelProgress(0), 0.0);
    });
  });

  group('streak_calculator', () {
    final today = DateTime(2026, 1, 20);

    test('same day as lastActiveDate is a no-op', () {
      final update = computeStreakUpdate(
        lastActiveDate: today,
        currentStreak: 5,
        longestStreak: 5,
        today: today,
      );
      expect(update.changed, isFalse);
      expect(update.currentStreak, 5);
    });

    test('consecutive day increments the streak', () {
      final update = computeStreakUpdate(
        lastActiveDate: DateTime(2026, 1, 19),
        currentStreak: 2,
        longestStreak: 2,
        today: today,
      );
      expect(update.changed, isTrue);
      expect(update.currentStreak, 3);
      expect(update.longestStreak, 3);
    });

    test('a gap of more than 1 day resets the streak to 1', () {
      final update = computeStreakUpdate(
        lastActiveDate: DateTime(2026, 1, 15),
        currentStreak: 10,
        longestStreak: 10,
        today: today,
      );
      expect(update.currentStreak, 1);
      expect(update.longestStreak, 10); // high-water mark preserved
    });

    test('first ever open (no lastActiveDate) starts the streak at 1', () {
      final update = computeStreakUpdate(
        lastActiveDate: null,
        currentStreak: 0,
        longestStreak: 0,
        today: today,
      );
      expect(update.currentStreak, 1);
      expect(update.longestStreak, 1);
    });

    test('a new longest streak updates the high-water mark', () {
      final update = computeStreakUpdate(
        lastActiveDate: DateTime(2026, 1, 19),
        currentStreak: 6,
        longestStreak: 6,
        today: today,
      );
      expect(update.currentStreak, 7);
      expect(update.longestStreak, 7);
    });
  });

  testWidgets('completing a task unlocks First Steps with a celebration toast', (tester) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final taskRepo = FakeTaskRepository();
    final achievementsDataSource = FakeAchievementsDataSource();
    await taskRepo.addTask(TaskEntity(id: 't1', title: 'Finish essay', createdAt: DateTime.now()));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskRepositoryProvider.overrideWithValue(taskRepo),
          achievementsRemoteDataSourceProvider.overrideWithValue(achievementsDataSource),
          noteRemoteDataSourceProvider.overrideWithValue(FakeNoteRemoteDataSource()),
        ],
        child: const MaterialApp(home: TasksPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TaskCheckbox));
    await tester.pumpAndSettle();

    expect(achievementsDataSource.progress.tasksCompletedCount, 1);
    expect(find.text('🎉 Badge unlocked: First Steps!'), findsOneWidget);
  });

  testWidgets('visiting all 4 tabs unlocks Full Tour', (tester) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final achievementsDataSource = FakeAchievementsDataSource();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(const UserEntity(id: '1', email: 's@t.com', displayName: 'Sara')),
          ),
          tasksStreamProvider.overrideWith((ref) => Stream.value(<TaskEntity>[])),
          plannerRepositoryProvider.overrideWithValue(FakePlannerRepository()),
          achievementsRemoteDataSourceProvider.overrideWithValue(achievementsDataSource),
          noteRemoteDataSourceProvider.overrideWithValue(FakeNoteRemoteDataSource()),
        ],
        child: const MaterialApp(home: DashboardPage()),
      ),
    );
    await tester.pumpAndSettle(); // initState records 'home'

    final bottomNav = find.byType(DashboardBottomNav);
    // Notes nav item navigates away and back too, recording 'notes' along the way.
    await tester.tap(find.descendant(of: bottomNav, matching: find.text('Notes')));
    await tester.pumpAndSettle();
    expect(find.byType(NotesPage), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.descendant(of: bottomNav, matching: find.text('Analytics')));
    await tester.pumpAndSettle();

    // Planner nav item navigates away and back, recording 'planner' along the way.
    await tester.tap(find.descendant(of: bottomNav, matching: find.text('Planner')));
    await tester.pumpAndSettle();
    expect(find.byType(PlannerPage), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(achievementsDataSource.progress.visitedTabs, {'home', 'notes', 'analytics', 'planner'});
    expect(find.textContaining('Full Tour'), findsOneWidget);
  });

  testWidgets('using duplicate-day unlocks Repeat Champion', (tester) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final plannerRepo = FakePlannerRepository();
    final achievementsDataSource = FakeAchievementsDataSource();
    final today = DateTime.now();
    // Seeded directly (bypassing the add sheet) so plannerItemsCount stays
    // 0 and only Repeat Champion — not First Schedule too — unlocks here,
    // keeping the assertion unambiguous.
    await plannerRepo.addItem(ScheduleItemEntity(
      id: 'i1',
      title: 'Gym',
      date: DateTime(today.year, today.month, today.day),
      startTime: DateTime(today.year, today.month, today.day, 7),
      endTime: DateTime(today.year, today.month, today.day, 8),
      colorHex: '#00D4A0',
      emoji: '🏋️',
      createdAt: today,
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          plannerRepositoryProvider.overrideWithValue(plannerRepo),
          achievementsRemoteDataSourceProvider.overrideWithValue(achievementsDataSource),
          tasksStreamProvider.overrideWith((ref) => Stream.value(<TaskEntity>[])),
        ],
        child: const MaterialApp(home: PlannerPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Duplicate this day'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.byWidgetPredicate((w) => w is Text && w.data == '1').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Duplicate to 1 day'));
    await tester.pump();

    // Both toasts are correctly queued at this point — ScaffoldMessenger
    // shows one at a time, so the "copied" toast appears first...
    expect(find.textContaining('Schedule copied'), findsOneWidget);
    expect(achievementsDataSource.progress.hasUsedDuplicateDay, isTrue);
    expect(achievementsDataSource.progress.badgeUnlockedAt.keys, contains(BadgeIds.repeatChampion));

    // ...and the badge celebration only becomes visible once the first
    // toast's default ~4s duration elapses and it's dismissed. Pumping in
    // 1-second steps (rather than one big jump) is what actually drives
    // the ScaffoldMessenger's internal queue-advance timer callbacks.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(find.text('🎉 Badge unlocked: Repeat Champion!'), findsOneWidget);
  });

  testWidgets('progress and level display on the achievements page reflect points earned',
      (tester) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final achievementsDataSource = FakeAchievementsDataSource();
    achievementsDataSource.progress = UserProgressModel.fromEntity(
      const UserProgressEntity(totalPoints: 150, currentStreak: 5, tasksCompletedCount: 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [achievementsRemoteDataSourceProvider.overrideWithValue(achievementsDataSource)],
        child: const MaterialApp(home: AchievementsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Level 2'), findsOneWidget);
    expect(find.text('150 points'), findsOneWidget);
    expect(find.textContaining('5 days streak'), findsOneWidget);
  });
}
