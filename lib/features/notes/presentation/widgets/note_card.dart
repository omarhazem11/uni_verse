import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../planner/presentation/utils/schedule_color.dart';
import '../../domain/entities/note_entity.dart';
import '../utils/relative_time_format.dart';
import 'tag_chip.dart';

class NoteCard extends StatelessWidget {
  final NoteEntity note;
  final VoidCallback onTap;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onEnterSelectionMode;
  final VoidCallback? onToggleSelect;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onEnterSelectionMode,
    this.onToggleSelect,
  });

  @override
  Widget build(BuildContext context) {
    final accent = colorFromHex(note.colorHex);

    return GestureDetector(
      onTap: isSelectionMode ? onToggleSelect : onTap,
      onLongPress: isSelectionMode ? null : onEnterSelectionMode,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.violet.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: isSelected ? 0.02 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: isSelected
              ? Border.all(color: AppColors.violet.withValues(alpha: 0.4), width: 1.5)
              : null,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              note.title.isEmpty ? 'Untitled' : note.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.nunito(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          if (note.linkedTaskId != null && !isSelectionMode) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.link_rounded, size: 15, color: AppColors.muted),
                          ],
                          if (isSelectionMode) ...[
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: isSelected,
                                onChanged: (_) => onToggleSelect?.call(),
                                activeColor: AppColors.violet,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (note.body.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          note.body,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted, height: 1.35),
                        ),
                      ],
                      if (note.tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: note.tags.map((tag) => TagChip(label: tag)).toList(),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        relativeTimeLabel(note.updatedAt),
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
