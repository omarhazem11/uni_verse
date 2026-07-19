import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class NoteEditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isEditing;
  final bool saving;
  final VoidCallback onDelete;
  final VoidCallback onSave;

  const NoteEditorAppBar({
    super.key,
    required this.isEditing,
    required this.saving,
    required this.onDelete,
    required this.onSave,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.ink),
      title: Text(
        isEditing ? 'Edit Note' : 'New Note',
        style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink),
      ),
      actions: [
        if (isEditing)
          IconButton(
            onPressed: saving ? null : onDelete,
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.coral),
          ),
        IconButton(
          key: const Key('noteEditorSaveButton'),
          onPressed: saving ? null : onSave,
          icon: const Icon(Icons.check_rounded, color: AppColors.violet),
        ),
      ],
    );
  }
}
