import '../../domain/entities/task_entity.dart';

/// Small shared helpers so the dashboard tile and hero card don't each
/// re-derive the same due-date math independently.
extension TaskListStats on List<TaskEntity> {
  int get activeCount => where((t) => !t.isCompleted).length;

  /// Active tasks due before [window] from now — includes anything already
  /// overdue, since an overdue task is at least as urgent as one due soon.
  int dueWithin(Duration window) {
    final cutoff = DateTime.now().add(window);
    return where((t) => !t.isCompleted && t.dueDate != null && t.dueDate!.isBefore(cutoff)).length;
  }
}

/// The single most urgent incomplete task — soonest due date first, ties
/// broken by priority (high wins). Tasks without a due date are excluded
/// since there's nothing to rank them against.
TaskEntity? getNextTask(List<TaskEntity> tasks) {
  final incomplete = tasks.where((t) => !t.isCompleted && t.dueDate != null).toList();
  if (incomplete.isEmpty) return null;
  incomplete.sort((a, b) {
    final dateCompare = a.dueDate!.compareTo(b.dueDate!);
    if (dateCompare != 0) return dateCompare;
    return b.priority.index.compareTo(a.priority.index);
  });
  return incomplete.first;
}
