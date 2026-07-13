import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../notes/presentation/pages/note_editor_page.dart';
import '../../../notes/presentation/providers/note_provider.dart';
import '../../../notes/presentation/widgets/view_notes_button.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_provider.dart';
import '../utils/task_completion_celebration.dart';
import '../widgets/add_task_sheet.dart';
import '../widgets/task_delete_dialog.dart';
import '../widgets/task_detail_description_card.dart';
import '../widgets/task_detail_due_date_card.dart';
import '../widgets/task_detail_header.dart';
import '../widgets/task_detail_metadata_row.dart';

class TaskDetailPage extends ConsumerWidget {
  final TaskEntity task;

  const TaskDetailPage({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksStreamProvider);
    final matches = tasksAsync.value?.where((t) => t.id == task.id) ?? const <TaskEntity>[];
    final current = matches.isEmpty ? null : matches.first;

    // The task was deleted (e.g. from the list) while this page was open —
    // bounce back to the list rather than showing stale/missing data.
    if (tasksAsync.hasValue && current == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) Navigator.pop(context);
      });
      return const Scaffold(backgroundColor: AppColors.bg, body: SizedBox.shrink());
    }

    final shown = current ?? task;
    final linkedNote = ref.watch(noteForTaskProvider(shown.id));

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
        title: Text(
          shown.title,
          style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.violet),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => AddTaskSheet(existingTask: shown),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TaskDetailHeader(task: shown, onToggle: () => _toggle(context, ref, shown)),
            const SizedBox(height: 20),
            TaskDetailMetadataRow(task: shown),
            const SizedBox(height: 20),
            TaskDetailDueDateCard(task: shown),
            if (linkedNote != null) ...[
              const SizedBox(height: 20),
              ViewNotesButton(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => NoteEditorPage(existingNote: linkedNote)),
                ),
              ),
            ],
            const SizedBox(height: 20),
            TaskDetailDescriptionCard(description: shown.description),
            const SizedBox(height: 28),
            _DeleteButton(onPressed: () => _delete(context, ref, shown)),
          ],
        ),
      ),
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref, TaskEntity task) async {
    final markingComplete = !task.isCompleted;
    await toggleTaskCompletionAndCelebrate(context, ref, task, markingComplete);
    if (markingComplete && context.mounted) Navigator.pop(context);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, TaskEntity task) async {
    final confirmed = await showDeleteTaskDialog(context);
    if (!confirmed || !context.mounted) return;
    await ref.read(taskActionsProvider.notifier).deleteTask(task.id);
    if (context.mounted) Navigator.pop(context);
  }
}

class _DeleteButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _DeleteButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.coral,
          side: const BorderSide(color: AppColors.coral),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          'Delete Task',
          style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
