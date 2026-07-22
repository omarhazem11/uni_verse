import 'package:flutter/material.dart';
import '../../../planner/presentation/utils/schedule_color.dart';
import '../../domain/entities/drawing_stroke_entity.dart';
import 'drawing_canvas.dart';
import 'drawing_toolbar.dart';
import 'drawing_toolbar_toggle_handle.dart';

const _toolbarWidth = 64.0;

class NoteEditorDrawTab extends StatefulWidget {
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
  State<NoteEditorDrawTab> createState() => _NoteEditorDrawTabState();
}

class _NoteEditorDrawTabState extends State<NoteEditorDrawTab> {
  // Starts visible; the phone's own gesture/nav bar overlapping a *bottom*
  // toolbar was the whole reason this moved to the side, but a side panel
  // can still eat into a narrow phone's drawing space, hence the toggle.
  bool _toolbarVisible = true;

  @override
  Widget build(BuildContext context) {
    final canvasBg =
        Color.alphaBlend(colorFromHex(widget.noteColorHex).withValues(alpha: 0.08), Colors.white);
    return Stack(
      children: [
        Row(
          children: [
            Expanded(
              child: DrawingCanvas(
                key: widget.canvasKey,
                initialStrokes: widget.strokes,
                tool: widget.tool,
                colorHex: widget.colorHex,
                strokeWidth: widget.strokeWidth,
                backgroundColor: canvasBg,
                onStrokesChanged: widget.onStrokesChanged,
                onHistoryChanged: widget.onHistoryChanged,
                onZoomChanged: widget.onZoomChanged,
              ),
            ),
            ClipRect(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: _toolbarVisible ? _toolbarWidth : 0,
                child: OverflowBox(
                  minWidth: _toolbarWidth,
                  maxWidth: _toolbarWidth,
                  alignment: Alignment.centerRight,
                  child: _buildToolbar(),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          right: _toolbarVisible ? _toolbarWidth - 1 : 0,
          top: 0,
          bottom: 0,
          child: Center(
            child: ToolbarToggleHandle(
              visible: _toolbarVisible,
              onTap: () => setState(() => _toolbarVisible = !_toolbarVisible),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return DrawingToolbar(
      tool: widget.tool,
      colorHex: widget.colorHex,
      strokeWidth: widget.strokeWidth,
      canUndo: widget.canUndo,
      canRedo: widget.canRedo,
      zoom: widget.zoom,
      onToolChanged: widget.onToolChanged,
      onColorChanged: widget.onColorChanged,
      onWidthChanged: widget.onWidthChanged,
      onUndo: () => widget.canvasKey.currentState?.undo(),
      onRedo: () => widget.canvasKey.currentState?.redo(),
      onClear: () => widget.canvasKey.currentState?.clearAll(),
      onZoomIn: () => widget.canvasKey.currentState?.zoomBy(1.25),
      onZoomOut: () => widget.canvasKey.currentState?.zoomBy(0.8),
    );
  }
}
