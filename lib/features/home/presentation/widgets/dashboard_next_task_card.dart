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

    final now = DateTime.now();
    final urgency = computeTaskUrgency(task.dueDate!, now);

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

    final cardContent = Row(
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
              if (urgency.isOverdue) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.coral,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'OVERDUE',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                urgency.isOverdue
                    ? _overdueLabel(task.dueDate!, now)
                    : 'Due ${shortDateLabel(task.dueDate!)}, ${shortTimeLabel(task.dueDate!)}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: urgency.isOverdue ? FontWeight.w600 : FontWeight.w400,
                  color: urgency.isOverdue ? AppColors.coral : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 20),
      ],
    );

    if (urgency.isOverdue) {
      return GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TaskDetailPage(task: task)),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.coral.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.coral.withValues(alpha: 0.35), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.coral.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: cardContent,
        ),
      );
    }

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TaskDetailPage(task: task)),
      ),
      child: DashboardNextTaskCardShell(child: cardContent),
    );
  }

  String _overdueLabel(DateTime dueDate, DateTime now) {
    final diff = now.difference(dueDate);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min overdue';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h hr${h == 1 ? '' : 's'} overdue';
    }
    final d = diff.inDays;
    return '$d day${d == 1 ? '' : 's'} overdue';
  }
}
