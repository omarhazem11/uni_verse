const _fullMonthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

const _weekdayNames = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];

const _shortMonthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "Monday, December 15" — DateTime.weekday is 1 (Monday) through 7 (Sunday).
String fullDateLabel(DateTime date) {
  return '${_weekdayNames[date.weekday - 1]}, ${_fullMonthNames[date.month - 1]} ${date.day}';
}

/// "Dec 14"
String shortDateLabel(DateTime date) {
  return '${_shortMonthNames[date.month - 1]} ${date.day}';
}

/// "3:00 PM"
String shortTimeLabel(DateTime time) {
  final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.hour < 12 ? 'AM' : 'PM';
  return '$hour12:$minute $period';
}

/// "Dec 14 at 3:00 PM" — used for the custom reminder display.
String shortDateTimeLabel(DateTime dateTime) {
  return '${shortDateLabel(dateTime)} at ${shortTimeLabel(dateTime)}';
}
