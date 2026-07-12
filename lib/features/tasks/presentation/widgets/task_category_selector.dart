import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/task_entity.dart';
import '../utils/task_display_helpers.dart';

class TaskCategorySelector extends StatelessWidget {
  final TaskCategory selected;
  final ValueChanged<TaskCategory> onChanged;

  const TaskCategorySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TaskCategory.values.map((category) {
        final isSelected = category == selected;
        return GestureDetector(
          onTap: () => onChanged(category),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.violet : AppColors.bg,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              '${category.emoji} ${category.label}',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.muted,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
