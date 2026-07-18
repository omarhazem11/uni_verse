import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/pages/task_detail_page.dart';
import '../../../tasks/presentation/utils/task_display_helpers.dart';
import 'block_preview_card.dart';

class TaskTimelineBlock extends StatelessWidget {
  final TaskEntity task;

  const TaskTimelineBlock({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final color = task.priority.color;

    return GestureDetector(
      onTap: () => showBlockPreview(
        context,
        emoji: task.category.emoji,
        title: task.title,
        color: color,
        subtitle: task.dueDate != null
            ? 'Due ${formatTimeOfDay(task.dueDate!)}'
            : 'No due time set',
        onOpen: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TaskDetailPage(task: task)),
        ),
      ),
      child: Opacity(
        opacity: task.isCompleted ? 0.6 : 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final short = constraints.maxHeight < 30;
            // Right padding 10 + checkbox badge ~18.
            final availableWidth = constraints.maxWidth - 28;

            final style = GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              decoration: task.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            );

            // Measure whether the full title fits in one line.
            final tp = TextPainter(
              text: TextSpan(
                text: '${task.category.emoji} ${task.title}',
                style: style,
              ),
              maxLines: 1,
              textDirection: TextDirection.ltr,
            )..layout(maxWidth: availableWidth);

            final fits = !tp.didExceedMaxLines;

            if (!fits) {
              // Title doesn't fit — emoji pinned to top-left, rest solid color.
              return Container(
                width: double.infinity,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(4),
                alignment: Alignment.topLeft,
                child: Text(task.category.emoji, style: const TextStyle(fontSize: 12)),
              );
            }

            return Container(
              width: double.infinity,
              clipBehavior: Clip.hardEdge,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: short ? 3 : 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 18),
                    child: Text(
                      '${task.category.emoji} ${task.title}',
                      maxLines: short ? 1 : 2,
                      style: style,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(
                      task.isCompleted
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
