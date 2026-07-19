import 'package:uuid/uuid.dart';
import '../../domain/entities/drawing_stroke_entity.dart';
import 'canvas_tool.dart';

// Highlighter strokes render fatter than the selected width so they read
// as a highlighter even at the "thin" preset.
const highlighterWidthFactor = 2.2;

double _effectiveWidth(double strokeWidth, CanvasTool tool) =>
    tool == CanvasTool.highlighter ? strokeWidth * highlighterWidthFactor : strokeWidth;

DrawingTool _domainTool(CanvasTool tool) =>
    tool == CanvasTool.highlighter ? DrawingTool.highlighter : DrawingTool.pen;

DrawingStrokeEntity buildStroke({
  required List<DrawingPointEntity> points,
  required String colorHex,
  required double strokeWidth,
  required CanvasTool tool,
}) {
  return DrawingStrokeEntity(
    id: const Uuid().v4(),
    points: points,
    colorHex: colorHex,
    strokeWidth: _effectiveWidth(strokeWidth, tool),
    tool: _domainTool(tool),
  );
}

DrawingStrokeEntity buildActiveStroke({
  required List<DrawingPointEntity> points,
  required String colorHex,
  required double strokeWidth,
  required CanvasTool tool,
}) {
  return DrawingStrokeEntity(
    id: '_active',
    points: points,
    colorHex: colorHex,
    strokeWidth: _effectiveWidth(strokeWidth, tool),
    tool: _domainTool(tool),
  );
}
