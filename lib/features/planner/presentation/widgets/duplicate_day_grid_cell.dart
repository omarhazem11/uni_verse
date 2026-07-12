import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class DuplicateDayGridCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isSource;
  final bool isPast;
  final bool isSelected;
  final VoidCallback onTap;

  const DuplicateDayGridCell({
    super.key,
    required this.day,
    required this.isToday,
    required this.isSource,
    required this.isPast,
    required this.isSelected,
    required this.onTap,
  });

  bool get _disabled => isSource || isPast;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _disabled ? null : onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.violet : Colors.transparent,
          border: (isToday || isSource) && !isSelected
              ? Border.all(color: isSource ? AppColors.muted : AppColors.violet, width: 1.5)
              : null,
        ),
        child: Text(
          '$day',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : _disabled
                    ? AppColors.muted.withValues(alpha: 0.4)
                    : AppColors.ink,
          ),
        ),
      ),
    );
  }
}
