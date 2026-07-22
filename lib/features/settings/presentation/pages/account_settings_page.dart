import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/utils/delete_account_flow.dart';
import '../../../onboarding/domain/entities/user_type.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../../core/providers/subscription_provider.dart';
import '../../../subscription/presentation/pages/paywall_page.dart';
import '../../data/data_export_service.dart';
import '../providers/settings_provider.dart';
import '../utils/switch_user_type_flow.dart';
import '../widgets/settings_row.dart';
import '../widgets/settings_section.dart';
import 'legal_page.dart';

const _supportEmail = 'support@uni-verse.app';

class AccountSettingsPage extends ConsumerStatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  ConsumerState<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends ConsumerState<AccountSettingsPage> {
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    final userType = ref.watch(userTypeProvider).value;
    final notifEnabled = ref.watch(notificationsEnabledProvider);
    final version = ref.watch(packageInfoProvider).value?.version ?? '…';
    final isPro = ref.watch(subscriptionProvider).value ?? false;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text('Settings',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.ink)),
        leading: const BackButton(color: AppColors.ink),
        bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1), child: Divider(height: 1, color: AppColors.divider)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        children: [
          SettingsSection(label: 'MEMBERSHIP', children: [
            SettingsRow(
              icon: Icons.workspace_premium_rounded,
              title: isPro ? 'Uni-Verse Pro' : 'Go Pro',
              subtitle: isPro
                  ? 'Your subscription is active'
                  : 'Remove ads and unlock premium features',
              titleColor: isPro ? AppColors.violet : null,
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const PaywallPage())),
            ),
          ]),
          SettingsSection(label: 'ACCOUNT', children: [
            if (userType == UserType.searching)
              SettingsRow(
                icon: Icons.school_rounded,
                title: 'Switch to Student Mode',
                subtitle: 'Found your university? Switch to student mode',
                onTap: () => confirmAndSwitchToStudent(context, ref),
              ),
            SettingsRow(icon: Icons.logout_rounded, title: 'Sign Out', onTap: () => _signOut(context)),
            SettingsRow(
              icon: Icons.delete_forever_rounded,
              title: 'Delete Account',
              titleColor: AppColors.coral,
              onTap: () => confirmAndDeleteAccount(context, ref),
            ),
          ]),
          SettingsSection(label: 'NOTIFICATIONS', children: [
            SettingsRow(
              icon: Icons.notifications_outlined,
              title: 'Task Reminders',
              subtitle: 'Get notified before tasks are due',
              trailing: Switch(
                value: notifEnabled,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.violet,
                onChanged: (_) => ref.read(notificationsEnabledProvider.notifier).toggle(),
              ),
              onTap: null,
            ),
          ]),
          SettingsSection(label: 'DATA', children: [
            SettingsRow(
              icon: Icons.download_rounded,
              title: 'Export My Data',
              subtitle: 'Download your tasks, notes, and planner as a file',
              trailing: _exporting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.violet))
                  : null,
              onTap: _exporting ? null : () => _export(context),
            ),
          ]),
          SettingsSection(label: 'SUPPORT', children: [
            SettingsRow(
              icon: Icons.email_outlined,
              title: 'Contact Support',
              subtitle: "We're here to help",
              onTap: () => _launch('mailto:$_supportEmail?subject=Uni-Verse%20Support'),
            ),
            SettingsRow(
              icon: Icons.star_outline_rounded,
              title: 'Rate Uni-Verse',
              subtitle: 'Enjoying the app? Leave a review!',
              onTap: () => _rateComingSoon(context),
            ),
          ]),
          SettingsSection(label: 'ABOUT', children: [
            SettingsRow(
              icon: Icons.info_outline_rounded,
              title: 'Version',
              trailing: Text(version, style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted)),
              onTap: null,
            ),
            SettingsRow(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TermsPage())),
            ),
            SettingsRow(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrivacyPage())),
            ),
          ]),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await ref.read(authNotifierProvider.notifier).signOut();
    if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _export(BuildContext context) async {
    setState(() => _exporting = true);
    try {
      await DataExportService.run();
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _launch(String url) async =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  void _rateComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Coming soon once we're live on the App Store! 🚀",
          style: GoogleFonts.inter(color: Colors.white)),
      backgroundColor: AppColors.violet,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }
}
