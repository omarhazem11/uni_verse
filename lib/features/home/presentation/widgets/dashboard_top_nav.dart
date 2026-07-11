import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/uni_verse_logo.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class DashboardTopNav extends ConsumerWidget {
  const DashboardTopNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const UniVerseLogo(size: 32),
              const SizedBox(width: 9),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.nunito(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                  children: const [
                    TextSpan(text: 'Uni', style: TextStyle(color: AppColors.violet)),
                    TextSpan(text: '-Verse', style: TextStyle(color: AppColors.ink)),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              _NavIconButton(
                icon: Icons.notifications_outlined,
                iconColor: AppColors.violet,
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _KebabMenu(
                onSignOut: () =>
                    ref.read(authNotifierProvider.notifier).signOut(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _NavIconButton({
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}

class _KebabMenu extends StatelessWidget {
  final VoidCallback onSignOut;

  const _KebabMenu({required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(13),
      ),
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.more_vert_rounded, color: AppColors.violet, size: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onSelected: (value) {
          if (value == 'sign_out') onSignOut();
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'sign_out', child: Text('Sign out')),
        ],
      ),
    );
  }
}
