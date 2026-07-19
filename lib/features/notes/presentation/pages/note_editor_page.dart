import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../planner/presentation/utils/schedule_color.dart';
import '../../domain/entities/drawing_stroke_entity.dart';
import '../../domain/entities/note_entity.dart';
import '../providers/note_provider.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/note_delete_dialog.dart';
import '../widgets/note_editor_app_bar.dart';
import '../widgets/note_editor_body.dart';
import '../widgets/note_editor_save.dart';
import '../widgets/note_editor_tab_switcher.dart';

/// Full screen (not a sheet) since notes can run long. Auto-saves on any way
/// out — hardware back, swipe-back, or the app bar's back/save controls all
/// funnel through the single PopScope callback so content is never silently
/// discarded and never double-written.
class NoteEditorPage extends ConsumerStatefulWidget {
  final NoteEntity? existingNote;

  const NoteEditorPage({super.key, this.existingNote});

  @override
  ConsumerState<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends ConsumerState<NoteEditorPage> {
  late final _titleController = TextEditingController(text: widget.existingNote?.title);
  late final _bodyController = TextEditingController(text: widget.existingNote?.body);
  late List<String> _tags = List.of(widget.existingNote?.tags ?? const []);
  late String _colorHex = widget.existingNote?.colorHex ?? plannerColorPalette[1];
  late String? _linkedTaskId;
  late List<DrawingStrokeEntity> _strokes = List.of(widget.existingNote?.strokes ?? const []);
  bool _exiting = false;

  final _canvasKey = GlobalKey<DrawingCanvasState>();
  NoteEditorTab _tab = NoteEditorTab.text;
  CanvasTool _canvasTool = CanvasTool.pen;
  String _canvasColorHex = plannerColorPalette[1];
  double _canvasWidth = 6.0;
  bool _canUndo = false;
  bool _canRedo = false;
  double _canvasZoom = 1.0;

  @override
  void initState() {
    super.initState();
    _linkedTaskId = widget.existingNote?.linkedTaskId;
  }

  bool get _isEditing => widget.existingNote != null;

  bool get _hasContent =>
      _titleController.text.trim().isNotEmpty ||
      _bodyController.text.trim().isNotEmpty ||
      _strokes.isNotEmpty;

  // Single exit path for all routes out (done button, system back, swipe).
  // Pops immediately — Firebase offline cache commits locally before the
  // network round-trip, so content is persisted even before server confirms.
  void _handleExit() {
    if (_exiting) return;
    _exiting = true;

    // Capture before pop — controllers and ref may be disposed afterward.
    final hasContent = _hasContent;
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    final tags = List<String>.of(_tags);
    final colorHex = _colorHex;
    final linkedTaskId = _linkedTaskId;
    final strokes = List<DrawingStrokeEntity>.of(_strokes);
    final existingNote = widget.existingNote;
    final notifier = ref.read(noteActionsProvider.notifier);

    Navigator.of(context).pop();

    if (!hasContent) return;
    saveNoteFromEditor(
      notifier: notifier,
      existingNote: existingNote,
      title: title,
      body: body,
      tags: tags,
      linkedTaskId: linkedTaskId,
      colorHex: colorHex,
      strokes: strokes,
    );
  }

  @override
  Widget build(BuildContext context) {
    final saving = _exiting;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleExit();
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: NoteEditorAppBar(
          isEditing: _isEditing,
          saving: saving,
          onDelete: _delete,
          onSave: _handleExit,
        ),
        body: NoteEditorBody(
          tab: _tab,
          onTabChanged: (t) => setState(() => _tab = t),
          titleController: _titleController,
          bodyController: _bodyController,
          tags: _tags,
          onTagsChanged: (tags) => setState(() => _tags = tags),
          colorHex: _colorHex,
          onColorChanged: (hex) => setState(() => _colorHex = hex),
          linkedTaskId: _linkedTaskId,
          onLinkedTaskChanged: (id) => setState(() => _linkedTaskId = id),
          canvasKey: _canvasKey,
          strokes: _strokes,
          onStrokesChanged: (strokes) => _strokes = strokes,
          canvasTool: _canvasTool,
          onCanvasToolChanged: (t) => setState(() => _canvasTool = t),
          canvasColorHex: _canvasColorHex,
          onCanvasColorChanged: (c) => setState(() => _canvasColorHex = c),
          canvasWidth: _canvasWidth,
          onCanvasWidthChanged: (w) => setState(() => _canvasWidth = w),
          canUndo: _canUndo,
          canRedo: _canRedo,
          onHistoryChanged: ({required canUndo, required canRedo}) {
            setState(() { _canUndo = canUndo; _canRedo = canRedo; });
          },
          canvasZoom: _canvasZoom,
          onCanvasZoomChanged: (z) => setState(() => _canvasZoom = z),
        ),
      ),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDeleteNoteDialog(context);
    if (!confirmed || !mounted) return;
    await ref.read(noteActionsProvider.notifier).deleteNote(widget.existingNote!.id);
    // Explicit pop bypasses PopScope's canPop:false guard (unlike
    // maybePop/system-back), so this doesn't re-trigger the auto-save path
    // and re-create the note we just deleted.
    if (mounted) Navigator.of(context).pop();
  }
}
