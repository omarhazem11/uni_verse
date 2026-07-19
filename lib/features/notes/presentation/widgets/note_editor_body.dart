import 'package:flutter/material.dart';
import '../../domain/entities/drawing_stroke_entity.dart';
import 'drawing_canvas.dart';
import 'note_editor_draw_tab.dart';
import 'note_editor_tab_switcher.dart';
import 'note_editor_text_tab.dart';

/// Tab switcher + IndexedStack of the two tabs — extracted purely to keep
/// NoteEditorPage under the 150-line limit. Both tabs stay mounted via
/// IndexedStack so switching tabs never loses either one's content.
class NoteEditorBody extends StatelessWidget {
  final NoteEditorTab tab;
  final ValueChanged<NoteEditorTab> onTabChanged;
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final List<String> tags;
  final ValueChanged<List<String>> onTagsChanged;
  final String colorHex;
  final ValueChanged<String> onColorChanged;
  final String? linkedTaskId;
  final ValueChanged<String?> onLinkedTaskChanged;
  final GlobalKey<DrawingCanvasState> canvasKey;
  final List<DrawingStrokeEntity> strokes;
  final ValueChanged<List<DrawingStrokeEntity>> onStrokesChanged;
  final CanvasTool canvasTool;
  final ValueChanged<CanvasTool> onCanvasToolChanged;
  final String canvasColorHex;
  final ValueChanged<String> onCanvasColorChanged;
  final double canvasWidth;
  final ValueChanged<double> onCanvasWidthChanged;
  final bool canUndo;
  final bool canRedo;
  final void Function({required bool canUndo, required bool canRedo}) onHistoryChanged;
  final double canvasZoom;
  final ValueChanged<double> onCanvasZoomChanged;

  const NoteEditorBody({
    super.key,
    required this.tab,
    required this.onTabChanged,
    required this.titleController,
    required this.bodyController,
    required this.tags,
    required this.onTagsChanged,
    required this.colorHex,
    required this.onColorChanged,
    required this.linkedTaskId,
    required this.onLinkedTaskChanged,
    required this.canvasKey,
    required this.strokes,
    required this.onStrokesChanged,
    required this.canvasTool,
    required this.onCanvasToolChanged,
    required this.canvasColorHex,
    required this.onCanvasColorChanged,
    required this.canvasWidth,
    required this.onCanvasWidthChanged,
    required this.canUndo,
    required this.canRedo,
    required this.onHistoryChanged,
    required this.canvasZoom,
    required this.onCanvasZoomChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NoteEditorTabSwitcher(selected: tab, onChanged: onTabChanged),
        Expanded(
          child: IndexedStack(
            index: tab == NoteEditorTab.text ? 0 : 1,
            children: [
              NoteEditorTextTab(
                titleController: titleController,
                bodyController: bodyController,
                tags: tags,
                onTagsChanged: onTagsChanged,
                colorHex: colorHex,
                onColorChanged: onColorChanged,
                linkedTaskId: linkedTaskId,
                onLinkedTaskChanged: onLinkedTaskChanged,
              ),
              NoteEditorDrawTab(
                canvasKey: canvasKey,
                strokes: strokes,
                tool: canvasTool,
                colorHex: canvasColorHex,
                strokeWidth: canvasWidth,
                noteColorHex: colorHex,
                canUndo: canUndo,
                canRedo: canRedo,
                zoom: canvasZoom,
                onStrokesChanged: onStrokesChanged,
                onHistoryChanged: onHistoryChanged,
                onToolChanged: onCanvasToolChanged,
                onColorChanged: onCanvasColorChanged,
                onWidthChanged: onCanvasWidthChanged,
                onZoomChanged: onCanvasZoomChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
