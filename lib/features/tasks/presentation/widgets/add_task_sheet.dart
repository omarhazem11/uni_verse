import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_provider.dart';
import 'task_category_selector.dart';
import 'task_due_date_row.dart';
import 'task_priority_selector.dart';
import 'task_reminder_dropdown.dart';
import 'task_save_button.dart';
import 'task_sheet_field.dart';
import 'task_sheet_header.dart';

class AddTaskSheet extends ConsumerStatefulWidget {
  final TaskEntity? existingTask;

  const AddTaskSheet({super.key, this.existingTask});

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  late final _titleController =
      TextEditingController(text: widget.existingTask?.title);
  late final _descriptionController =
      TextEditingController(text: widget.existingTask?.description);
  late TaskPriority _priority = widget.existingTask?.priority ?? TaskPriority.medium;
  late TaskCategory _category = widget.existingTask?.category ?? TaskCategory.other;
  DateTime? _dueDate;
  Duration? _reminderOffset;

  @override
  void initState() {
    super.initState();
    _dueDate = widget.existingTask?.dueDate;
    _reminderOffset = widget.existingTask?.reminderOffset ?? const Duration(days: 1);
    _titleController.addListener(() => setState(() {}));
  }

  bool get _isEditing => widget.existingTask != null;

  @override
  Widget build(BuildContext context) {
    final saving = ref.watch(taskActionsProvider).isLoading;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TaskSheetHeader(isEditing: _isEditing),
                const SizedBox(height: 18),
                TaskSheetField(label: 'Task name', controller: _titleController, autofocus: true),
                const SizedBox(height: 14),
                TaskSheetField(
                  label: 'Description (optional)',
                  controller: _descriptionController,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _fieldLabel('Priority'),
                TaskPrioritySelector(
                  selected: _priority,
                  onChanged: (p) => setState(() => _priority = p),
                ),
                const SizedBox(height: 16),
                _fieldLabel('Category'),
                TaskCategorySelector(
                  selected: _category,
                  onChanged: (c) => setState(() => _category = c),
                ),
                const SizedBox(height: 16),
                _fieldLabel('Due date'),
                TaskDueDateRow(
                  dueDate: _dueDate,
                  onChanged: (d) => setState(() => _dueDate = d),
                ),
                const SizedBox(height: 16),
                _fieldLabel('Remind me'),
                TaskReminderDropdown(
                  enabled: _dueDate != null,
                  value: _reminderOffset,
                  onChanged: (d) => setState(() => _reminderOffset = d),
                ),
                const SizedBox(height: 24),
                TaskSaveButton(
                  saving: saving,
                  enabled: _titleController.text.trim().isNotEmpty,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.ink),
        ),
      );

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final notifier = ref.read(taskActionsProvider.notifier);
    final description = _descriptionController.text.trim();
    final reminder = _dueDate == null ? null : _reminderOffset;

    final success = _isEditing
        ? await notifier.updateTask(widget.existingTask!.copyWith(
            title: title,
            description: description.isEmpty ? null : description,
            priority: _priority,
            category: _category,
            dueDate: _dueDate,
            clearDueDate: _dueDate == null,
            reminderOffset: reminder,
            clearReminderOffset: reminder == null,
          ))
        : await notifier.addTask(
            title: title,
            description: description.isEmpty ? null : description,
            priority: _priority,
            category: _category,
            dueDate: _dueDate,
            reminderOffset: reminder,
          );

    if (success && mounted) Navigator.pop(context);
  }
}
