import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/drawing_stroke_entity.dart';
import '../../domain/entities/note_entity.dart';

class NoteModel extends NoteEntity {
  const NoteModel({
    required super.id,
    required super.title,
    required super.body,
    super.tags,
    super.linkedTaskId,
    required super.colorHex,
    super.strokes,
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
      strokes: note.strokes,
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
      strokes: _strokesFromFirestore(data['strokes'] as List?),
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
      'strokes': strokes.map(_strokeToMap).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static List<DrawingStrokeEntity> _strokesFromFirestore(List? raw) {
    if (raw == null) return const [];
    return raw.map((s) {
      final map = Map<String, dynamic>.from(s as Map);
      final points = (map['points'] as List? ?? const [])
          .map((p) {
            final pt = Map<String, dynamic>.from(p as Map);
            return DrawingPointEntity(
              x: (pt['x'] as num).toDouble(),
              y: (pt['y'] as num).toDouble(),
            );
          })
          .toList();
      return DrawingStrokeEntity(
        id: map['id'] as String,
        points: points,
        colorHex: map['colorHex'] as String,
        strokeWidth: (map['strokeWidth'] as num).toDouble(),
        tool: DrawingTool.values.firstWhere(
          (t) => t.name == map['tool'],
          orElse: () => DrawingTool.pen,
        ),
      );
    }).toList();
  }

  static Map<String, dynamic> _strokeToMap(DrawingStrokeEntity stroke) {
    return {
      'id': stroke.id,
      'points': stroke.points.map((p) => {'x': p.x, 'y': p.y}).toList(),
      'colorHex': stroke.colorHex,
      'strokeWidth': stroke.strokeWidth,
      'tool': stroke.tool.name,
    };
  }
}
