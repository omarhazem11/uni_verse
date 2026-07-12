import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Shared confirmation dialog used by both swipe-to-delete on the task
/// list and the "Delete Task" button on the detail page, so both paths
/// show exactly the same prompt.
Future<bool> showDeleteTaskDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete this task?', style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
      content: Text('This can\'t be undone.', style: GoogleFonts.inter()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete', style: TextStyle(color: AppColors.coral)),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
