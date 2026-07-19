import 'package:flutter/material.dart';

/// Pan/zoom math for a fixed-size content canvas inside a smaller viewport.
/// Kept separate from DrawingCanvas purely to keep that file under the
/// line-count budget.
class CanvasTransform {
  final Size contentSize;
  final double minScale;
  final double maxScale;

  const CanvasTransform({required this.contentSize, this.minScale = 0.25, this.maxScale = 4.0});

  double clampScale(double scale) => scale.clamp(minScale, maxScale);

  Offset toContent(Offset viewportLocal, Offset pan, double scale) => (viewportLocal - pan) / scale;

  /// Keeps the content point under [focalPoint] fixed on screen while the
  /// scale changes — the standard pinch-to-zoom-at-point formula.
  Offset panForZoomAnchor({
    required Offset focalPoint,
    required Offset oldPan,
    required double oldScale,
    required double newScale,
  }) {
    final contentFocal = (focalPoint - oldPan) / oldScale;
    return focalPoint - contentFocal * newScale;
  }

  /// Prevents the content from scrolling past its own edges; centers it if
  /// the (scaled) content is smaller than the viewport on that axis.
  Offset clampPan(Offset pan, double scale, Size viewportSize) {
    double clampAxis(double p, double viewport, double content) {
      if (content <= viewport) return (viewport - content) / 2;
      return p.clamp(viewport - content, 0.0);
    }

    final scaledW = contentSize.width * scale;
    final scaledH = contentSize.height * scale;
    return Offset(
      clampAxis(pan.dx, viewportSize.width, scaledW),
      clampAxis(pan.dy, viewportSize.height, scaledH),
    );
  }
}
