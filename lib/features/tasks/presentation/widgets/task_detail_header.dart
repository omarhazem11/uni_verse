import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/task_entity.dart';
import 'task_checkbox.dart';

class TaskDetailHeader extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onToggle;

  const TaskDetailHeader({super.key, required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: TaskCheckbox(isCompleted: task.isCompleted, onTap: onToggle, size: 32),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Opacity(
            opacity: task.isCompleted ? 0.6 : 1,
            child: Text(
              task.title,
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: task.isCompleted ? AppColors.muted : AppColors.ink,
                decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
