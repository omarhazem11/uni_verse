import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Small pill shown alongside a task's other metadata chips when a note is
/// linked to it. Uses GestureDetector (not InkWell) so it stays tappable
/// nested inside a task tile's own InkWell without triggering that tile's
/// tap — same pattern as the due-date row's inline clear button.
class ViewNotesChip extends StatelessWidget {
  final VoidCallback onTap;

  const ViewNotesChip({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: AppColors.tileMintBg, borderRadius: BorderRadius.circular(100)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.description_outlined, size: 11, color: AppColors.tileMintText),
            const SizedBox(width: 3),
            Text(
              'View notes',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.tileMintText),
            ),
          ],
        ),
      ),
    );
  }
}
