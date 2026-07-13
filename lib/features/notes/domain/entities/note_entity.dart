import 'package:equatable/equatable.dart';

class NoteEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final List<String> tags;
  final String? linkedTaskId;
  final String colorHex;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NoteEntity({
    required this.id,
    required this.title,
    required this.body,
    this.tags = const [],
    this.linkedTaskId,
    required this.colorHex,
    required this.createdAt,
    required this.updatedAt,
  });

  NoteEntity copyWith({
    String? title,
    String? body,
    List<String>? tags,
    String? linkedTaskId,
    bool clearLinkedTaskId = false,
    String? colorHex,
    DateTime? updatedAt,
  }) {
    return NoteEntity(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      tags: tags ?? this.tags,
      linkedTaskId: clearLinkedTaskId ? null : (linkedTaskId ?? this.linkedTaskId),
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, title, body, tags, linkedTaskId, colorHex, createdAt, updatedAt];
}
