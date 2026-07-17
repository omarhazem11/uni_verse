import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
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

  static bool _isOverdue(TaskEntity t) {
    if (t.dueDate == null || t.isCompleted) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
    return due.isBefore(today);
  }

  @override
  Widget build(BuildContext context) {
    final overdue = tasks.where((t) => _isOverdue(t)).toList();
    final active = tasks.where((t) => !t.isCompleted && !_isOverdue(t)).toList();
    final completed = tasks.where((t) => t.isCompleted).toList();

    final items = <_ListItem>[
      if (overdue.isNotEmpty) ...[
        _HeaderItem('Overdue', overdue.length, isOverdue: true),
        ...overdue.map(_TaskItem.new),
      ],
      if (active.isNotEmpty) ...[
        if (overdue.isNotEmpty || completed.isNotEmpty)
          _HeaderItem('Active', active.length),
        ...active.map(_TaskItem.new),
      ],
      if (completed.isNotEmpty) ...[
        _HeaderItem('Completed', completed.length),
        ...completed.map(_TaskItem.new),
      ],
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is _HeaderItem) {
          return _SectionHeader(label: item.label, count: item.count, isOverdue: item.isOverdue);
        }
        final task = (item as _TaskItem).task;
        return TaskTile(
          task: task,
          isOverdue: _isOverdue(task),
          isSelectionMode: isSelectionMode,
          isSelected: selectedIds.contains(task.id),
          onEnterSelectionMode: () => onEnterSelectionMode(task.id),
          onToggleSelect: () => onToggleSelect(task.id),
        );
      },
    );
  }
}

sealed class _ListItem {}
class _HeaderItem extends _ListItem {
  final String label;
  final int count;
  final bool isOverdue;
  _HeaderItem(this.label, this.count, {this.isOverdue = false});
}
class _TaskItem extends _ListItem {
  final TaskEntity task;
  _TaskItem(this.task);
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final bool isOverdue;

  const _SectionHeader({required this.label, required this.count, this.isOverdue = false});

  @override
  Widget build(BuildContext context) {
    final color = isOverdue ? AppColors.coral : AppColors.muted;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              '$count',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Container(height: 1, color: color.withValues(alpha: 0.15))),
        ],
      ),
    );
  }
}
