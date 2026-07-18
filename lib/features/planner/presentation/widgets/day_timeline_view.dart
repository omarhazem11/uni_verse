import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../../tasks/presentation/utils/task_display_helpers.dart';
import '../providers/planner_provider.dart';
import '../utils/timeline_math.dart';
import 'day_timeline_empty_state.dart';
import 'schedule_item_block.dart';
import 'task_timeline_block.dart';
import 'timeline_hour_markers.dart';

const _absoluteMinColumn = 80.0;

double _titlePx(String text) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700),
    ),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout();
  return tp.size.width;
}

class DayTimelineView extends ConsumerStatefulWidget {
  final DateTime date;

  const DayTimelineView({super.key, required this.date});

  @override
  ConsumerState<DayTimelineView> createState() => _DayTimelineViewState();
}

class _DayTimelineViewState extends ConsumerState<DayTimelineView> {
  final _blocksController = ScrollController();
  final _labelController = ScrollController();
  final _hScrollController = ScrollController();
  bool _syncing = false;

  // Scroll hint visibility — updated by the horizontal scroll listener.
  bool _showLeftHint = false;
  bool _showRightHint = false;

  @override
  void initState() {
    super.initState();
    _blocksController.addListener(_syncLabels);
    _hScrollController.addListener(_updateHints);
  }

  void _syncLabels() {
    if (_syncing) return;
    _syncing = true;
    if (_labelController.hasClients) {
      _labelController.jumpTo(_blocksController.offset);
    }
    _syncing = false;
  }

  void _updateHints() {
    if (!_hScrollController.hasClients) return;
    final pos = _hScrollController.position;
    final left = pos.pixels > 2;
    final right = pos.pixels < pos.maxScrollExtent - 2;
    if (left != _showLeftHint || right != _showRightHint) {
      setState(() {
        _showLeftHint = left;
        _showRightHint = right;
      });
    }
  }

