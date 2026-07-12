/// "3:00 PM"
String shortTimeLabel(DateTime time) {
  final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.hour < 12 ? 'AM' : 'PM';
  return '$hour12:$minute $period';
}

const _weekdayNames = [
  'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
];

const _shortMonthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "Mon, Dec 15"
String weekdayDateLabel(DateTime date) {
  return '${_weekdayNames[date.weekday - 1]}, ${_shortMonthNames[date.month - 1]} ${date.day}';
}

/// "7:00 AM" — for a plain minutes-from-midnight value (day boundary settings).
String minutesLabel(int minutesFromMidnight) {
  return shortTimeLabel(DateTime(2000, 1, 1, minutesFromMidnight ~/ 60, minutesFromMidnight % 60));
}
