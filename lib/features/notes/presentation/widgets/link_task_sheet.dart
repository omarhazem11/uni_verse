import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../tasks/presentation/providers/task_provider.dart';

/// Bottom sheet listing incomplete tasks to link a note to. Returns the
/// picked task's id, or `null` if the user chose "None" / dismissed it
/// without a change (callers should only clear the link on an explicit tap).
class LinkTaskSheet extends ConsumerWidget {
  final String? currentTaskId;

  const LinkTaskSheet({super.key, this.currentTaskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = (ref.watch(tasksStreamProvider).value ?? [])
        .where((t) => !t.isCompleted)
        .toList();

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Link to a task',
              style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.close_rounded, color: AppColors.muted),
              title: Text('None', style: GoogleFonts.inter(fontSize: 14, color: AppColors.ink)),
              onTap: () => Navigator.pop(context, ''),
            ),
            if (tasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No incomplete tasks to link',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: tasks.length,
                  itemBuilder: (context, i) {
                    final task = tasks[i];
                    final isSelected = task.id == currentTaskId;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        color: isSelected ? AppColors.violet : AppColors.muted,
                      ),
                      title: Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 14, color: AppColors.ink),
                      ),
                      onTap: () => Navigator.pop(context, task.id),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
