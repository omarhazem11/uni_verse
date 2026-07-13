import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Reusable small pill for a tag — used in the notes list filter row and the
/// editor's tag picker. [onTap] toggles selection; [onRemove] (editor only)
/// shows a trailing X to delete the tag from the note.
class TagChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const TagChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(left: 12, right: onRemove != null ? 6 : 12, top: 6, bottom: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.violet : AppColors.bg,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.muted,
              ),
            ),
            if (onRemove != null) ...[
              const SizedBox(width: 2),
              GestureDetector(
                onTap: onRemove,
                child: Icon(Icons.close_rounded, size: 15, color: isSelected ? Colors.white : AppColors.muted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
