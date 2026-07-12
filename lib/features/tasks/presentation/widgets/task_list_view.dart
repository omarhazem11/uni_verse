import 'package:flutter/material.dart';
import '../../domain/entities/task_entity.dart';
import 'task_tile.dart';

class TaskListView extends StatelessWidget {
  final List<TaskEntity> tasks;

  const TaskListView({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    // The stream already sorts by dueDate ascending (no-date last); here we
    // additionally push completed tasks to the bottom as a group.
    final incomplete = tasks.where((t) => !t.isCompleted).toList();
    final completed = tasks.where((t) => t.isCompleted).toList();
    final ordered = [...incomplete, ...completed];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: ordered.length,
      itemBuilder: (context, index) => TaskTile(task: ordered[index]),
    );
  }
}
