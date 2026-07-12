import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

const reminderOptions = <String, Duration?>{
  '15 minutes before': Duration(minutes: 15),
  '1 hour before': Duration(hours: 1),
  '1 day before': Duration(days: 1),
  '2 days before': Duration(days: 2),
  '1 week before': Duration(days: 7),
  'No reminder': null,
};

class TaskReminderDropdown extends StatelessWidget {
  final bool enabled;
  final Duration? value;
  final ValueChanged<Duration?> onChanged;

  const TaskReminderDropdown({
    super.key,
    required this.enabled,
    required this.value,
    required this.onChanged,
  });

  String _labelFor(Duration? duration) {
    return reminderOptions.entries
        .firstWhere(
          (e) => e.value == duration,
          orElse: () => reminderOptions.entries.last,
        )
        .key;
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: _labelFor(value),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.muted),
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.ink),
            onChanged: enabled
                ? (label) {
                    if (label != null) onChanged(reminderOptions[label]);
                  }
                : null,
            items: reminderOptions.keys
                .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                .toList(),
          ),
        ),
      ),
    );
  }
}
