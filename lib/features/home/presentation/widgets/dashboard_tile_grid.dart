import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
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
}
