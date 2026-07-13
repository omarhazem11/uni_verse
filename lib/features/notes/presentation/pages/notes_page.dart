import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/note_provider.dart';
import '../widgets/notes_empty_state.dart';
import '../widgets/notes_list_view.dart';
import '../widgets/notes_search_app_bar.dart';
import '../widgets/notes_tag_filter_row.dart';
import 'note_editor_page.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesStreamProvider);
    final filtered = ref.watch(filteredNotesProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const NotesSearchAppBar(),
      body: notesAsync.when(
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
                  const SizedBox(height: 12),
                  const NotesTagFilterRow(),
                  const SizedBox(height: 8),
                  Expanded(
                    child: filtered.isEmpty ? const NotesNoResultsState() : NotesListView(notes: filtered),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(context),
        backgroundColor: AppColors.violet,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  void _openEditor(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NoteEditorPage()));
  }
}
