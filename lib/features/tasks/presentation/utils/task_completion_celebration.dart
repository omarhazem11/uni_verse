import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/subscription_provider.dart';
import '../../../../core/services/ad_service.dart';
import '../../../achievements/presentation/providers/achievements_provider.dart';
import '../../../achievements/presentation/utils/celebrate_badges.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_provider.dart';

/// Toggles completion and, only when marking a task complete (not when
/// un-completing it), records the achievement event and celebrates any
/// newly unlocked badges. Shared by the task tile's checkbox and the
/// detail page's header checkbox so the two never drift out of sync.
Future<void> toggleTaskCompletionAndCelebrate(
  BuildContext context,
  WidgetRef ref,
  TaskEntity task,
  bool isCompleted,
) async {
  await ref.read(taskActionsProvider.notifier).toggleComplete(task.id, isCompleted);
  if (!isCompleted || !context.mounted) return;

  final wasEarly = task.dueDate != null && DateTime.now().isBefore(task.dueDate!);
  await ref.read(achievementsActionsProvider.notifier).recordTaskCompleted(wasEarly: wasEarly);
  if (context.mounted) await recalculateAndCelebrate(context, ref);

  final isPro = ref.read(subscriptionProvider).value ?? false;
  AdService.maybeShowInterstitial(isPro: isPro);
}
