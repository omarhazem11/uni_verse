import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../providers/planner_provider.dart';
import '../utils/timeline_math.dart';
import 'day_timeline_empty_state.dart';
import 'schedule_item_block.dart';
import 'task_timeline_block.dart';
import 'timeline_hour_markers.dart';

class DayTimelineView extends ConsumerWidget {
  final DateTime date;

  const DayTimelineView({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(dayItemsProvider(date));
    final settingsAsync = ref.watch(plannerSettingsProvider);
    // Reuses the same tasksStreamProvider the Tasks feature and dashboard
    // watch — Riverpod caches the underlying Firestore stream, so this
    // doesn't open a second listener.
    final tasksAsync = ref.watch(tasksStreamProvider);

    if (!itemsAsync.hasValue || !settingsAsync.hasValue) {
      return const SizedBox.shrink();
    }

    final items = itemsAsync.value!;
    final settings = settingsAsync.value!;
    final normalized = dateOnly(date);
    final tasksToday = (tasksAsync.value ?? [])
        .where((t) => t.dueDate != null && dateOnly(t.dueDate!) == normalized)
        .toList();

    if (items.isEmpty && tasksToday.isEmpty) return const DayTimelineEmptyState();

    final start = settings.dayStartMinutes;
    final end = settings.dayEndMinutes;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        height: totalTimelineHeight(start, end),
        child: Stack(
          children: [
            TimelineHourMarkers(dayStartMinutes: start, dayEndMinutes: end),
            for (final item in items)
              Positioned(
                top: timelineTop(item.startTime, start),
                left: timelineLabelWidth + 8,
                right: 0,
                height: timelineHeight(item.startTime, item.endTime),
                child: ScheduleItemBlock(item: item),
              ),
            for (final task in tasksToday)
              Positioned(
                top: timelineTop(task.dueDate!, start),
                left: timelineLabelWidth + 8,
                right: 0,
                height: taskBlockHeight,
                child: TaskTimelineBlock(task: task),
              ),
          ],
        ),
      ),
    );
  }
}
