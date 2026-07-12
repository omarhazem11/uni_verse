import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../providers/planner_provider.dart';
import '../widgets/month_day_cell.dart';
import '../widgets/month_grid.dart';

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

class MonthCalendarPage extends ConsumerStatefulWidget {
  const MonthCalendarPage({super.key});

  @override
  ConsumerState<MonthCalendarPage> createState() => _MonthCalendarPageState();
}

class _MonthCalendarPageState extends ConsumerState<MonthCalendarPage> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    _visibleMonth = dateOnly(ref.read(selectedDateProvider));
  }

  @override
  Widget build(BuildContext context) {
    final today = dateOnly(DateTime.now());
    final selectedDate = ref.watch(selectedDateProvider);
    final scheduleItems = ref.watch(monthItemsProvider(_visibleMonth)).value ?? [];
    final tasks = ref.watch(tasksStreamProvider).value ?? [];

    final daysWithScheduleItems = scheduleItems
        .where((i) => i.date.year == _visibleMonth.year && i.date.month == _visibleMonth.month)
        .map((i) => i.date.day)
        .toSet();
    final daysWithTasksDue = tasks
        .where((t) =>
            t.dueDate != null &&
            t.dueDate!.year == _visibleMonth.year &&
            t.dueDate!.month == _visibleMonth.month)
        .map((t) => t.dueDate!.day)
        .toSet();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: () => setState(() => _visibleMonth = _shiftMonth(-1)),
            ),
            Expanded(
              child: Text(
                '${_monthNames[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: () => setState(() => _visibleMonth = _shiftMonth(1)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _goToToday,
            child: Text('Today', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: AppColors.violet)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: MonthGrid(
          visibleMonth: _visibleMonth,
          cellBuilder: (date) => MonthDayCell(
            day: date.day,
            isToday: _isSameDate(date, today),
            isSelected: _isSameDate(date, selectedDate),
            hasScheduleItems: daysWithScheduleItems.contains(date.day),
            hasTasksDue: daysWithTasksDue.contains(date.day),
            onTap: () => _selectAndReturn(date),
          ),
        ),
      ),
    );
  }

  DateTime _shiftMonth(int delta) => DateTime(_visibleMonth.year, _visibleMonth.month + delta, 1);

  bool _isSameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  void _goToToday() {
    final today = dateOnly(DateTime.now());
    setState(() => _visibleMonth = today);
    ref.read(selectedDateProvider.notifier).state = today;
  }

  void _selectAndReturn(DateTime date) {
    ref.read(selectedDateProvider.notifier).state = dateOnly(date);
    Navigator.pop(context);
  }
}
