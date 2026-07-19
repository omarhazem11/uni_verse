import 'package:flutter/material.dart';
import '../../../planner/presentation/utils/schedule_color.dart';
import '../../domain/entities/drawing_stroke_entity.dart';
import 'drawing_canvas.dart';
import 'drawing_toolbar.dart';

class NoteEditorDrawTab extends StatelessWidget {
  final GlobalKey<DrawingCanvasState> canvasKey;
  final List<DrawingStrokeEntity> strokes;
  final CanvasTool tool;
  final String colorHex;
  final double strokeWidth;
  final String noteColorHex;
  final bool canUndo;
  final bool canRedo;
  final double zoom;
  final ValueChanged<List<DrawingStrokeEntity>> onStrokesChanged;
  final void Function({required bool canUndo, required bool canRedo}) onHistoryChanged;
  final ValueChanged<CanvasTool> onToolChanged;
  final ValueChanged<String> onColorChanged;
  final ValueChanged<double> onWidthChanged;
  final ValueChanged<double> onZoomChanged;

  const NoteEditorDrawTab({
    super.key,
    required this.canvasKey,
    required this.strokes,
    required this.tool,
    required this.colorHex,
    required this.strokeWidth,
    required this.noteColorHex,
    required this.canUndo,
    required this.canRedo,
    required this.zoom,
    required this.onStrokesChanged,
    required this.onHistoryChanged,
    required this.onToolChanged,
    required this.onColorChanged,
    required this.onWidthChanged,
    required this.onZoomChanged,
  });

  @override
  Widget build(BuildContext context) {
    final canvasBg = Color.alphaBlend(colorFromHex(noteColorHex).withValues(alpha: 0.08), Colors.white);
    return Column(
      children: [
        Expanded(
          child: DrawingCanvas(
            key: canvasKey,
            initialStrokes: strokes,
            tool: tool,
            colorHex: colorHex,
            strokeWidth: strokeWidth,
            backgroundColor: canvasBg,
            onStrokesChanged: onStrokesChanged,
            onHistoryChanged: onHistoryChanged,
            onZoomChanged: onZoomChanged,
          ),
        ),
        DrawingToolbar(
          tool: tool,
          colorHex: colorHex,
          strokeWidth: strokeWidth,
          canUndo: canUndo,
          canRedo: canRedo,
          zoom: zoom,
          onToolChanged: onToolChanged,
          onColorChanged: onColorChanged,
          onWidthChanged: onWidthChanged,
          onUndo: () => canvasKey.currentState?.undo(),
          onRedo: () => canvasKey.currentState?.redo(),
          onClear: () => canvasKey.currentState?.clearAll(),
          onZoomIn: () => canvasKey.currentState?.zoomBy(1.25),
          onZoomOut: () => canvasKey.currentState?.zoomBy(0.8),
        ),
      ],
    );
  }
}
