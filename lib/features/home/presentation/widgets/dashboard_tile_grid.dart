import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'dashboard_tile.dart';

class DashboardTileGrid extends StatelessWidget {
  const DashboardTileGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: DashboardTile(
                  icon: Icons.checklist_rounded,
                  title: 'Tasks',
                  subtitle: 'Add your first task! ✏️',
                  background: AppColors.tileCoralBg,
                  iconBackground: AppColors.tileCoralIcon,
                  accent: AppColors.tileCoralText,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DashboardTile(
                  icon: Icons.calendar_month_rounded,
                  title: 'Planner',
                  subtitle: 'Plan your week 📅',
                  background: AppColors.tileVioletBg,
                  iconBackground: AppColors.tileVioletIcon,
                  accent: AppColors.tileVioletText,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: DashboardTile(
                  icon: Icons.description_outlined,
                  title: 'Notes',
                  subtitle: 'Start writing 📝',
                  background: AppColors.tileMintBg,
                  iconBackground: AppColors.tileMintIcon,
                  accent: AppColors.tileMintText,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DashboardTile(
                  icon: Icons.emoji_events_outlined,
                  title: 'Badges',
                  subtitle: 'Earn first badge 🏆',
                  background: AppColors.tileAmberBg,
                  iconBackground: AppColors.tileAmberIcon,
                  accent: AppColors.tileAmberText,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
