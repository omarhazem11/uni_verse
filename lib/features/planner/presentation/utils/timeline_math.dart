/// Pixels per minute of the day — controls how "tall" the timeline reads.
/// At 1.2px/min, a 15-hour day (7am-10pm default) renders at ~1080px tall.
const double pixelsPerMinute = 1.2;

int minutesFromMidnight(DateTime time) => time.hour * 60 + time.minute;

/// Vertical offset of [time] within a timeline starting at [dayStartMinutes].
/// Clamped to 0 so items starting before the visible window don't render
/// with a negative offset.
double timelineTop(DateTime time, int dayStartMinutes) {
  final minutes = minutesFromMidnight(time) - dayStartMinutes;
  return (minutes < 0 ? 0 : minutes) * pixelsPerMinute;
}

double timelineHeight(DateTime start, DateTime end) {
  final minutes = minutesFromMidnight(end) - minutesFromMidnight(start);
  final clamped = minutes < 20 ? 20 : minutes; // floor so short items stay tappable
  return clamped * pixelsPerMinute;
}

double totalTimelineHeight(int dayStartMinutes, int dayEndMinutes) {
  return (dayEndMinutes - dayStartMinutes) * pixelsPerMinute;
}

/// Tasks are a point in time, not a range, so they get a fixed nominal
/// block height on the timeline rather than one derived from a duration.
const double taskBlockHeight = 30 * pixelsPerMinute;

// ---------------------------------------------------------------------------
// Overlap layout
// ---------------------------------------------------------------------------

/// Horizontal position and width for a single item in the timeline Stack.
typedef BlockLayout = ({double left, double width});

/// Assigns side-by-side columns to items that overlap in time so no event
/// is hidden behind another (Google Calendar style).
///
/// [contentLeft] is the x-offset where the event area begins (label width + gap).
/// [contentWidth] is the default available width; columns are divided equally.
/// [minColumnWidth] — when > 0, no column is narrower than this value; the
/// Stack grows wider than [contentWidth] when needed (enables horizontal scroll).
Map<String, BlockLayout> computeBlockLayouts({
  required List<({String id, DateTime start, DateTime end})> items,
  required double contentLeft,
  required double contentWidth,
  double minColumnWidth = 0,
}) {
  if (items.isEmpty) return {};

  final sorted = [...items]..sort((a, b) => a.start.compareTo(b.start));

  // --- Step 1: group items that directly or transitively overlap -----------
  final groups = <List<({String id, DateTime start, DateTime end})>>[];

  for (final item in sorted) {
    // Find every existing group this item overlaps with.
    final overlapping = <int>[];
    for (var g = 0; g < groups.length; g++) {
      if (groups[g].any((other) => _overlaps(item.start, item.end, other.start, other.end))) {
        overlapping.add(g);
      }
    }

    if (overlapping.isEmpty) {
      groups.add([item]);
    } else {
      // Merge all overlapping groups into one.
      final merged = [item];
      for (final idx in overlapping.reversed) {
        merged.addAll(groups.removeAt(idx));
      }
      groups.add(merged);
    }
  }

  // --- Step 2: assign columns within each group ----------------------------
  final result = <String, BlockLayout>{};

  for (final group in groups) {
    final gSorted = [...group]..sort((a, b) => a.start.compareTo(b.start));
    final colEnds = <DateTime>[];      // last end time for each column
    final itemCol = <String, int>{};

    for (final item in gSorted) {
      // Find first column whose last item has already ended.
      var col = colEnds.indexWhere((end) => !end.isAfter(item.start));
      if (col == -1) {
        col = colEnds.length;
        colEnds.add(item.end);
      } else {
        colEnds[col] = item.end;
      }
      itemCol[item.id] = col;
    }

    final totalCols = colEnds.length;
    final naturalSlot = contentWidth / totalCols;
    final slotW = (minColumnWidth > 0 && naturalSlot < minColumnWidth)
        ? minColumnWidth
        : naturalSlot;

    for (final item in group) {
      final col = itemCol[item.id]!;
      result[item.id] = (left: contentLeft + col * slotW, width: slotW);
    }
  }

  return result;
}

bool _overlaps(DateTime aStart, DateTime aEnd, DateTime bStart, DateTime bEnd) =>
    aStart.isBefore(bEnd) && bStart.isBefore(aEnd);
