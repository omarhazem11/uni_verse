import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/pages/task_detail_page.dart';
import '../../../tasks/presentation/utils/task_date_format.dart';
import '../utils/task_urgency.dart';
import 'circular_progress_ring.dart';
import 'dashboard_next_task_empty_card.dart';

/// Replaces the "Getting started" card once onboarding is complete — shows
/// the single most urgent upcoming task. Runs its own periodic timer so the
/// urgency ring visibly progresses while the app stays open, without the
/// parent needing to know about the ticking.
class DashboardNextTaskCard extends StatefulWidget {
  final TaskEntity? task;

  const DashboardNextTaskCard({super.key, required this.task});

  @override
  State<DashboardNextTaskCard> createState() => _DashboardNextTaskCardState();
}

class _DashboardNextTaskCardState extends State<DashboardNextTaskCard>
    with SingleTickerProviderStateMixin {
  Timer? _ticker;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    if (task == null || task.dueDate == null) return const EmptyNextTaskCard();

    final urgency = computeTaskUrgency(task.dueDate!, DateTime.now());
    if (urgency.isOverdue && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!urgency.isOverdue && _pulseController.isAnimating) {
      _pulseController.stop();
    }
    final ring = CircularProgressRing(
      size: 48,
      strokeWidth: 5,
      progress: urgency.fillPercent,
      color: urgency.color,
      label: urgency.centerLabel,
    );

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TaskDetailPage(task: task)),
      ),
      child: DashboardNextTaskCardShell(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = urgency.isOverdue ? 1.0 + (0.05 * _pulseController.value) : 1.0;
                return Transform.scale(key: const Key('urgencyRingPulse'), scale: scale, child: child);
              },
              child: ring,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Due ${shortDateLabel(task.dueDate!)}, ${shortTimeLabel(task.dueDate!)}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: urgency.isOverdue ? FontWeight.w700 : FontWeight.w400,
                      color: urgency.isOverdue ? AppColors.coral : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
