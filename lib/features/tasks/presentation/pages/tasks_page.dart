import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/task_provider.dart';
import '../widgets/add_task_sheet.dart';
import '../widgets/task_empty_state.dart';
import '../widgets/task_list_view.dart';

class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
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
          'Delete $count task${count == 1 ? '' : 's'}?',
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
    final notifier = ref.read(taskActionsProvider.notifier);
    for (final id in _selected.toList()) {
      notifier.deleteTask(id);
    }
    _exitSelectionMode();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _selectionMode
          ? _selectionAppBar(tasksAsync.value?.map((t) => t.id).toList() ?? [])
          : _normalAppBar(),
      body: tasksAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.violet),
        ),
        error: (error, _) => Center(
          child: Text(
            "Couldn't load your tasks — pull down to try again.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.muted),
          ),
        ),
        data: (tasks) => tasks.isEmpty
            ? TaskEmptyState(onAddTask: () => _openAddSheet(context))
            : TaskListView(
                tasks: tasks,
                isSelectionMode: _selectionMode,
                selectedIds: _selected,
                onEnterSelectionMode: _enterSelectionMode,
                onToggleSelect: _toggleSelect,
              ),
      ),
      floatingActionButton: _selectionMode
          ? null
          : FloatingActionButton(
              onPressed: () => _openAddSheet(context),
              backgroundColor: AppColors.violet,
              shape: const CircleBorder(),
              child: const Icon(Icons.add_rounded, color: Colors.white),
            ),
    );
  }

  PreferredSizeWidget _normalAppBar() => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
        title: Text(
          'Tasks',
          style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      );

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

  void _openAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTaskSheet(),
    );
  }
}
