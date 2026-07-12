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
