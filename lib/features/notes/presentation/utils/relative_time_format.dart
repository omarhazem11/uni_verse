const _shortMonthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "Just now" / "5m ago" / "3h ago" / "Yesterday" / "4d ago" / "Dec 15".
String relativeTimeLabel(DateTime dateTime, [DateTime? now]) {
  final reference = now ?? DateTime.now();
  final diff = reference.difference(dateTime);

  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';

  final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
  final referenceOnly = DateTime(reference.year, reference.month, reference.day);
  final dayGap = referenceOnly.difference(dateOnly).inDays;

  if (dayGap == 1) return 'Yesterday';
  if (dayGap < 7) return '${dayGap}d ago';
  return '${_shortMonthNames[dateTime.month - 1]} ${dateTime.day}';
}
