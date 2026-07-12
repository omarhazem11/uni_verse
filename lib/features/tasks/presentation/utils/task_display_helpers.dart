import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/task_entity.dart';

extension TaskCategoryDisplay on TaskCategory {
  String get emoji => switch (this) {
        TaskCategory.assignment => '📝',
        TaskCategory.exam => '📚',
        TaskCategory.project => '🛠️',
        TaskCategory.other => '📌',
      };

  String get label => switch (this) {
        TaskCategory.assignment => 'Assignment',
        TaskCategory.exam => 'Exam',
        TaskCategory.project => 'Project',
        TaskCategory.other => 'Other',
      };
}

extension TaskPriorityDisplay on TaskPriority {
  Color get color => switch (this) {
        TaskPriority.low => AppColors.mint,
        TaskPriority.medium => AppColors.amber,
        TaskPriority.high => AppColors.coral,
      };

  String get label => switch (this) {
        TaskPriority.low => 'Low',
        TaskPriority.medium => 'Medium',
        TaskPriority.high => 'High',
      };
}
