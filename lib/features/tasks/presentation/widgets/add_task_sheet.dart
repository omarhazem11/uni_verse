import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_provider.dart';
import 'task_category_selector.dart';
import 'task_due_date_row.dart';
import 'task_priority_selector.dart';
import 'task_reminder_dropdown.dart';
import 'task_reminder_section.dart';
import 'task_save_button.dart';
import 'task_sheet_field.dart';
import 'task_sheet_field_label.dart';
import 'task_sheet_header.dart';
import 'task_sheet_save.dart';

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
  bool _isCustomReminder = false;
  DateTime? _customReminderDateTime;

  @override
  void initState() {
    super.initState();
    _dueDate = widget.existingTask?.dueDate;
    _customReminderDateTime = widget.existingTask?.customReminderDateTime;
    _isCustomReminder = _customReminderDateTime != null;
    _reminderOffset =
        _isCustomReminder ? null : (widget.existingTask?.reminderOffset ?? const Duration(days: 1));
    _titleController.addListener(() => setState(() {}));
  }

  bool get _isEditing => widget.existingTask != null;

  bool get _canSave =>
      _titleController.text.trim().isNotEmpty &&
      customReminderIsValid(
        isCustom: _isCustomReminder,
        customReminderDateTime: _customReminderDateTime,
        dueDate: _dueDate,
      );

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
                const TaskSheetFieldLabel('Priority'),
                TaskPrioritySelector(selected: _priority, onChanged: (p) => setState(() => _priority = p)),
                const SizedBox(height: 16),
                const TaskSheetFieldLabel('Category'),
                TaskCategorySelector(selected: _category, onChanged: (c) => setState(() => _category = c)),
                const SizedBox(height: 16),
                const TaskSheetFieldLabel('Due date'),
                TaskDueDateRow(dueDate: _dueDate, onChanged: (d) => setState(() => _dueDate = d)),
                const SizedBox(height: 16),
                const TaskSheetFieldLabel('Remind me'),
                TaskReminderSection(
                  dueDate: _dueDate,
                  reminderOffset: _reminderOffset,
                  isCustom: _isCustomReminder,
                  customReminderDateTime: _customReminderDateTime,
                  onLabelSelected: _onReminderLabelSelected,
                  onCustomChanged: (dt) => setState(() => _customReminderDateTime = dt),
                ),
                const SizedBox(height: 24),
                TaskSaveButton(saving: saving, enabled: _canSave, onPressed: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onReminderLabelSelected(String label) {
    setState(() {
      if (label == customReminderLabel) {
        _isCustomReminder = true;
        _reminderOffset = null;
      } else {
        _isCustomReminder = false;
        _customReminderDateTime = null;
        _reminderOffset = reminderOptions[label];
      }
    });
  }

  Future<void> _save() async {
    if (!_canSave) return;
    final description = _descriptionController.text.trim();

    final success = await saveTaskFromSheet(
      ref: ref,
      existingTask: widget.existingTask,
      title: _titleController.text.trim(),
      description: description.isEmpty ? null : description,
      priority: _priority,
      category: _category,
      dueDate: _dueDate,
      reminderOffset: _dueDate == null || _isCustomReminder ? null : _reminderOffset,
      customReminderDateTime: _dueDate == null || !_isCustomReminder ? null : _customReminderDateTime,
    );

    if (success && mounted) Navigator.pop(context);
  }
}