  // Sets the initial right hint the first time horizontal scroll becomes
  // available.  Only fires once (when neither hint is active yet) so it
  // doesn't fight with _updateHints after the user has scrolled.
  void _setInitialHint(bool needsHScroll) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (needsHScroll && !_showRightHint && !_showLeftHint) {
        setState(() => _showRightHint = true);
      } else if (!needsHScroll && (_showRightHint || _showLeftHint)) {
        setState(() { _showRightHint = false; _showLeftHint = false; });
      }
    });
  }

  @override
  void dispose() {
    _blocksController.dispose();
    _labelController.dispose();
    _hScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(dayItemsProvider(widget.date));
    final settingsAsync = ref.watch(plannerSettingsProvider);
    final tasksAsync = ref.watch(tasksStreamProvider);

    if (!itemsAsync.hasValue || !settingsAsync.hasValue) {
      return const SizedBox.shrink();
    }

    final items = itemsAsync.value!;
    final settings = settingsAsync.value!;
    final normalized = dateOnly(widget.date);
    final tasksToday = (tasksAsync.value ?? [])
        .where((t) => t.dueDate != null && dateOnly(t.dueDate!) == normalized)
        .toList();

    if (items.isEmpty && tasksToday.isEmpty) return const DayTimelineEmptyState();

    final start = settings.dayStartMinutes;
    final end = settings.dayEndMinutes;

    return LayoutBuilder(
      builder: (context, constraints) {
        const labelColWidth = timelineLabelWidth + 8.0;
        final blocksAreaWidth = constraints.maxWidth - labelColWidth;

        const contentLeft = 0.0;
        final dayStartDt = dateOnly(widget.date).add(Duration(minutes: start));

        const sPrefix = 's_';
        const tPrefix = 't_';

        final taskCollisionItems = tasksToday.map((task) {
          final ts = task.dueDate!;
          final clamped = ts.isBefore(dayStartDt) ? dayStartDt : ts;
          return (
            id: '$tPrefix${task.id}',
            start: clamped,
            end: clamped.add(const Duration(minutes: 30)),
          );
        }).toList();

        var minColWidth = _absoluteMinColumn;
        for (final item in items) {
          final w = _titlePx('${item.emoji} ${item.title}') + 24;
          if (w > minColWidth) minColWidth = w;
        }
        for (final task in tasksToday) {
          final w = _titlePx('${task.category.emoji} ${task.title}') + 32;
          if (w > minColWidth) minColWidth = w;
        }

        final layouts = computeBlockLayouts(
          items: [
            for (final item in items)
              (id: '$sPrefix${item.id}', start: item.startTime, end: item.endTime),
            ...taskCollisionItems,
          ],
          contentLeft: contentLeft,
          contentWidth: blocksAreaWidth,
          minColumnWidth: minColWidth,
        );

        var stackWidth = blocksAreaWidth;
        for (final l in layouts.values) {
          final edge = l.left + l.width;
          if (edge > stackWidth) stackWidth = edge;
        }

        final needsHScroll = stackWidth > blocksAreaWidth;
        _setInitialHint(needsHScroll);

        final timelineH = totalTimelineHeight(start, end);

        final blocksStack = SizedBox(
          height: timelineH,
          width: stackWidth,
          child: Stack(
            children: [
              TimelineHourMarkers(
                dayStartMinutes: start,
                dayEndMinutes: end,
                showLabels: false,
              ),
              for (final item in items)
                Positioned(
                  top: timelineTop(item.startTime, start),
                  left: layouts['$sPrefix${item.id}']!.left,
                  width: layouts['$sPrefix${item.id}']!.width,
                  height: timelineHeight(item.startTime, item.endTime),
                  child: ScheduleItemBlock(item: item),
                ),
              for (final task in tasksToday)
                Positioned(
                  top: timelineTop(task.dueDate!, start),
                  left: layouts['$tPrefix${task.id}']!.left,
                  width: layouts['$tPrefix${task.id}']!.width,
                  height: taskBlockHeight,
                  child: TaskTimelineBlock(task: task),
                ),
            ],
          ),
        );

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Fixed label column ──────────────────────────────────────────
              SizedBox(
                width: labelColWidth,
                child: SingleChildScrollView(
                  controller: _labelController,
                  physics: const NeverScrollableScrollPhysics(),
                  child: SizedBox(
                    height: timelineH,
                    child: TimelineHourMarkers(
                      dayStartMinutes: start,
                      dayEndMinutes: end,
                      showDividers: false,
                    ),
                  ),
                ),
              ),

              // ── Scrollable blocks column + scroll hints ─────────────────────
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _hScrollController,
                      child: SingleChildScrollView(
                        controller: _blocksController,
                        child: blocksStack,
                      ),
                    ),

                    // Arrow width: 14 % of the blocks column, clamped 44–72px.
                    if (needsHScroll) ...[
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: IgnorePointer(
                          child: AnimatedOpacity(
                            opacity: _showLeftHint ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            child: _ScrollHintArrow(
                              isRight: false,
                              width: (blocksAreaWidth * 0.14).clamp(44, 72),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: IgnorePointer(
                          child: AnimatedOpacity(
                            opacity: _showRightHint ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            child: _ScrollHintArrow(
                              isRight: true,
                              width: (blocksAreaWidth * 0.14).clamp(44, 72),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScrollHintArrow extends StatelessWidget {
  final bool isRight;
  final double width;

  const _ScrollHintArrow({required this.isRight, required this.width});

  @override
  Widget build(BuildContext context) {
    // Icon scales proportionally with the hint width.
    final iconSize = (width * 0.55).clamp(22.0, 36.0);
    return Container(
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isRight ? Alignment.centerLeft : Alignment.centerRight,
          end: isRight ? Alignment.centerRight : Alignment.centerLeft,
          colors: [
            const Color(0xFFF7F4FF).withAlpha(0),
            const Color(0xFFF7F4FF).withAlpha(220),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        isRight ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
        size: iconSize,
        color: const Color(0xFF8B7FB8).withAlpha(200),
      ),
    );
  }
}
