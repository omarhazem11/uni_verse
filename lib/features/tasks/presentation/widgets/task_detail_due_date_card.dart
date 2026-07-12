import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/task_entity.dart';
import '../utils/task_date_format.dart';
import 'task_reminder_dropdown.dart' show reminderOptions;

class TaskDetailDueDateCard extends StatelessWidget {
  final TaskEntity task;

  const TaskDetailDueDateCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final hasDueDate = task.dueDate != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.ink.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: hasDueDate ? AppColors.violet : AppColors.muted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hasDueDate ? fullDateLabel(task.dueDate!) : 'No due date set',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: hasDueDate ? AppColors.ink : AppColors.muted,
                  ),
                ),
              ),
            ],
          ),
          if (hasDueDate) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.notifications_outlined, size: 16, color: AppColors.muted),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Reminder: ${_reminderLabel(task)}',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _reminderLabel(TaskEntity task) {
    if (task.customReminderDateTime != null) {
      return shortDateTimeLabel(task.customReminderDateTime!);
    }
    return reminderOptions.entries
        .firstWhere((e) => e.value == task.reminderOffset, orElse: () => reminderOptions.entries.last)
        .key;
  }
}
