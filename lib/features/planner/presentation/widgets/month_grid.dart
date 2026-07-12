import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

const _weekdayHeaders = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

/// Renders the weekday header row + a 7-column day grid for [visibleMonth],
/// delegating each day's cell to [cellBuilder] — shared by MonthCalendarPage
/// (single-select, navigates away on tap) and DuplicateDaySheet
/// (multi-select, stays open) so neither has to re-derive the
/// leading-blanks/days-in-month math itself.
class MonthGrid extends StatelessWidget {
  final DateTime visibleMonth; // any date within the month
  final Widget Function(DateTime date) cellBuilder;

  const MonthGrid({super.key, required this.visibleMonth, required this.cellBuilder});

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final daysInMonth = DateTime(visibleMonth.year, visibleMonth.month + 1, 0).day;
    final leadingBlanks = firstOfMonth.weekday % 7; // Sunday-first: Sun=7%7=0

    return Column(
      children: [
        Row(
          children: _weekdayHeaders
              .map((label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1,
          children: [
            for (var i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
            for (var day = 1; day <= daysInMonth; day++)
              cellBuilder(DateTime(visibleMonth.year, visibleMonth.month, day)),
          ],
        ),
      ],
    );
  }
}
