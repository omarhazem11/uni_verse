import 'package:equatable/equatable.dart';

class ScheduleItemEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime date; // the day this item belongs to (time part ignored)
  final DateTime startTime; // full DateTime with time component
  final DateTime endTime;
  final String colorHex; // '#RRGGBB', one of AppColors accent set
  final String emoji; // e.g. "📚", "☕", "🏃"
  final DateTime createdAt;

  const ScheduleItemEntity({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.colorHex,
    required this.emoji,
    required this.createdAt,
  });

  ScheduleItemEntity copyWith({
    String? title,
    String? description,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    String? colorHex,
    String? emoji,
  }) {
    return ScheduleItemEntity(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      colorHex: colorHex ?? this.colorHex,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, description, date, startTime, endTime, colorHex, emoji, createdAt];
}
