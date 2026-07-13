import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TaskUrgency {
  final double fillPercent;
  final Color color;
  final String centerLabel;
  final bool isOverdue;

  const TaskUrgency({
    required this.fillPercent,
    required this.color,
    required this.centerLabel,
    required this.isOverdue,
  });
}

/// Fill percentage represents urgency, not literal time elapsed — bands are
/// deliberately coarse so the ring reads at a glance rather than as a precise
/// countdown.
TaskUrgency computeTaskUrgency(DateTime dueDate, DateTime now) {
  final diff = dueDate.difference(now);
  final hoursRemaining = diff.inHours;

  if (hoursRemaining < 0) {
    return const TaskUrgency(
      fillPercent: 1.0,
      color: AppColors.coral,
      centerLabel: '!',
      isOverdue: true,
    );
  }
  if (hoursRemaining >= 72) {
    return TaskUrgency(
      fillPercent: 0.25,
      color: AppColors.mint,
      centerLabel: '${diff.inDays}d',
      isOverdue: false,
    );
  }
  if (hoursRemaining >= 24) {
    return TaskUrgency(
      fillPercent: 0.60,
      color: AppColors.amber,
      centerLabel: '${diff.inDays}d',
      isOverdue: false,
    );
  }
  return TaskUrgency(
    fillPercent: 0.90,
    color: AppColors.coral,
    centerLabel: '${hoursRemaining}h',
    isOverdue: false,
  );
}
