import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../utils/task_date_format.dart';

class TaskCustomReminderRow extends StatelessWidget {
  final DateTime? dueDate;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  const TaskCustomReminderRow({
    super.key,
    required this.dueDate,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dateLabel = value == null ? 'Pick date' : shortDateLabel(value!);
    final timeLabel = value == null ? 'Pick time' : shortTimeLabel(value!);

    return Row(
      children: [
        Expanded(
          child: _PickerButton(
            icon: Icons.calendar_today_rounded,
            label: dateLabel,
            onTap: () => _pickDate(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PickerButton(
            icon: Icons.access_time_rounded,
            label: timeLabel,
            onTap: () => _pickTime(context),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final maxDate = dueDate ?? now.add(const Duration(days: 365));
    var initial = value ?? maxDate;
    if (initial.isBefore(now)) initial = now;
    if (initial.isAfter(maxDate)) initial = maxDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: maxDate,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.violet),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;

    final time = value != null ? TimeOfDay.fromDateTime(value!) : const TimeOfDay(hour: 9, minute: 0);
    onChanged(DateTime(picked.year, picked.month, picked.day, time.hour, time.minute));
  }

  Future<void> _pickTime(BuildContext context) async {
    final initialTime = value != null ? TimeOfDay.fromDateTime(value!) : TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: initialTime);
    if (picked == null) return;

    final date = value ?? dueDate ?? DateTime.now();
    onChanged(DateTime(date.year, date.month, date.day, picked.hour, picked.minute));
  }
}

class _PickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickerButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.violet),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
