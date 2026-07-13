import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class NoteEditorFields extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController bodyController;

  const NoteEditorFields({super.key, required this.titleController, required this.bodyController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: titleController,
            style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
            decoration: const InputDecoration(hintText: 'Title', border: InputBorder.none),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: bodyController,
            minLines: 8,
            maxLines: null,
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.ink, height: 1.5),
            decoration: const InputDecoration(hintText: 'Start writing...', border: InputBorder.none),
          ),
        ],
      ),
    );
  }
}
