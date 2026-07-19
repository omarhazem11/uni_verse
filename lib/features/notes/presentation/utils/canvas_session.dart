import 'package:flutter/material.dart';
import '../../domain/entities/drawing_stroke_entity.dart';
import 'canvas_tool.dart';
import 'canvas_transform.dart';
import 'stroke_builder.dart';
import 'stroke_hit_test.dart';

const eraseRadius = 14.0;

enum _Mode { none, draw, panZoom }

/// Owns all mutable drawing/pan/zoom state for DrawingCanvas. Plain object
/// (not a widget) so gesture math can live outside drawing_canvas.dart and
/// keep that file under the line-count budget — the State class just calls
/// these methods inside setState and reacts to their return values.
class CanvasSession {
  final CanvasTransform transform;
  List<DrawingStrokeEntity> strokes;
  final List<DrawingStrokeEntity> redoStack = [];
  List<DrawingPointEntity> activePoints = [];

  double scale = 1.0;
  Offset pan = Offset.zero;
  Size viewportSize = Size.zero;

  double _scaleAtGestureStart = 1.0;
  _Mode _mode = _Mode.none;

  CanvasSession({required this.transform, required List<DrawingStrokeEntity> initialStrokes})
      : strokes = List.of(initialStrokes);

  bool get canUndo => strokes.isNotEmpty;
  bool get canRedo => redoStack.isNotEmpty;

  void undo() {
    if (canUndo) redoStack.add(strokes.removeLast());
  }

  void redo() {
    if (canRedo) strokes.add(redoStack.removeLast());
  }

  void clearAll() {
    strokes = [];
    redoStack.clear();
  }

  void zoomBy(double factor) {
    final newScale = transform.clampScale(scale * factor);
    final center = Offset(viewportSize.width / 2, viewportSize.height / 2);
    pan = transform.panForZoomAnchor(focalPoint: center, oldPan: pan, oldScale: scale, newScale: newScale);
    scale = newScale;
    pan = transform.clampPan(pan, scale, viewportSize);
  }

  ({bool startedStroke, bool erased}) onScaleStart(ScaleStartDetails d, CanvasTool tool) {
    if (d.pointerCount >= 2 || tool == CanvasTool.pan) {
      _mode = _Mode.panZoom;
      _scaleAtGestureStart = scale;
      return (startedStroke: false, erased: false);
    }
    _mode = _Mode.draw;
    final p = transform.toContent(d.localFocalPoint, pan, scale);
    if (tool == CanvasTool.eraser) {
      return (startedStroke: false, erased: _eraseAt(p));
    }
    activePoints = [DrawingPointEntity(x: p.dx, y: p.dy)];
    return (startedStroke: true, erased: false);
  }

  bool onScaleUpdate(ScaleUpdateDetails d, CanvasTool tool) {
    if (_mode == _Mode.panZoom) {
      final oldScale = scale;
      final newScale = transform.clampScale(_scaleAtGestureStart * d.scale);
      // Pure finger movement — panForZoomAnchor alone can't represent this,
      // it only reacts to scale *changes* (it's a no-op when scale is
      // unchanged, which is exactly the single-finger / no-pinch case).
      pan += d.focalPointDelta;
      if (newScale != oldScale) {
        // Re-anchor around the focal point so pinching zooms toward where
        // the fingers are, not toward the canvas origin.
        pan = transform.panForZoomAnchor(
          focalPoint: d.localFocalPoint, oldPan: pan, oldScale: oldScale, newScale: newScale,
        );
      }
      scale = newScale;
      pan = transform.clampPan(pan, scale, viewportSize);
      return false;
    }
    if (_mode != _Mode.draw) return false;
    final p = transform.toContent(d.localFocalPoint, pan, scale);
    if (tool == CanvasTool.eraser) return _eraseAt(p);
    if (activePoints.isNotEmpty) {
      activePoints = [...activePoints, DrawingPointEntity(x: p.dx, y: p.dy)];
    }
    return false;
  }

  bool onScaleEnd(CanvasTool tool, String colorHex, double strokeWidth) {
    final committed = _mode == _Mode.draw && tool != CanvasTool.eraser && activePoints.isNotEmpty;
    if (committed) {
      strokes = [...strokes, buildStroke(points: activePoints, colorHex: colorHex, strokeWidth: strokeWidth, tool: tool)];
      activePoints = [];
      redoStack.clear();
    }
    _mode = _Mode.none;
    return committed;
  }

  bool _eraseAt(Offset contentPos) {
    final hit = strokes.where((s) => strokeNearPoint(s, contentPos, eraseRadius)).toSet();
    if (hit.isEmpty) return false;
    strokes = strokes.where((s) => !hit.contains(s)).toList();
    redoStack.clear();
    return true;
  }

  DrawingStrokeEntity? activeStroke(String colorHex, double strokeWidth, CanvasTool tool) {
    if (activePoints.isEmpty) return null;
    return buildActiveStroke(points: activePoints, colorHex: colorHex, strokeWidth: strokeWidth, tool: tool);
  }
}
