import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/note_entity.dart';

class NoteModel extends NoteEntity {
  const NoteModel({
    required super.id,
    required super.title,
    required super.body,
    super.tags,
    super.linkedTaskId,
    required super.colorHex,
    required super.createdAt,
    required super.updatedAt,
  });

  factory NoteModel.fromEntity(NoteEntity note) {
    return NoteModel(
      id: note.id,
      title: note.title,
      body: note.body,
      tags: note.tags,
      linkedTaskId: note.linkedTaskId,
      colorHex: note.colorHex,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
  }

  factory NoteModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return NoteModel(
      id: doc.id,
      title: data['title'] as String,
      body: data['body'] as String,
      tags: List<String>.from(data['tags'] as List? ?? const []),
      linkedTaskId: data['linkedTaskId'] as String?,
      colorHex: data['colorHex'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'tags': tags,
      'linkedTaskId': linkedTaskId,
      'colorHex': colorHex,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
