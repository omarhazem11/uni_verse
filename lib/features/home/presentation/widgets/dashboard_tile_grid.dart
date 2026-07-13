import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../achievements/presentation/pages/achievements_page.dart';
import '../../../achievements/presentation/providers/achievements_provider.dart';
import '../../../notes/presentation/pages/notes_page.dart';
import '../../../notes/presentation/providers/note_provider.dart';
import '../../../planner/presentation/pages/planner_page.dart';
import '../../../planner/presentation/providers/planner_provider.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/pages/tasks_page.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../../tasks/presentation/utils/task_stats.dart';
import 'dashboard_tile.dart';

class DashboardTileGrid extends ConsumerWidget {
  const DashboardTileGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksStreamProvider).value ?? [];
    final tasksSubtitle = _tasksSubtitle(tasks);
    final todayItemCount = ref.watch(dayItemsProvider(dateOnly(DateTime.now()))).value?.length ?? 0;
    final plannerSubtitle = todayItemCount > 0 ? '$todayItemCount scheduled today' : 'Plan your week 📅';
    final unlockedBadgeCount =
        ref.watch(badgesProvider).value?.where((b) => b.isUnlocked).length ?? 0;
    final badgesSubtitle =
        unlockedBadgeCount > 0 ? '$unlockedBadgeCount badges earned' : 'Earn your first badge 🏆';
    final noteCount = ref.watch(notesStreamProvider).value?.length ?? 0;
    final notesSubtitle = noteCount > 0 ? '$noteCount notes' : 'Start writing 📝';

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
                  subtitle: tasksSubtitle,
                  background: AppColors.tileCoralBg,
                  iconBackground: AppColors.tileCoralIcon,
                  accent: AppColors.tileCoralText,
                  onTap: () => _openTasks(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DashboardTile(
                  icon: Icons.calendar_month_rounded,
                  title: 'Planner',
                  subtitle: plannerSubtitle,
                  background: AppColors.tileVioletBg,
                  iconBackground: AppColors.tileVioletIcon,
                  accent: AppColors.tileVioletText,
                  onTap: () => _openPlanner(context),
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
                  subtitle: notesSubtitle,
                  background: AppColors.tileMintBg,
                  iconBackground: AppColors.tileMintIcon,
                  accent: AppColors.tileMintText,
                  onTap: () => _openNotes(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DashboardTile(
                  icon: Icons.emoji_events_outlined,
                  title: 'Badges',
                  subtitle: badgesSubtitle,
                  background: AppColors.tileAmberBg,
                  iconBackground: AppColors.tileAmberIcon,
                  accent: AppColors.tileAmberText,
                  onTap: () => _openAchievements(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _tasksSubtitle(List<TaskEntity> tasks) {
    if (tasks.isEmpty) return 'Add your first task! ✏️';

    final active = tasks.activeCount;
    if (active == 0) return 'All done for now! ✅';

    final dueSoon = tasks.dueWithin(const Duration(days: 3));
    if (dueSoon > 0) return '$dueSoon due soon';
    return '$active tasks on track';
  }

  void _openTasks(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TasksPage()));
  }

  void _openPlanner(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlannerPage()));
  }

  void _openAchievements(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AchievementsPage()));
  }

  void _openNotes(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotesPage()));
  }
}
