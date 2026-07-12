import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import 'task_custom_reminder_row.dart';
import 'task_reminder_dropdown.dart';

/// Shared by the sheet's live validation and its Save-button-enabled check
/// so the two can never disagree with each other.
///
/// The same day as the due date is fine — due dates in this app never
/// carry a real time (always midnight), so comparing full DateTimes would
/// reject any same-day reminder outright. Only if the due date genuinely
/// has a time component does a same-day reminder need to land at or
/// before that time; otherwise it's the day, not the exact moment, that
/// must not be exceeded.
bool customReminderIsValid({
  required bool isCustom,
  required DateTime? customReminderDateTime,
  required DateTime? dueDate,
}) {
  if (!isCustom) return true;
  if (customReminderDateTime == null) return false;
  if (dueDate == null) return true;

  final reminderDay = DateTime(customReminderDateTime.year, customReminderDateTime.month, customReminderDateTime.day);
  final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
  if (reminderDay.isAfter(dueDay)) return false;

  final dueHasTimeComponent = dueDate.hour != 0 || dueDate.minute != 0;
  if (reminderDay.isAtSameMomentAs(dueDay) && dueHasTimeComponent) {
    return !customReminderDateTime.isAfter(dueDate);
  }
  return true;
}

class TaskReminderSection extends StatelessWidget {
  final DateTime? dueDate;
  final Duration? reminderOffset;
  final bool isCustom;
  final DateTime? customReminderDateTime;
  final ValueChanged<String> onLabelSelected;
  final ValueChanged<DateTime> onCustomChanged;

  const TaskReminderSection({
    super.key,
    required this.dueDate,
    required this.reminderOffset,
    required this.isCustom,
    required this.customReminderDateTime,
    required this.onLabelSelected,
    required this.onCustomChanged,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = dueDate != null;
    final invalid = enabled &&
        isCustom &&
        !customReminderIsValid(
          isCustom: isCustom,
          customReminderDateTime: customReminderDateTime,
          dueDate: dueDate,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TaskReminderDropdown(
          enabled: enabled,
          value: reminderOffset,
          isCustom: isCustom,
          onLabelSelected: onLabelSelected,
        ),
        if (!enabled)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Set a due date first to use a custom reminder',
              style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.muted, fontStyle: FontStyle.italic),
            ),
          ),
        if (enabled && isCustom) ...[
          const SizedBox(height: 10),
          TaskCustomReminderRow(
            dueDate: dueDate,
            value: customReminderDateTime,
            onChanged: onCustomChanged,
          ),
        ],
        if (invalid)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Reminder must be before the due date',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.coral),
            ),
          ),
      ],
    );
  }
}
