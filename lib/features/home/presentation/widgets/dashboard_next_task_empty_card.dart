import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Shared white rounded-card shell used by [DashboardNextTaskCard] and its
/// empty state, matching DashboardGettingStartedCard's styling.
class DashboardNextTaskCardShell extends StatelessWidget {
  final Widget child;

  const DashboardNextTaskCardShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.ink.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}

class EmptyNextTaskCard extends StatelessWidget {
  const EmptyNextTaskCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardNextTaskCardShell(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(color: AppColors.tileMintBg, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: AppColors.mint, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nothing urgent right now',
                  style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink),
                ),
                const SizedBox(height: 4),
                Text(
                  "You're ahead of the game! 🎉",
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
