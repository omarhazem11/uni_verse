import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/schedule_item_entity.dart';
import '../providers/planner_provider.dart';
import '../utils/schedule_color.dart';
import '../utils/schedule_date_format.dart';
import 'schedule_color_picker.dart';
import 'schedule_emoji_picker.dart';
import 'schedule_save_button.dart';
import 'schedule_sheet_field.dart';
import 'schedule_sheet_field_label.dart';
import 'schedule_sheet_header.dart';
import 'schedule_sheet_save.dart';
import 'schedule_time_row.dart';

class AddScheduleItemSheet extends ConsumerStatefulWidget {
  final ScheduleItemEntity? existingItem;
  final DateTime? initialDate;

  const AddScheduleItemSheet({super.key, this.existingItem, this.initialDate});

  @override
  ConsumerState<AddScheduleItemSheet> createState() => _AddScheduleItemSheetState();
}

class _AddScheduleItemSheetState extends ConsumerState<AddScheduleItemSheet> {
  late final _titleController = TextEditingController(text: widget.existingItem?.title);
  late final _descriptionController = TextEditingController(text: widget.existingItem?.description);
  late DateTime _date;
  late DateTime _startTime;
  late DateTime _endTime;
  late String _colorHex;
  late String _emoji;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingItem;
    _date = existing?.date ?? dateOnly(widget.initialDate ?? DateTime.now());
    _startTime = existing?.startTime ?? DateTime(_date.year, _date.month, _date.day, 9);
    _endTime = existing?.endTime ?? DateTime(_date.year, _date.month, _date.day, 10);
    _colorHex = existing?.colorHex ?? plannerColorPalette.first;
    _emoji = existing?.emoji ?? scheduleEmojiOptions.first;
    _titleController.addListener(() => setState(() {}));
  }

  bool get _isEditing => widget.existingItem != null;
  bool get _validTimeRange => _endTime.isAfter(_startTime);
  bool get _canSave => _titleController.text.trim().isNotEmpty && _validTimeRange;

  @override
  Widget build(BuildContext context) {
    final saving = ref.watch(plannerActionsProvider).isLoading;

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
                ScheduleSheetHeader(title: _isEditing ? 'Edit Schedule Item' : 'Add Schedule Item'),
                const SizedBox(height: 6),
                Text(weekdayDateLabel(_date), style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted)),
                const SizedBox(height: 16),
                ScheduleSheetField(label: 'Title', controller: _titleController, autofocus: true),
                const SizedBox(height: 14),
                ScheduleSheetField(
                  label: 'Description (optional)',
                  controller: _descriptionController,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const ScheduleSheetFieldLabel('Time'),
                ScheduleTimeRow(
                  date: _date,
                  startTime: _startTime,
                  endTime: _endTime,
                  onStartChanged: (t) => setState(() => _startTime = t),
                  onEndChanged: (t) => setState(() => _endTime = t),
                ),
                if (!_validTimeRange)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'End time must be after start time',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.coral),
                    ),
                  ),
                const SizedBox(height: 16),
                const ScheduleSheetFieldLabel('Icon'),
                ScheduleEmojiPicker(selected: _emoji, onChanged: (e) => setState(() => _emoji = e)),
                const SizedBox(height: 16),
                const ScheduleSheetFieldLabel('Color'),
                ScheduleColorPicker(selectedHex: _colorHex, onChanged: (c) => setState(() => _colorHex = c)),
                const SizedBox(height: 24),
                ScheduleSaveButton(saving: saving, enabled: _canSave, onPressed: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_canSave) return;
    final description = _descriptionController.text.trim();

    final success = await saveScheduleItemFromSheet(
      ref: ref,
      existingItem: widget.existingItem,
      title: _titleController.text.trim(),
      description: description.isEmpty ? null : description,
      date: _date,
      startTime: _startTime,
      endTime: _endTime,
      colorHex: _colorHex,
      emoji: _emoji,
    );

    if (success && mounted) Navigator.pop(context);
  }
}
