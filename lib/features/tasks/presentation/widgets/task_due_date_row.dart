import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../utils/task_date_format.dart';

// If the student dismisses the time picker, the due date still needs a
// concrete time component (Planner positions tasks on the timeline by
// exact time) — default to end-of-day rather than leaving it at midnight.
const _defaultDueTime = TimeOfDay(hour: 23, minute: 59);

class TaskDueDateRow extends StatelessWidget {
  final DateTime? dueDate;
  final ValueChanged<DateTime?> onChanged;

  const TaskDueDateRow({
    super.key,
    required this.dueDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final label = dueDate == null
        ? 'No due date'
        : '${shortDateLabel(dueDate!)}, ${shortTimeLabel(dueDate!)}';

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _pickDateAndTime(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.violet),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: dueDate == null ? AppColors.muted : AppColors.ink,
                ),
              ),
            ),
            if (dueDate != null)
              GestureDetector(
                onTap: () => onChanged(null),
                child: const Icon(Icons.close_rounded, size: 18, color: AppColors.muted),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateAndTime(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: _violetTheme,
    );
    if (pickedDate == null || !context.mounted) return;

    final initialTime = dueDate != null ? TimeOfDay.fromDateTime(dueDate!) : _defaultDueTime;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: _violetTheme,
    );
    final time = pickedTime ?? _defaultDueTime;

    onChanged(DateTime(pickedDate.year, pickedDate.month, pickedDate.day, time.hour, time.minute));
  }

  Widget _violetTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.violet),
      ),
      child: child!,
    );
  }
}
