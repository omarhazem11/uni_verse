import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class NotesEmptyState extends StatelessWidget {
  final VoidCallback onCreateNote;

  const NotesEmptyState({super.key, required this.onCreateNote});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: AppColors.tileMintBg, borderRadius: BorderRadius.circular(24)),
            child: const Icon(Icons.description_outlined, color: AppColors.mint, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            'No notes yet — jot something down! 📝',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onCreateNote,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.violet,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            child: Text(
              'New Note',
              style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class NotesNoResultsState extends StatelessWidget {
  const NotesNoResultsState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No notes match that search',
        style: GoogleFonts.inter(fontSize: 14, color: AppColors.muted),
      ),
    );
  }
}
