import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TaskCheckbox extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback onTap;

  const TaskCheckbox({
    super.key,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCompleted ? AppColors.mint : Colors.transparent,
          border: Border.all(
            color: isCompleted ? AppColors.mint : AppColors.muted,
            width: 2,
          ),
        ),
        child: isCompleted
            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}
