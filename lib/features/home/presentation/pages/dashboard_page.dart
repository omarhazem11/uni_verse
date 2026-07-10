import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/dashboard_bottom_nav.dart';
import '../widgets/dashboard_hero_card.dart';
import '../widgets/dashboard_tile_grid.dart';
import '../widgets/dashboard_top_nav.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final firstName = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!.trim().split(' ').first
        : 'there';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const DashboardTopNav(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DashboardHeroCard(
                      greeting: 'Good morning, $firstName 👋',
                      subtitle: 'You have 0 things due this week',
                    ),
                    const SizedBox(height: 14),
                    const DashboardTileGrid(),
                  ],
                ),
              ),
            ),
            const DashboardBottomNav(),
          ],
        ),
      ),
    );
  }
}
