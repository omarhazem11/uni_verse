import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/planner_provider.dart';
import '../widgets/add_schedule_item_sheet.dart';
import '../widgets/date_strip.dart';
import '../widgets/day_settings_sheet.dart';
import '../widgets/day_timeline_view.dart';
import '../widgets/duplicate_day_sheet.dart';
import 'month_calendar_page.dart';

class PlannerPage extends ConsumerWidget {
  const PlannerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final isToday = selectedDate == dateOnly(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
        title: Text(
          'Planner',
          style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink),
        ),
        actions: [
          if (!isToday) _TodayPill(onTap: () => _goToToday(ref)),
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MonthCalendarPage()),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) => _handleMenu(context, ref, value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'settings', child: Text('Day settings')),
              PopupMenuItem(value: 'duplicate', child: Text('Duplicate this day')),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          const DateStrip(),
          const SizedBox(height: 4),
          Expanded(child: DayTimelineView(date: selectedDate)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.violet,
        shape: const CircleBorder(),
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => AddScheduleItemSheet(initialDate: selectedDate),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  void _goToToday(WidgetRef ref) {
    ref.read(selectedDateProvider.notifier).state = dateOnly(DateTime.now());
  }

  void _handleMenu(BuildContext context, WidgetRef ref, String value) {
    if (value == 'settings') {
      final settings = ref.read(plannerSettingsProvider).value;
      if (settings == null) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => DaySettingsSheet(settings: settings),
      );
    } else if (value == 'duplicate') {
      final source = ref.read(selectedDateProvider);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => DuplicateDaySheet(sourceDate: source),
      );
    }
  }
}

class _TodayPill extends StatelessWidget {
  final VoidCallback onTap;

  const _TodayPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.tileVioletBg,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        child: Text(
          'Today',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: AppColors.violet, fontSize: 13),
        ),
      ),
    );
  }
}
