import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

// ─── Entry points ──────────────────────────────────────────────────────────

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const _LegalPage(title: 'Terms of Service', lastUpdated: 'July 2026', sections: _termsSections);
}

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const _LegalPage(title: 'Privacy Policy', lastUpdated: 'July 2026', sections: _privacySections);
}

// ─── Shared page shell ─────────────────────────────────────────────────────

class _LegalPage extends StatelessWidget {
  final String title;
  final String lastUpdated;
  final List<_Section> sections;

  const _LegalPage({
    required this.title,
    required this.lastUpdated,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const BackButton(color: AppColors.ink),
        title: Text(
          title,
          style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.divider),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
        children: [
          Text(
            'Last updated: $lastUpdated',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          for (final s in sections) ...[
            _SectionWidget(section: s),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}

class _SectionWidget extends StatelessWidget {
  final _Section section;
  const _SectionWidget({required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.heading,
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          section.body,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.ink2,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _Section {
  final String heading;
  final String body;
  const _Section(this.heading, this.body);
}

// ─── Terms of Service content ──────────────────────────────────────────────

const _termsSections = [
  _Section(
    'Acceptance of Terms',
    'By downloading or using Uni-Verse, you agree to be bound by these Terms of Service. If you do not agree, please do not use the app. We may update these terms from time to time and will notify you of material changes.',
  ),
  _Section(
    'Description of Service',
    'Uni-Verse is a productivity and discovery app designed for Egyptian university students. It provides tools to manage tasks, plan schedules, take notes, and explore universities. The app is offered free of charge and is intended for personal, non-commercial use.',
  ),
  _Section(
    'User Accounts',
    'You must sign in with a valid Google account to use Uni-Verse. You are responsible for keeping your account credentials secure. You agree not to share your account with others or use another person\'s account without permission.',
  ),
  _Section(
    'User Content',
    'You retain ownership of any content you create in the app (tasks, notes, planner entries). By storing content in Uni-Verse, you grant us a limited license to process and display that content solely for the purpose of providing the service to you. We do not claim ownership of your data.',
  ),
  _Section(
    'Acceptable Use',
    'You agree to use Uni-Verse only for lawful purposes. You must not attempt to reverse-engineer the app, exploit security vulnerabilities, or use the service in a way that could harm other users or disrupt the platform. Accounts found in violation may be suspended.',
  ),
  _Section(
    'Intellectual Property',
    'All design, code, branding, and original content in Uni-Verse (excluding user-generated content) are the intellectual property of the Uni-Verse team. You may not copy, modify, or redistribute any part of the app without explicit written permission.',
  ),
  _Section(
    'Termination',
    'You may stop using the app and delete your account at any time from Account Settings. We reserve the right to suspend or terminate accounts that violate these terms. Upon termination, your data will be deleted from our servers as described in our Privacy Policy.',
  ),
  _Section(
    'Disclaimers',
    'Uni-Verse is provided "as is" without warranties of any kind. We do not guarantee that the app will be available at all times or that university information displayed is always current and accurate. University data is provided for informational purposes only.',
  ),
  _Section(
    'Limitation of Liability',
    'To the maximum extent permitted by law, Uni-Verse and its developers shall not be liable for any indirect, incidental, or consequential damages arising from your use of the app, including data loss, missed deadlines, or reliance on university information.',
  ),
  _Section(
    'Contact',
    'Questions about these terms? Reach us at support@uni-verse.app. We aim to respond within 48 hours.',
  ),
];

// ─── Privacy Policy content ────────────────────────────────────────────────

const _privacySections = [
  _Section(
    'Overview',
    'Uni-Verse is built with student privacy in mind. We collect the minimum information necessary to provide the service and never sell your data to third parties. This policy explains what we collect, why, and how you can control it.',
  ),
  _Section(
    'Information We Collect',
    'Account information: Your name and email address from your Google account, used only to identify you within the app.\n\nUser content: Tasks, notes, planner entries, and preferences you create are stored in Firebase Firestore under your account.\n\nUsage data: Anonymous analytics such as which features are used, crash reports, and performance metrics to help us improve the app. This data is never linked to your identity.',
  ),
  _Section(
    'How We Use Your Information',
    'We use your information solely to:\n• Provide and personalise the Uni-Verse experience\n• Sync your data across devices\n• Send task reminder notifications you have opted in to\n• Diagnose bugs and improve performance\n\nWe do not use your data for advertising, profiling, or any purpose beyond operating the app.',
  ),
  _Section(
    'Data Storage and Security',
    'Your data is stored on Google Firebase (Firestore and Authentication), which complies with industry-standard security practices including encryption at rest and in transit. We apply Firestore security rules so only you can read or write your own data.',
  ),
  _Section(
    'Third-Party Services',
    'Uni-Verse uses the following third-party services, each with their own privacy policies:\n• Google Firebase — authentication and data storage\n• Google Sign-In — account authentication\n• Google Fonts — font rendering (no tracking)\n\nNo other third parties receive your personal data.',
  ),
  _Section(
    'Data Retention',
    'Your data is retained as long as your account is active. If you delete your account (Account Settings → Delete Account), all your data — tasks, notes, planner entries, and achievements — is permanently deleted from our servers within 30 days.',
  ),
  _Section(
    'Notifications',
    'If you enable task reminders, we store the reminder time locally on your device to schedule notifications. Notification preferences are synced to your account so they persist across reinstalls. You can disable notifications at any time from Account Settings.',
  ),
  _Section(
    'Children\'s Privacy',
    'Uni-Verse is intended for users aged 13 and older. We do not knowingly collect personal information from children under 13. If you believe a child under 13 has created an account, please contact us and we will delete it promptly.',
  ),
  _Section(
    'Your Rights',
    'You have the right to:\n• Access the personal data we hold about you\n• Export your data (Account Settings → Export My Data)\n• Delete your account and all associated data\n• Opt out of notifications at any time\n\nFor any data request, contact us at support@uni-verse.app.',
  ),
  _Section(
    'Changes to This Policy',
    'We may update this Privacy Policy from time to time. We will notify you of significant changes through the app. Your continued use of Uni-Verse after changes are posted constitutes acceptance of the updated policy.',
  ),
  _Section(
    'Contact Us',
    'If you have questions or concerns about your privacy, please reach out at support@uni-verse.app. We take all privacy enquiries seriously and will respond within 48 hours.',
  ),
];
