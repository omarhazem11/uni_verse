import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uni_verse/core/theme/app_colors.dart';
import 'package:uni_verse/features/home/presentation/utils/task_urgency.dart';
import 'package:uni_verse/features/home/presentation/widgets/circular_progress_ring.dart';
import 'package:uni_verse/features/home/presentation/widgets/dashboard_next_task_card.dart';
import 'package:uni_verse/features/tasks/domain/entities/task_entity.dart';
import 'package:uni_verse/features/tasks/presentation/pages/task_detail_page.dart';
import 'package:uni_verse/features/notes/presentation/providers/note_provider.dart';
import 'package:uni_verse/features/tasks/presentation/utils/task_stats.dart';
import 'package:uni_verse/features/tasks/presentation/providers/task_provider.dart';
import 'fakes/fake_note_datasource.dart';

TaskEntity _taskDueIn(Duration offset, {TaskPriority priority = TaskPriority.medium, String id = 't1'}) {
  return TaskEntity(
    id: id,
    title: 'Task $id',
    priority: priority,
    dueDate: DateTime.now().add(offset),
    createdAt: DateTime.now(),
  );
}

void main() {
  group('computeTaskUrgency', () {
    final now = DateTime(2026, 1, 1, 12);

    test('due in 5 days: mint, 25% fill', () {
      final urgency = computeTaskUrgency(now.add(const Duration(days: 5)), now);
      expect(urgency.color, AppColors.mint);
      expect(urgency.fillPercent, 0.25);
      expect(urgency.centerLabel, '5d');
      expect(urgency.isOverdue, false);
    });

    test('due in 30 hours: amber, 60% fill', () {
      final urgency = computeTaskUrgency(now.add(const Duration(hours: 30)), now);
      expect(urgency.color, AppColors.amber);
      expect(urgency.fillPercent, 0.60);
      expect(urgency.isOverdue, false);
    });

    test('due in 12 hours: coral, 90% fill, hour label', () {
      final urgency = computeTaskUrgency(now.add(const Duration(hours: 12)), now);
      expect(urgency.color, AppColors.coral);
      expect(urgency.fillPercent, 0.90);
      expect(urgency.centerLabel, '12h');
      expect(urgency.isOverdue, false);
    });

    test('overdue: coral, 100% fill, "!" label', () {
      final urgency = computeTaskUrgency(now.subtract(const Duration(hours: 1)), now);
      expect(urgency.color, AppColors.coral);
      expect(urgency.fillPercent, 1.0);
      expect(urgency.centerLabel, '!');
      expect(urgency.isOverdue, true);
    });
  });

  group('getNextTask', () {
    test('no incomplete tasks with a due date returns null', () {
      expect(getNextTask([]), isNull);
      expect(getNextTask([_taskDueIn(const Duration(hours: 1)).copyWith(isCompleted: true)]), isNull);
    });

    test('soonest due date wins', () {
      final soon = _taskDueIn(const Duration(hours: 1), id: 'soon');
      final later = _taskDueIn(const Duration(days: 3), id: 'later');
      expect(getNextTask([later, soon])!.id, 'soon');
    });

    test('identical due date/time: higher priority wins', () {
      final dueDate = DateTime.now().add(const Duration(hours: 5));
      final low = TaskEntity(
        id: 'low',
        title: 'Low',
        priority: TaskPriority.low,
        dueDate: dueDate,
        createdAt: DateTime.now(),
      );
      final high = TaskEntity(
        id: 'high',
        title: 'High',
        priority: TaskPriority.high,
        dueDate: dueDate,
        createdAt: DateTime.now(),
      );
      expect(getNextTask([low, high])!.id, 'high');
    });
  });

  group('DashboardNextTaskCard', () {
    testWidgets('empty state when there is no next task', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DashboardNextTaskCard(task: null))),
      );
      expect(find.text('Nothing urgent right now'), findsOneWidget);
    });

    testWidgets('renders the ring matching the computed urgency for a soon-due task', (tester) async {
      final task = _taskDueIn(const Duration(hours: 12, minutes: 5));
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: DashboardNextTaskCard(task: task))),
      );
      final ring = tester.widget<CircularProgressRing>(find.byType(CircularProgressRing));
      expect(ring.color, AppColors.coral);
      expect(ring.progress, 0.90);
      expect(ring.label, '12h');
    });

    testWidgets('overdue task pulses: ring scale changes across animation frames', (tester) async {
      final task = _taskDueIn(const Duration(hours: -2));
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: DashboardNextTaskCard(task: task))),
      );
      await tester.pump();
      final transformFinder = find.byKey(const Key('urgencyRingPulse'));
      final scaleAtStart = tester.widget<Transform>(transformFinder).transform.getMaxScaleOnAxis();
      await tester.pump(const Duration(milliseconds: 450));
      final scaleMidway = tester.widget<Transform>(transformFinder).transform.getMaxScaleOnAxis();
      expect(scaleMidway, isNot(scaleAtStart));
    });

    testWidgets('tapping the card navigates to the task detail page', (tester) async {
      final task = _taskDueIn(const Duration(days: 2));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksStreamProvider.overrideWith((ref) => Stream.value([task])),
            noteRemoteDataSourceProvider.overrideWithValue(FakeNoteRemoteDataSource()),
          ],
          child: MaterialApp(home: Scaffold(body: DashboardNextTaskCard(task: task))),
        ),
      );
      await tester.tap(find.byType(DashboardNextTaskCard));
      await tester.pumpAndSettle();
      expect(find.byType(TaskDetailPage), findsOneWidget);
    });
  });
}
