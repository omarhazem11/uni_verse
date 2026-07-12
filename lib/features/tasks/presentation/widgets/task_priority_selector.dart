import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/task_entity.dart';
import '../utils/task_display_helpers.dart';

class TaskPrioritySelector extends StatelessWidget {
  final TaskPriority selected;
  final ValueChanged<TaskPriority> onChanged;

  const TaskPrioritySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TaskPriority.values.map((priority) {
        final isSelected = priority == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: priority == TaskPriority.high ? 0 : 8),
            child: GestureDetector(
              onTap: () => onChanged(priority),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? priority.color : AppColors.bg,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  priority.label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.muted,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
