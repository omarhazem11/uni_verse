import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class TaskDetailDescriptionCard extends StatelessWidget {
  final String? description;

  const TaskDetailDescriptionCard({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    final hasDescription = description != null && description!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.ink),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: AppColors.ink.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Text(
            hasDescription ? description!.trim() : 'No description added',
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.5,
              color: hasDescription ? AppColors.ink : AppColors.muted,
              fontStyle: hasDescription ? FontStyle.normal : FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}
