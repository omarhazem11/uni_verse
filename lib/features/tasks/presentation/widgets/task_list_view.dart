import 'package:flutter/material.dart';
import '../../domain/entities/task_entity.dart';
import 'task_tile.dart';

class TaskListView extends StatelessWidget {
  final List<TaskEntity> tasks;
  final bool isSelectionMode;
  final Set<String> selectedIds;
  final void Function(String id) onEnterSelectionMode;
  final void Function(String id) onToggleSelect;

  const TaskListView({
    super.key,
    required this.tasks,
    this.isSelectionMode = false,
    this.selectedIds = const {},
    this.onEnterSelectionMode = _noop,
    this.onToggleSelect = _noop,
  });

  static void _noop(String _) {}

  @override
  Widget build(BuildContext context) {
    final incomplete = tasks.where((t) => !t.isCompleted).toList();
    final completed = tasks.where((t) => t.isCompleted).toList();
    final ordered = [...incomplete, ...completed];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: ordered.length,
      itemBuilder: (context, index) {
        final task = ordered[index];
        return TaskTile(
          task: task,
          isSelectionMode: isSelectionMode,
          isSelected: selectedIds.contains(task.id),
          onEnterSelectionMode: () => onEnterSelectionMode(task.id),
          onToggleSelect: () => onToggleSelect(task.id),
        );
      },
    );
  }
}
