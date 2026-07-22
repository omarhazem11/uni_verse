import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ad_banner.dart';
import '../providers/analytics_provider.dart';
import '../widgets/analytics_summary_card.dart';
import '../widgets/category_breakdown_card.dart';
import '../widgets/weekly_bar_chart.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(taskAnalyticsProvider);
    final totalOverdue = analytics.overdueCompletions + analytics.stillOverdueIncomplete;
    final onTimePercent =
        analytics.completedTasks == 0 ? null : (analytics.onTimeCompletions / analytics.completedTasks * 100).round();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
        title: Text(
          'Analytics',
          style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AnalyticsSummaryCard(
                          value: analytics.totalTasks == 0 ? '—' : '${(analytics.completionRate * 100).round()}%',
                          label: 'Completion Rate',
                          color: AppColors.violet,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AnalyticsSummaryCard(
                          value: analytics.completedTasks == 0 ? 'Get started! 🌱' : '${analytics.completedTasks}',
                          label: 'Tasks Completed',
                          color: AppColors.violet,
                          valueFontSize: analytics.completedTasks == 0 ? 16 : 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AnalyticsSummaryCard(
                          value: onTimePercent == null ? '—' : '$onTimePercent%',
                          label: onTimePercent == null ? 'On Time' : 'On Time (${analytics.onTimeCompletions})',
                          color: AppColors.mint,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AnalyticsSummaryCard(
                          value: totalOverdue == 0 ? 'None' : '$totalOverdue',
                          label: totalOverdue == 0 ? '— great job! 🎉' : 'Overdue',
                          color: AppColors.coral,
                          valueFontSize: totalOverdue == 0 ? 22 : 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _ChartCard(
                    title: 'Tasks Completed (Last 8 Weeks)',
                    child: WeeklyBarChart(weeks: analytics.weeklyCompletions),
                  ),
                  const SizedBox(height: 20),
                  CategoryBreakdownCard(breakdown: analytics.categoryBreakdown, totalTasks: analytics.totalTasks),
                ],
              ),
            ),
          ),
          const AdBanner(),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.ink.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
