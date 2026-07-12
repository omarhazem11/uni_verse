import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    super.description,
    super.priority,
    super.category,
    super.dueDate,
    super.reminderOffset,
    super.customReminderDateTime,
    super.isCompleted,
    required super.createdAt,
  });

  factory TaskModel.fromEntity(TaskEntity task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      priority: task.priority,
      category: task.category,
      dueDate: task.dueDate,
      reminderOffset: task.reminderOffset,
      customReminderDateTime: task.customReminderDateTime,
      isCompleted: task.isCompleted,
      createdAt: task.createdAt,
    );
  }

  factory TaskModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final reminderMinutes = data['reminderOffsetMinutes'] as int?;

    return TaskModel(
      id: doc.id,
      title: data['title'] as String,
      description: data['description'] as String?,
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == data['priority'],
        orElse: () => TaskPriority.medium,
      ),
      category: TaskCategory.values.firstWhere(
        (c) => c.name == data['category'],
        orElse: () => TaskCategory.other,
      ),
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      reminderOffset:
          reminderMinutes != null ? Duration(minutes: reminderMinutes) : null,
      customReminderDateTime: (data['customReminderDateTime'] as Timestamp?)?.toDate(),
      isCompleted: data['isCompleted'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'priority': priority.name,
      'category': category.name,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'reminderOffsetMinutes': reminderOffset?.inMinutes,
      'customReminderDateTime':
          customReminderDateTime != null ? Timestamp.fromDate(customReminderDateTime!) : null,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
