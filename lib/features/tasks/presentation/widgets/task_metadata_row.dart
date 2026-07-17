import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/task_entity.dart';
import '../utils/task_display_helpers.dart';

const _monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

class TaskMetadataRow extends StatelessWidget {
  final TaskEntity task;
  final Widget? trailingChip;

  const TaskMetadataRow({super.key, required this.task, this.trailingChip});

  @override
  Widget build(BuildContext context) {
    final overdue = _isOverdue(task);

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _CategoryChip(category: task.category),
        _PriorityDot(priority: task.priority),
        if (task.dueDate != null) _DueDateChip(date: task.dueDate!, overdue: overdue),
        if (trailingChip != null) trailingChip!,
      ],
    );
  }

  bool _isOverdue(TaskEntity task) {
    if (task.dueDate == null || task.isCompleted) return false;
    return task.dueDate!.isBefore(DateTime.now());
  }
}

class _CategoryChip extends StatelessWidget {
  final TaskCategory category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.tileVioletBg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        '${category.emoji} ${category.label}',
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.tileVioletText,
        ),
      ),
    );
  }
}

class _PriorityDot extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityDot({required this.priority});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: priority.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          priority.label,
          style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted),
        ),
      ],
    );
  }
}

class _DueDateChip extends StatelessWidget {
  final DateTime date;
  final bool overdue;

  const _DueDateChip({required this.date, required this.overdue});

  @override
  Widget build(BuildContext context) {
    final label = '${_monthNames[date.month - 1]} ${date.day}';
    final color = overdue ? AppColors.coral : AppColors.muted;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.calendar_today_rounded, size: 11, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: overdue ? FontWeight.w700 : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
