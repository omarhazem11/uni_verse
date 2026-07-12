import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/planner_provider.dart';
import '../utils/schedule_date_format.dart';
import 'duplicate_day_confirm_button.dart';
import 'duplicate_day_grid_cell.dart';
import 'duplicate_day_month_nav.dart';
import 'month_grid.dart';
import 'schedule_sheet_header.dart';

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

class DuplicateDaySheet extends ConsumerStatefulWidget {
  final DateTime sourceDate;

  const DuplicateDaySheet({super.key, required this.sourceDate});

  @override
  ConsumerState<DuplicateDaySheet> createState() => _DuplicateDaySheetState();
}

class _DuplicateDaySheetState extends ConsumerState<DuplicateDaySheet> {
  final Set<DateTime> _selected = {};
  late DateTime _visibleMonth = dateOnly(widget.sourceDate);

  @override
  Widget build(BuildContext context) {
    final saving = ref.watch(plannerActionsProvider).isLoading;
    final count = _selected.length;
    final today = dateOnly(DateTime.now());

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScheduleSheetHeader(title: 'Duplicate Day'),
                const SizedBox(height: 6),
                Text(
                  "Duplicate ${weekdayDateLabel(widget.sourceDate)}'s schedule to...",
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted),
                ),
                const SizedBox(height: 12),
                DuplicateDayMonthNav(
                  label: '${_monthNames[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                  onPrevious: () => setState(() => _visibleMonth = _shiftMonth(-1)),
                  onNext: () => setState(() => _visibleMonth = _shiftMonth(1)),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: MonthGrid(
                      visibleMonth: _visibleMonth,
                      cellBuilder: (date) => DuplicateDayGridCell(
                        day: date.day,
                        isToday: _isSameDate(date, today),
                        isSource: _isSameDate(date, widget.sourceDate),
                        isPast: date.isBefore(dateOnly(widget.sourceDate)),
                        isSelected: _selected.contains(date),
                        onTap: () => setState(() {
                          _selected.contains(date) ? _selected.remove(date) : _selected.add(date);
                        }),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DuplicateDayConfirmButton(saving: saving, count: count, onPressed: _confirm),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DateTime _shiftMonth(int delta) => DateTime(_visibleMonth.year, _visibleMonth.month + delta, 1);

  bool _isSameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _confirm() async {
    if (_selected.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    final count = _selected.length;

    final success = await ref
        .read(plannerActionsProvider.notifier)
        .duplicateItemsToDate(widget.sourceDate, _selected.toList());

    if (success && mounted) {
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Schedule copied to $count day${count == 1 ? '' : 's'}! 🎉',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          backgroundColor: AppColors.mint,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          margin: const EdgeInsets.symmetric(horizontal: 70, vertical: 24),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
      );
    }
  }
}
