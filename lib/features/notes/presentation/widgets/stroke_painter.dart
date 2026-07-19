import 'package:flutter/material.dart';
import '../../../planner/presentation/utils/schedule_color.dart';
import '../../domain/entities/drawing_stroke_entity.dart';

/// Paints completed strokes plus the in-progress stroke (if any) on top.
/// Highlighter strokes render semi-transparent; pen strokes are opaque.
class StrokePainter extends CustomPainter {
  final List<DrawingStrokeEntity> strokes;
  final DrawingStrokeEntity? activeStroke;

  StrokePainter({required this.strokes, this.activeStroke});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _paintStroke(canvas, stroke);
    }
    if (activeStroke != null) {
      _paintStroke(canvas, activeStroke!);
    }
  }

  void _paintStroke(Canvas canvas, DrawingStrokeEntity stroke) {
    if (stroke.points.isEmpty) return;

    final isHighlighter = stroke.tool == DrawingTool.highlighter;
    final paint = Paint()
      ..color = isHighlighter
          ? colorFromHex(stroke.colorHex).withValues(alpha: 0.35)
          : colorFromHex(stroke.colorHex)
      ..strokeWidth = stroke.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (stroke.points.length == 1) {
      // A tap with no drag — draw a dot so it's still visible.
      final p = stroke.points.first;
      canvas.drawCircle(Offset(p.x, p.y), stroke.strokeWidth / 2, paint..style = PaintingStyle.fill);
      return;
    }

    final path = Path()..moveTo(stroke.points.first.x, stroke.points.first.y);
    for (final point in stroke.points.skip(1)) {
      path.lineTo(point.x, point.y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant StrokePainter oldDelegate) {
    return oldDelegate.strokes != strokes || oldDelegate.activeStroke != activeStroke;
  }
}
