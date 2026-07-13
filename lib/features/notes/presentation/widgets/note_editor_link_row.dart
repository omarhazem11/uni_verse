import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import 'link_task_sheet.dart';

class NoteEditorLinkRow extends ConsumerWidget {
  final String? linkedTaskId;
  final ValueChanged<String?> onChanged;

  const NoteEditorLinkRow({super.key, required this.linkedTaskId, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksStreamProvider).value ?? [];
    final matches = tasks.where((t) => t.id == linkedTaskId);
    final linkedTask = matches.isEmpty ? null : matches.first;
    final isLinked = linkedTaskId != null;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isLinked ? AppColors.tileVioletBg : AppColors.bg,
          borderRadius: BorderRadius.circular(12),
          border: isLinked ? Border.all(color: AppColors.violet.withValues(alpha: 0.3)) : null,
        ),
        child: Row(
          children: [
            Icon(Icons.link_rounded, size: 18, color: isLinked ? AppColors.violet : AppColors.muted),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLinked ? 'Linked task' : 'Link to a task',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isLinked ? AppColors.tileVioletText : AppColors.muted,
                    ),
                  ),
                  if (isLinked) ...[
                    const SizedBox(height: 2),
                    Text(
                      linkedTask?.title ?? 'Task',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink),
                    ),
                  ],
                ],
              ),
            ),
            if (isLinked)
              GestureDetector(
                onTap: () => onChanged(null),
                behavior: HitTestBehavior.opaque,
                child: const Icon(Icons.close_rounded, size: 20, color: AppColors.muted),
              )
            else
              const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.muted),
          ],
        ),
      ),
    );
  }

  Future<void> _openSheet(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => LinkTaskSheet(currentTaskId: linkedTaskId),
    );
    if (result == null) return;
    onChanged(result.isEmpty ? null : result);
  }
}
