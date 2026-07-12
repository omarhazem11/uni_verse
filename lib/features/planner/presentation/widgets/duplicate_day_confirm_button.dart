import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class DuplicateDayConfirmButton extends StatelessWidget {
  final bool saving;
  final int count;
  final VoidCallback onPressed;

  const DuplicateDayConfirmButton({
    super.key,
    required this.saving,
    required this.count,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: (saving || count == 0) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.violet,
          disabledBackgroundColor: AppColors.violet.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        ),
        child: saving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Text(
                count == 0 ? 'Select dates to duplicate to' : 'Duplicate to $count day${count == 1 ? '' : 's'}',
                style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
              ),
      ),
    );
  }
}
