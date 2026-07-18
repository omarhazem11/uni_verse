import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../utils/timeline_math.dart';

const timelineLabelWidth = 48.0;

class TimelineHourMarkers extends StatelessWidget {
  final int dayStartMinutes;
  final int dayEndMinutes;

  const TimelineHourMarkers({
    super.key,
    required this.dayStartMinutes,
    required this.dayEndMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final firstHour = (dayStartMinutes / 60).ceil();
    final lastHour = (dayEndMinutes / 60).floor();
    final hours = [for (var h = firstHour; h <= lastHour; h++) h];

    return Stack(
      children: hours.expand((hour) {
        final top = (hour * 60 - dayStartMinutes) * pixelsPerMinute;
        return [
          Positioned(
            top: top + 3,
            left: 0,
            width: timelineLabelWidth,
            child: Text(
              _hourLabel(hour),
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted),
            ),
          ),
          Positioned(
            top: top,
            left: timelineLabelWidth + 8,
            right: 0,
            child: Container(height: 1, color: AppColors.divider),
          ),
        ];
      }).toList(),
    );
  }

  String _hourLabel(int hour24) {
    final period = hour24 < 12 ? 'AM' : 'PM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return '$hour12 $period';
  }
}
