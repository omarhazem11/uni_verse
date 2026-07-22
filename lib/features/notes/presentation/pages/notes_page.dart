import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ad_banner.dart';
import '../providers/note_provider.dart';
import '../widgets/notes_empty_state.dart';
import '../widgets/notes_list_view.dart';
import '../widgets/notes_search_app_bar.dart';
import '../widgets/notes_tag_filter_row.dart';
import 'note_editor_page.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  final Set<String> _selected = {};
  bool _selectionMode = false;

  void _enterSelectionMode(String id) {
    setState(() {
      _selectionMode = true;
      _selected.add(id);
    });
  }

  void _toggleSelect(String id) {
    setState(() {
      _selected.contains(id) ? _selected.remove(id) : _selected.add(id);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selected.clear();
    });
  }

  void _toggleSelectAll(List<String> allIds) {
    setState(() {
      if (_selected.length == allIds.length) {
        _selected.clear();
      } else {
        _selected
          ..clear()
          ..addAll(allIds);
      }
    });
  }

  Future<void> _deleteSelected() async {
    final count = _selected.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Delete $count note${count == 1 ? '' : 's'}?',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
        ),
        content: Text("This can't be undone.", style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.coral)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final notifier = ref.read(noteActionsProvider.notifier);
    for (final id in _selected.toList()) {
      notifier.deleteNote(id);
    }
    _exitSelectionMode();
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesStreamProvider);
    final filtered = ref.watch(filteredNotesProvider);
    final allFilteredIds = filtered.map((n) => n.id).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _selectionMode
          ? _selectionAppBar(allFilteredIds)
          : const NotesSearchAppBar(),
      body: Column(
        children: [
          Expanded(
            child: notesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.violet)),
              error: (_, __) => Center(
                child: Text(
                  "Couldn't load your notes — pull down to try again.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.muted),
                ),
              ),
              data: (notes) => notes.isEmpty
                  ? NotesEmptyState(onCreateNote: () => _openEditor(context))
                  : Column(
                      children: [
                        if (!_selectionMode) ...[
                          const SizedBox(height: 12),
                          const NotesTagFilterRow(),
                          const SizedBox(height: 8),
                        ] else
                          const SizedBox(height: 12),
                        Expanded(
                          child: filtered.isEmpty
                              ? const NotesNoResultsState()
                              : NotesListView(
                                  notes: filtered,
                                  isSelectionMode: _selectionMode,
                                  selectedIds: _selected,
                                  onEnterSelectionMode: _enterSelectionMode,
                                  onToggleSelect: _toggleSelect,
                                ),
                        ),
                      ],
                    ),
            ),
          ),
          const AdBanner(),
        ],
      ),
      floatingActionButton: _selectionMode
          ? null
          : FloatingActionButton(
              onPressed: () => _openEditor(context),
              backgroundColor: AppColors.violet,
              shape: const CircleBorder(),
              child: const Icon(Icons.add_rounded, color: Colors.white),
            ),
    );
  }

  PreferredSizeWidget _selectionAppBar(List<String> allIds) => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.ink),
          onPressed: _exitSelectionMode,
        ),
        title: Text(
          '${_selected.length} selected',
          style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink),
        ),
        actions: [
          IconButton(
            tooltip: _selected.length == allIds.length ? 'Deselect all' : 'Select all',
            icon: Icon(
              _selected.length == allIds.length
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              color: AppColors.violet,
            ),
            onPressed: () => _toggleSelectAll(allIds),
          ),
          IconButton(
            tooltip: 'Delete selected',
            icon: const Icon(Icons.delete_rounded, color: AppColors.coral),
            onPressed: _selected.isEmpty ? null : _deleteSelected,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      );

  void _openEditor(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NoteEditorPage()));
  }
}
