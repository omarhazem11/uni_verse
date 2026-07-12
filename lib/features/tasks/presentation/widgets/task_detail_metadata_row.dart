import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/task_entity.dart';
import '../utils/task_display_helpers.dart';

/// Same visual language as [TaskMetadataRow] on the list tile, scaled up
/// for the full-page detail view.
class TaskDetailMetadataRow extends StatelessWidget {
  final TaskEntity task;

  const TaskDetailMetadataRow({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.tileVioletBg,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            '${task.category.emoji} ${task.category.label}',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.tileVioletText,
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: task.priority.color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              '${task.priority.label} priority',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted),
            ),
          ],
        ),
      ],
    );
  }
}
