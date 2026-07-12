import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uni_verse/core/errors/failures.dart';
import 'package:uni_verse/features/auth/domain/entities/user_entity.dart';
import 'package:uni_verse/features/auth/presentation/providers/auth_provider.dart';
import 'package:uni_verse/features/home/presentation/pages/dashboard_page.dart';
import 'package:uni_verse/features/planner/domain/entities/planner_settings_entity.dart';
import 'package:uni_verse/features/planner/domain/entities/schedule_item_entity.dart';
import 'package:uni_verse/features/planner/domain/repositories/planner_repository.dart';
import 'package:uni_verse/features/planner/presentation/providers/planner_provider.dart';
import 'package:uni_verse/features/tasks/domain/entities/task_entity.dart';
import 'package:uni_verse/features/tasks/presentation/providers/task_provider.dart';

/// A minimal stand-in for PlannerRepository — every method that isn't
/// exercised by DashboardPage/DashboardTileGrid just needs to not touch
/// real Firestore. [hasItems] controls what every items query returns, so
/// hasAnyScheduleItemsProvider (and the Planner tile's own item count)
/// derive consistently from one flag instead of needing separate overrides.
class _FakePlannerRepository implements PlannerRepository {
  final bool hasItems;

  _FakePlannerRepository({required this.hasItems});

  List<ScheduleItemEntity> get _items => hasItems
      ? [
          ScheduleItemEntity(
            id: 'seed',
            title: 'Seed item',
            date: DateTime.now(),
            startTime: DateTime.now(),
            endTime: DateTime.now().add(const Duration(hours: 1)),
            colorHex: '#6C3BFF',
            emoji: '📚',
            createdAt: DateTime.now(),
          ),
        ]
      : [];

  @override
  Stream<List<ScheduleItemEntity>> watchItemsForDate(DateTime date) => Stream.value(_items);

  @override
  Stream<List<ScheduleItemEntity>> watchItemsInRange(DateTime start, DateTime end) =>
      Stream.value(_items);

  @override
  Future<Either<Failure, void>> addItem(ScheduleItemEntity item) async => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> updateItem(ScheduleItemEntity item) async => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deleteItem(String itemId) async => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> duplicateItemsToDate(DateTime sourceDate, List<DateTime> targetDates) async =>
      throw UnimplementedError();

  @override
  Stream<PlannerSettingsEntity> watchSettings() => Stream.value(const PlannerSettingsEntity());

  @override
  Future<Either<Failure, void>> updateSettings(PlannerSettingsEntity settings) async =>
      throw UnimplementedError();
}

Future<void> _pumpDashboard(
  WidgetTester tester, {
  required List<TaskEntity> tasks,
  required bool hasScheduleItems,
}) async {
  tester.view.physicalSize = const Size(400, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStateProvider.overrideWith(
          (ref) => Stream.value(const UserEntity(id: '1', email: 's@t.com', displayName: 'Sara')),
        ),
        tasksStreamProvider.overrideWith((ref) => Stream.value(tasks)),
        plannerRepositoryProvider.overrideWithValue(_FakePlannerRepository(hasItems: hasScheduleItems)),
      ],
      child: const MaterialApp(home: DashboardPage()),
    ),
  );
  await tester.pumpAndSettle();
}

TaskEntity _task() => TaskEntity(id: 't1', title: 'Do something', createdAt: DateTime.now());

void main() {
  testWidgets('no tasks, no schedule items: 1/4, add a task next', (tester) async {
    await _pumpDashboard(tester, tasks: [], hasScheduleItems: false);
    expect(find.text('1/4'), findsOneWidget);
    expect(find.textContaining('add a task next'), findsOneWidget);
  });

  testWidgets('has a task but no schedule items: 2/4, plan your week next', (tester) async {
    await _pumpDashboard(tester, tasks: [_task()], hasScheduleItems: false);
    expect(find.text('2/4'), findsOneWidget);
    expect(find.textContaining('plan your week next'), findsOneWidget);
  });

  testWidgets('has a task and a schedule item: 3/4, earn your first badge next', (tester) async {
    await _pumpDashboard(tester, tasks: [_task()], hasScheduleItems: true);
    expect(find.text('3/4'), findsOneWidget);
    expect(find.textContaining('earn your first badge next'), findsOneWidget);
  });

  testWidgets('schedule item added before any task still counts its own step', (tester) async {
    await _pumpDashboard(tester, tasks: [], hasScheduleItems: true);
    expect(find.text('2/4'), findsOneWidget);
  });
}
