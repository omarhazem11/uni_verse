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

  const NoteCard({super.key, required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = colorFromHex(note.colorHex);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: AppColors.ink.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        // IntrinsicHeight lets the accent bar (which has no height of its
        // own) stretch to match the text column's height — a plain Row with
        // crossAxisAlignment.stretch can't size itself inside a ListView's
        // unbounded height without it.
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
                          if (note.linkedTaskId != null) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.link_rounded, size: 15, color: AppColors.muted),
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
