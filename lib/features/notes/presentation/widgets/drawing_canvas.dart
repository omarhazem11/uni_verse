import 'package:flutter/material.dart';
import '../../domain/entities/drawing_stroke_entity.dart';
import '../utils/canvas_session.dart';
import '../utils/canvas_tool.dart';
import '../utils/canvas_transform.dart';
import '../utils/drawing_sound.dart';
import 'stroke_painter.dart';

export '../utils/canvas_tool.dart' show CanvasTool;

// Fixed virtual canvas, larger than any phone viewport — the user scrolls
// and zooms around inside it rather than being limited to one screen.
const _contentSize = Size(2400, 3600);
const _transform = CanvasTransform(contentSize: _contentSize);

class DrawingCanvas extends StatefulWidget {
  final List<DrawingStrokeEntity> initialStrokes;
  final CanvasTool tool;
  final String colorHex;
  final double strokeWidth;
  final Color backgroundColor;
  final ValueChanged<List<DrawingStrokeEntity>> onStrokesChanged;
  final void Function({required bool canUndo, required bool canRedo})? onHistoryChanged;
  final ValueChanged<double>? onZoomChanged;

  const DrawingCanvas({
    super.key,
    required this.initialStrokes,
    required this.tool,
    required this.colorHex,
    required this.strokeWidth,
    required this.onStrokesChanged,
    this.onHistoryChanged,
    this.onZoomChanged,
    this.backgroundColor = Colors.white,
  });

  @override
  State<DrawingCanvas> createState() => DrawingCanvasState();
}

class DrawingCanvasState extends State<DrawingCanvas> {
  late final _session = CanvasSession(transform: _transform, initialStrokes: widget.initialStrokes);

  bool get canUndo => _session.canUndo;
  bool get canRedo => _session.canRedo;

  void undo() {
    if (!canUndo) return;
    setState(_session.undo);
    _notify();
  }

  void redo() {
    if (!canRedo) return;
    setState(_session.redo);
    _notify();
  }

  void clearAll() {
    setState(_session.clearAll);
    _notify();
  }

  void zoomBy(double factor) {
    setState(() => _session.zoomBy(factor));
    widget.onZoomChanged?.call(_session.scale);
  }

  void _notify() {
    widget.onStrokesChanged(_session.strokes);
    widget.onHistoryChanged?.call(canUndo: canUndo, canRedo: canRedo);
  }

  void _onScaleStart(ScaleStartDetails d) {
    final result = _session.onScaleStart(d, widget.tool);
    setState(() {});
    if (result.startedStroke) {
      DrawingSound.startStroke(isHighlighter: widget.tool == CanvasTool.highlighter);
    }
    if (result.erased) {
      DrawingSound.eraseDeleted();
      _notify();
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    final erased = _session.onScaleUpdate(d, widget.tool);
    setState(() {});
    if (erased) {
      DrawingSound.eraseDeleted();
      _notify();
    }
    widget.onZoomChanged?.call(_session.scale);
  }

  void _onScaleEnd(ScaleEndDetails d) {
    final committed = _session.onScaleEnd(widget.tool, widget.colorHex, widget.strokeWidth);
    setState(() {});
    DrawingSound.stopStroke();
    if (committed) _notify();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _session.viewportSize = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: _onScaleEnd,
          child: ClipRect(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: widget.backgroundColor,
              child: Transform(
                transform: Matrix4.identity()
                  ..translateByDouble(_session.pan.dx, _session.pan.dy, 0, 1)
                  ..scaleByDouble(_session.scale, _session.scale, 1, 1),
                child: SizedBox(
                  width: _contentSize.width,
                  height: _contentSize.height,
                  child: Container(
                    color: widget.backgroundColor,
                    child: CustomPaint(
                      painter: StrokePainter(
                        strokes: _session.strokes,
                        activeStroke: _session.activeStroke(widget.colorHex, widget.strokeWidth, widget.tool),
                      ),
                      size: _contentSize,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
