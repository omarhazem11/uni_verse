import 'package:flutter/material.dart';
import '../../domain/entities/drawing_stroke_entity.dart';

/// True if [pos] lies within [radius] of any segment of [stroke].
bool strokeNearPoint(DrawingStrokeEntity stroke, Offset pos, double radius) {
  if (stroke.points.length == 1) {
    final p = stroke.points.first;
    return (Offset(p.x, p.y) - pos).distance <= radius;
  }
  for (var i = 0; i < stroke.points.length - 1; i++) {
    final a = stroke.points[i];
    final b = stroke.points[i + 1];
    if (_distanceToSegment(pos, Offset(a.x, a.y), Offset(b.x, b.y)) <= radius) {
      return true;
    }
  }
  return false;
}

double _distanceToSegment(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final lenSq = ab.dx * ab.dx + ab.dy * ab.dy;
  if (lenSq == 0) return (p - a).distance;
  final t = (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / lenSq).clamp(0.0, 1.0);
  final projection = a + ab * t;
  return (p - projection).distance;
}
