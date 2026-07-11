import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import 'dashboard_tile_tier.dart';

class DashboardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color background;
  final Color iconBackground;
  final Color accent;
  final VoidCallback onTap;

  const DashboardTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.background,
    required this.iconBackground,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Discrete size tiers by tile width, not a continuous formula, so
          // compact phones (iPhone SE) render exactly as before while wider
          // phones (14 Pro Max) and tablets (iPad) get a real size bump
          // rather than a marginal one.
          final tier = TileTier.forWidth(constraints.maxWidth);
          final innerWidth = (constraints.maxWidth - tier.padding * 2)
              .clamp(0.0, double.infinity);

          // "Achievements" was replaced with "Badges" specifically to fix
          // sizing — it was 12 chars, by far the longest of the four
          // titles, and single-handedly capped everyone's font size since
          // all tiles share one size for visual consistency. "Planner" (7
          // chars) is now the longest, at 6.72-6.86em depending on target
          // size (Nunito 800, -0.2 letterSpacing) — 6.9 covers the worst
          // case. This is the hard physical ceiling — regardless of tier
          // target, the title can never exceed the width actually
          // available, or it silently clips instead of shrinking. The 0.99
          // factor leaves a thin safety margin for rounding at the boundary.
          final maxFittingTitleSize = innerWidth * 0.99 / 6.9;
          final titleSize = tier.titleSize < maxFittingTitleSize
              ? tier.titleSize
              : maxFittingTitleSize;

          // Guaranteed smaller than the title, not just by tuned tier
          // values — if titleSize ever gets pulled down by the fit cap
          // above, the subtitle follows it down too rather than risking
          // a subtitle that's accidentally the same size as (or bigger
          // than) the title at some untested width. Floored at 8.0 so an
          // extreme edge case can't shrink it past legibility.
          final rawSubtitleSize = tier.subtitleSize < titleSize - 2
              ? tier.subtitleSize
              : titleSize - 2;
          final subtitleSize = rawSubtitleSize.clamp(8.0, titleSize - 0.5);

          return Container(
            padding: EdgeInsets.all(tier.padding),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            // Bounding the child to the tile's actual inner width before
            // FittedBox measures it stops longer copy (e.g. "Planner")
            // from getting an extra width-driven shrink that shorter copy
            // (e.g. "Notes") doesn't — so all tiles scale by height alone.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: innerWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: tier.iconContainerSize,
                      height: tier.iconContainerSize,
                      decoration: BoxDecoration(
                        color: iconBackground,
                        borderRadius: BorderRadius.circular(tier.iconRadius),
                      ),
                      child: Icon(icon, color: accent, size: tier.iconGlyphSize),
                    ),
                    SizedBox(height: tier.iconTitleGap),
                    Text(
                      title,
                      style: GoogleFonts.nunito(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w800,
                        color: accent,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                    ),
                    SizedBox(height: tier.titleSubtitleGap),
                    // Capped at 3 lines with a fixed reserved height so a
                    // long subtitle (e.g. "Earn your first badge 🏆", which
                    // measured 3 lines at our tightest tier) wraps
                    // predictably instead of silently pushing that one tile
                    // taller than its shorter-text siblings — the wrap
                    // becomes a defined limit, not an inconsistent side
                    // effect. 2 lines was tried first but truncated real
                    // text at these font sizes; 3 keeps everything visible.
                    SizedBox(
                      height: subtitleSize * 1.3 * 3,
                      child: Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: subtitleSize,
                          height: 1.3,
                          color: AppColors.muted,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
