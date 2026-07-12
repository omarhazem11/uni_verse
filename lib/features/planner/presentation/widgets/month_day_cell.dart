import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class MonthDayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isSelected;
  final bool hasScheduleItems;
  final bool hasTasksDue;
  final VoidCallback onTap;

  const MonthDayCell({
    super.key,
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.hasScheduleItems,
    required this.hasTasksDue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.violet : Colors.transparent,
              border: isToday && !isSelected ? Border.all(color: AppColors.violet, width: 1.5) : null,
            ),
            child: Text(
              '$day',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.ink,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasScheduleItems) _dot(AppColors.violet),
              if (hasScheduleItems && hasTasksDue) const SizedBox(width: 3),
              if (hasTasksDue) _dot(AppColors.coral),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
