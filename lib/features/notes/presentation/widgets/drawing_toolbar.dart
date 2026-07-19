import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/horizontal_scroll_hint.dart';
import '../../../planner/presentation/utils/schedule_color.dart';
import 'drawing_canvas.dart';
import 'drawing_toolbar_controls.dart';
import 'zoom_controls.dart';

const _widthPresets = [3.0, 6.0, 10.0];

class DrawingToolbar extends StatelessWidget {
  final CanvasTool tool;
  final String colorHex;
  final double strokeWidth;
  final bool canUndo;
  final bool canRedo;
  final double zoom;
  final ValueChanged<CanvasTool> onToolChanged;
  final ValueChanged<String> onColorChanged;
  final ValueChanged<double> onWidthChanged;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onClear;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const DrawingToolbar({
    super.key,
    required this.tool,
    required this.colorHex,
    required this.strokeWidth,
    required this.canUndo,
    required this.canRedo,
    required this.zoom,
    required this.onToolChanged,
    required this.onColorChanged,
    required this.onWidthChanged,
    required this.onUndo,
    required this.onRedo,
    required this.onClear,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  bool get _showColorControls => tool != CanvasTool.eraser && tool != CanvasTool.pan;
  bool get _showWidthControls => tool != CanvasTool.pan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: HorizontalScrollHint(
        builder: (context, controller) => SingleChildScrollView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ToolButton(icon: Icons.edit_rounded, selected: tool == CanvasTool.pen,
                onTap: () => onToolChanged(CanvasTool.pen)),
            ToolButton(icon: Icons.brush_rounded, selected: tool == CanvasTool.highlighter,
                onTap: () => onToolChanged(CanvasTool.highlighter)),
            ToolButton(icon: Icons.auto_fix_normal_rounded, selected: tool == CanvasTool.eraser,
                onTap: () => onToolChanged(CanvasTool.eraser)),
            ToolButton(icon: Icons.pan_tool_rounded, selected: tool == CanvasTool.pan,
                onTap: () => onToolChanged(CanvasTool.pan)),
            const SizedBox(width: 10),
            Container(width: 1, height: 28, color: AppColors.divider),
            const SizedBox(width: 10),
            if (_showColorControls) ...[
              for (final hex in plannerColorPalette) DrawingColorSwatch(
                hex: hex,
                selected: hex == colorHex,
                onTap: () => onColorChanged(hex),
              ),
              const SizedBox(width: 10),
              Container(width: 1, height: 28, color: AppColors.divider),
              const SizedBox(width: 10),
            ],
            if (_showWidthControls) ...[
              for (final w in _widthPresets) WidthPreset(
                width: w,
                selected: w == strokeWidth,
                onTap: () => onWidthChanged(w),
              ),
              const SizedBox(width: 10),
              Container(width: 1, height: 28, color: AppColors.divider),
              const SizedBox(width: 10),
            ],
            IconButton(
              onPressed: canUndo ? onUndo : null,
              icon: const Icon(Icons.undo_rounded),
              color: canUndo ? AppColors.ink : AppColors.muted.withValues(alpha: 0.4),
            ),
            IconButton(
              onPressed: canRedo ? onRedo : null,
              icon: const Icon(Icons.redo_rounded),
              color: canRedo ? AppColors.ink : AppColors.muted.withValues(alpha: 0.4),
            ),
            IconButton(
              onPressed: () => _confirmClear(context),
              icon: const Icon(Icons.delete_outline_rounded),
              color: AppColors.coral,
            ),
            const SizedBox(width: 10),
            Container(width: 1, height: 28, color: AppColors.divider),
            const SizedBox(width: 4),
            ZoomControls(zoom: zoom, onZoomIn: onZoomIn, onZoomOut: onZoomOut),
          ],
        ),
        ),
        fadeColor: Colors.white,
        badgeColor: AppColors.violet,
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear drawing?'),
        content: const Text('This removes all strokes on the canvas. This can\'t be undone once you save.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear', style: TextStyle(color: AppColors.coral)),
          ),
        ],
      ),
    );
    if (confirmed == true) onClear();
  }
}
