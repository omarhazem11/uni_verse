import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Zoom out / percentage / zoom in group for [DrawingToolbar] — split out
/// purely to keep the toolbar file under the line-count budget.
class ZoomControls extends StatelessWidget {
  final double zoom;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const ZoomControls({super.key, required this.zoom, required this.onZoomIn, required this.onZoomOut});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onZoomOut,
          icon: const Icon(Icons.zoom_out_rounded),
          color: AppColors.ink,
        ),
        SizedBox(
          width: 42,
          child: Text(
            '${(zoom * 100).round()}%',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          onPressed: onZoomIn,
          icon: const Icon(Icons.zoom_in_rounded),
          color: AppColors.ink,
        ),
      ],
    );
  }
}
