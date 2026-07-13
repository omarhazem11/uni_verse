import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Full-width pill CTA shown on a task's detail page only when a note is
/// linked to it.
class ViewNotesButton extends StatelessWidget {
  final VoidCallback onTap;

  const ViewNotesButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.description_outlined, size: 18, color: AppColors.tileMintText),
        label: Text(
          'View Notes',
          style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.tileMintText),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.mint),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        ),
      ),
    );
  }
}
