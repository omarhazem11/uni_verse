import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/schedule_item_entity.dart';

class ScheduleItemModel extends ScheduleItemEntity {
  const ScheduleItemModel({
    required super.id,
    required super.title,
    super.description,
    required super.date,
    required super.startTime,
    required super.endTime,
    required super.colorHex,
    required super.emoji,
    required super.createdAt,
  });

  factory ScheduleItemModel.fromEntity(ScheduleItemEntity item) {
    return ScheduleItemModel(
      id: item.id,
      title: item.title,
      description: item.description,
      date: item.date,
      startTime: item.startTime,
      endTime: item.endTime,
      colorHex: item.colorHex,
      emoji: item.emoji,
      createdAt: item.createdAt,
    );
  }

  factory ScheduleItemModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ScheduleItemModel(
      id: doc.id,
      title: data['title'] as String,
      description: data['description'] as String?,
      date: (data['date'] as Timestamp).toDate(),
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      colorHex: data['colorHex'] as String,
      emoji: data['emoji'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'colorHex': colorHex,
      'emoji': emoji,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
