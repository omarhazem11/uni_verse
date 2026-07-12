import 'package:equatable/equatable.dart';

enum TaskPriority { low, medium, high }

enum TaskCategory { assignment, exam, project, other }

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final TaskPriority priority;
  final TaskCategory category;
  final DateTime? dueDate;
  final Duration? reminderOffset;
  final bool isCompleted;
  final DateTime createdAt;

  const TaskEntity({
    required this.id,
    required this.title,
    this.description,
    this.priority = TaskPriority.medium,
    this.category = TaskCategory.other,
    this.dueDate,
    this.reminderOffset = const Duration(days: 1),
    this.isCompleted = false,
    required this.createdAt,
  });

  TaskEntity copyWith({
    String? title,
    String? description,
    TaskPriority? priority,
    TaskCategory? category,
    DateTime? dueDate,
    bool clearDueDate = false,
    Duration? reminderOffset,
    bool clearReminderOffset = false,
    bool? isCompleted,
  }) {
    return TaskEntity(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      reminderOffset:
          clearReminderOffset ? null : (reminderOffset ?? this.reminderOffset),
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        priority,
        category,
        dueDate,
        reminderOffset,
        isCompleted,
        createdAt,
      ];
}
