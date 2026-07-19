import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

enum NoteEditorTab { text, draw }

/// Pill-style segmented control matching the app's tag-chip look — used to
/// switch between the text fields and the drawing canvas without losing
/// either one's content (both stay mounted in the parent's state).
class NoteEditorTabSwitcher extends StatelessWidget {
  final NoteEditorTab selected;
  final ValueChanged<NoteEditorTab> onChanged;

  const NoteEditorTabSwitcher({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(100)),
      child: Row(
        children: [
          _segment(context, NoteEditorTab.text, 'Text', Icons.text_fields_rounded),
          _segment(context, NoteEditorTab.draw, 'Draw', Icons.brush_rounded),
        ],
      ),
    );
  }

  Widget _segment(BuildContext context, NoteEditorTab tab, String label, IconData icon) {
    final isSelected = selected == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.violet : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.muted),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
