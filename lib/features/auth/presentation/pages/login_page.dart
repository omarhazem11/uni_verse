import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/uni_verse_logo.dart';
import '../../../../main.dart';
import '../providers/account_deletion_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/legal_links_text.dart';
import '../widgets/social_button.dart';
import '../widgets/uni_card_grid.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  void _showComingSoon(BuildContext context, String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$provider Sign-In coming soon!',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: AppColors.violet,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    // Show a full-screen loading splash while Google sign-in is in progress
    // (account picker is open or Firebase is processing the credential).
    if (authState is AsyncLoading) return const SplashScreen(showSpinner: true);

    // Watched (not ref.listen) deliberately: the flag is set to true
    // *before* LoginPage ever mounts (deletion pops back to root, then
    // LoginPage appears once AuthGate sees the signed-out state), so this
    // needs to react to the value already being true on the very first
    // build — ref.listen alone only reacts to changes from here forward and
    // would silently miss it. The side effect and the reset are deferred
    // (post-frame / microtask) since providers can't be mutated mid-build.
    final justDeleted = ref.watch(accountJustDeletedProvider);
    if (justDeleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Your account has been deleted',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: AppColors.ink2,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      });
      Future.microtask(() => ref.read(accountJustDeletedProvider.notifier).state = false);
    }

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const Spacer(),
                      _buildCardSection(),
                      const Spacer(),
                      _buildButtons(context, ref, authState),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const UniVerseLogo(size: 44),
              const SizedBox(width: 12),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.nunito(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                  ),
                  children: const [
                    TextSpan(text: 'Uni', style: TextStyle(color: Color(0xFFA08FFF))),
                    TextSpan(text: '-Verse', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'Find your perfect\nuniversity 🎓',
            style: GoogleFonts.nunito(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Join thousands of Egyptian students discovering their future.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.muted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const UniCardGrid(),
          const SizedBox(height: 12),
          _buildMoreHint(),
        ],
      ),
    );
  }

  Widget _buildMoreHint() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _colorDot(AppColors.violet),
        const SizedBox(width: 6),
        _colorDot(AppColors.coral),
        const SizedBox(width: 6),
        _colorDot(AppColors.mint),
        const SizedBox(width: 6),
        _colorDot(AppColors.amber),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            '+46 more universities inside',
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
        ),
      ],
    );
  }

  Widget _colorDot(Color color) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildButtons(
      BuildContext context, WidgetRef ref, AsyncValue authState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (authState is AsyncError)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.coral.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.coral.withValues(alpha: 0.3)),
              ),
              child: Text(
                authState.error.toString(),
                style: GoogleFonts.inter(color: AppColors.coral, fontSize: 13),
              ),
            ),

          SocialButton(
            onPressed: authState is AsyncLoading
                ? null
                : () => ref.read(authNotifierProvider.notifier).signInWithGoogle(),
            icon: const _GoogleIcon(),
            label: 'Continue with Google',
            backgroundColor: Colors.white,
            textColor: AppColors.ink,
            isLoading: authState is AsyncLoading,
          ),

          const SizedBox(height: 12),

          SocialButton(
            onPressed: () => _showComingSoon(context, 'Apple'),
            icon: const Icon(Icons.apple, color: Colors.white, size: 22),
            label: 'Continue with Apple',
            backgroundColor: Colors.transparent,
            textColor: Colors.white,
            borderColor: AppColors.muted.withValues(alpha: 0.4),
          ),

          const SizedBox(height: 12),

          SocialButton(
            onPressed: () => _showComingSoon(context, 'Facebook'),
            icon: const _FacebookIcon(),
            label: 'Continue with Facebook',
            backgroundColor: const Color(0xFF1877F2),
            textColor: Colors.white,
          ),

          const SizedBox(height: 10),

          const LegalLinksText(),
        ],
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4285F4)),
    );
  }
}

class _FacebookIcon extends StatelessWidget {
  const _FacebookIcon();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'f',
      style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }
}
