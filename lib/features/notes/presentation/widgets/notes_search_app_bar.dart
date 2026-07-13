import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/note_provider.dart';

class NotesSearchAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const NotesSearchAppBar({super.key});

  @override
  ConsumerState<NotesSearchAppBar> createState() => _NotesSearchAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}

class _NotesSearchAppBarState extends ConsumerState<NotesSearchAppBar> {
  bool _searching = false;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.ink),
      title: _searching
          ? TextField(
              controller: _controller,
              autofocus: true,
              onChanged: (v) => ref.read(noteSearchQueryProvider.notifier).state = v,
              style: GoogleFonts.inter(fontSize: 15, color: AppColors.ink),
              decoration: const InputDecoration(hintText: 'Search notes...', border: InputBorder.none),
            )
          : Text(
              'Notes',
              style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink),
            ),
      actions: [
        IconButton(
          onPressed: () => setState(() {
            _searching = !_searching;
            if (!_searching) {
              _controller.clear();
              ref.read(noteSearchQueryProvider.notifier).state = '';
            }
          }),
          icon: Icon(_searching ? Icons.close_rounded : Icons.search_rounded),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.divider),
      ),
    );
  }
}
