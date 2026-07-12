import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TaskCheckbox extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback onTap;
  final double size;

  const TaskCheckbox({
    super.key,
    required this.isCompleted,
    required this.onTap,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCompleted ? AppColors.mint : Colors.transparent,
          border: Border.all(
            color: isCompleted ? AppColors.mint : AppColors.muted,
            width: 2,
          ),
        ),
        child: isCompleted
            ? Icon(Icons.check_rounded, size: size * 0.67, color: Colors.white)
            : null,
      ),
    );
  }
}
