import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_type.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_choice_card.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'One quick question',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.violet,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Are you already a student, or\nsearching for your university?',
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 32),
              OnboardingChoiceCard(
                icon: Icons.school_rounded,
                title: "I'm a student",
                subtitle: 'I already have a university',
                accent: AppColors.violet,
                onTap: () => ref
                    .read(onboardingNotifierProvider.notifier)
                    .chooseUserType(UserType.student),
              ),
              const SizedBox(height: 14),
              OnboardingChoiceCard(
                icon: Icons.search_rounded,
                title: "I'm searching for my university",
                subtitle: 'Help me find the right fit',
                accent: AppColors.coral,
                onTap: () => ref
                    .read(onboardingNotifierProvider.notifier)
                    .chooseUserType(UserType.searching),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
