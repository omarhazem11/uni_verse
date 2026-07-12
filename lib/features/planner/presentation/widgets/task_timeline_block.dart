import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/pages/task_detail_page.dart';
import '../../../tasks/presentation/utils/task_display_helpers.dart';

/// Positioned on the timeline exactly like a schedule item, but visually
/// distinct — priority-colored (not a fixed accent) with a checkbox badge
/// in the corner, since tasks are actionable while schedule items are just
/// time blocks.
class TaskTimelineBlock extends StatelessWidget {
  final TaskEntity task;

  const TaskTimelineBlock({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TaskDetailPage(task: task)),
      ),
      child: Opacity(
        opacity: task.isCompleted ? 0.6 : 1,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: task.priority.color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 18),
                child: Text(
                  '${task.category.emoji} ${task.title}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  task.isCompleted ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
