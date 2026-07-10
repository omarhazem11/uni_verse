import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'dashboard_tile.dart';

class DashboardTileGrid extends StatelessWidget {
  const DashboardTileGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: [
        DashboardTile(
          icon: Icons.checklist_rounded,
          title: 'Tasks',
          subtitle: 'Nothing yet',
          background: AppColors.tileCoralBg,
          iconBackground: AppColors.tileCoralIcon,
          textColor: AppColors.tileCoralText,
          onTap: () {},
        ),
        DashboardTile(
          icon: Icons.calendar_month_rounded,
          title: 'Planner',
          subtitle: 'No events',
          background: AppColors.tileVioletBg,
          iconBackground: AppColors.tileVioletIcon,
          textColor: AppColors.tileVioletText,
          onTap: () {},
        ),
        DashboardTile(
          icon: Icons.description_outlined,
          title: 'Notes',
          subtitle: '0 saved',
          background: AppColors.tileMintBg,
          iconBackground: AppColors.tileMintIcon,
          textColor: AppColors.tileMintText,
          onTap: () {},
        ),
        DashboardTile(
          icon: Icons.emoji_events_outlined,
          title: 'Achievements',
          subtitle: '0 badges',
          background: AppColors.tileAmberBg,
          iconBackground: AppColors.tileAmberIcon,
          textColor: AppColors.tileAmberText,
          onTap: () {},
        ),
      ],
    );
  }
}
