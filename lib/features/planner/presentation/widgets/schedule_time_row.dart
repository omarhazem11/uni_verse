import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../utils/schedule_date_format.dart';

class ScheduleTimeRow extends StatelessWidget {
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final ValueChanged<DateTime> onStartChanged;
  final ValueChanged<DateTime> onEndChanged;

  const ScheduleTimeRow({
    super.key,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.onStartChanged,
    required this.onEndChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TimeButton(
            label: 'Starts',
            time: startTime,
            onTap: () => _pick(context, startTime, onStartChanged),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TimeButton(
            label: 'Ends',
            time: endTime,
            onTap: () => _pick(context, endTime, onEndChanged),
          ),
        ),
      ],
    );
  }

  Future<void> _pick(BuildContext context, DateTime current, ValueChanged<DateTime> onChanged) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.violet),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    onChanged(DateTime(date.year, date.month, date.day, picked.hour, picked.minute));
  }
}

class _TimeButton extends StatelessWidget {
  final String label;
  final DateTime time;
  final VoidCallback onTap;

  const _TimeButton({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted)),
            const SizedBox(height: 2),
            Text(
              shortTimeLabel(time),
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}
