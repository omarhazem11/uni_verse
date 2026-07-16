import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../notes/presentation/pages/note_editor_page.dart';
import '../../../notes/presentation/providers/note_provider.dart';
import '../../../notes/presentation/widgets/view_notes_chip.dart';
import '../../domain/entities/task_entity.dart';
import '../pages/task_detail_page.dart';
import '../providers/task_provider.dart';
import '../utils/task_completion_celebration.dart';
import 'task_checkbox.dart';
import 'task_delete_dialog.dart';
import 'task_metadata_row.dart';

class TaskTile extends ConsumerWidget {
  final TaskEntity task;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onEnterSelectionMode;
  final VoidCallback? onToggleSelect;

  const TaskTile({
    super.key,
    required this.task,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onEnterSelectionMode,
    this.onToggleSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linkedNote = ref.watch(noteForTaskProvider(task.id));
    final tile = _buildTile(context, ref, linkedNote);

    if (isSelectionMode) return tile;

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.horizontal,
      background: _deleteBackground(Alignment.centerLeft),
      secondaryBackground: _deleteBackground(Alignment.centerRight),
      confirmDismiss: (_) => showDeleteTaskDialog(context),
      onDismissed: (_) => ref.read(taskActionsProvider.notifier).deleteTask(task.id),
      child: tile,
    );
  }

  Widget _buildTile(BuildContext context, WidgetRef ref, dynamic linkedNote) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isSelected ? AppColors.violet.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isSelectionMode
              ? onToggleSelect
              : () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => TaskDetailPage(task: task)),
                  ),
          onLongPress: isSelectionMode ? null : onEnterSelectionMode,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: isSelectionMode
                      ? Checkbox(
                          value: isSelected,
                          onChanged: (_) => onToggleSelect?.call(),
                          activeColor: AppColors.violet,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        )
                      : TaskCheckbox(
                          isCompleted: task.isCompleted,
                          onTap: () =>
                              toggleTaskCompletionAndCelebrate(context, ref, task, !task.isCompleted),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Opacity(
                        opacity: task.isCompleted ? 0.6 : 1,
                        child: Text(
                          task.title,
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: task.isCompleted ? AppColors.muted : AppColors.ink,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      TaskMetadataRow(
                        task: task,
                        trailingChip: linkedNote == null
                            ? null
                            : ViewNotesChip(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => NoteEditorPage(existingNote: linkedNote)),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _deleteBackground(Alignment alignment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: alignment,
      decoration: BoxDecoration(
        color: AppColors.coral,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.delete_rounded, color: Colors.white),
    );
  }
}
