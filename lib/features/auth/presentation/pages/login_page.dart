import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';

// ── Brand Colors ──
class AppColors {
  static const coral  = Color(0xFFFF5757);
  static const violet = Color(0xFF6C3BFF);
  static const mint   = Color(0xFF00D4A0);
  static const amber  = Color(0xFFFFB327);
  static const ink    = Color(0xFF1A1033);
  static const ink2   = Color(0xFF2E2350);
  static const muted  = Color(0xFF8B7FB8);
  static const bg     = Color(0xFFF7F4FF);
}

// ── University Card Data ──
class _UniCard {
  final String name;
  final String location;
  final String emoji;
  final Color color;

  const _UniCard({
    required this.name,
    required this.location,
    required this.emoji,
    required this.color,
  });
}

const _universities = [
  _UniCard(name: 'Cairo University', location: 'Giza', emoji: '🏛️', color: AppColors.violet),
  _UniCard(name: 'AUC', location: 'New Cairo', emoji: '🎓', color: AppColors.coral),
  _UniCard(name: 'Ain Shams', location: 'Cairo', emoji: '☀️', color: AppColors.amber),
  _UniCard(name: 'Alexandria Uni', location: 'Alexandria', emoji: '🌊', color: AppColors.mint),
  _UniCard(name: 'GUC', location: 'New Cairo', emoji: '🔬', color: AppColors.violet),
  _UniCard(name: 'Mansoura Uni', location: 'Mansoura', emoji: '⚕️', color: AppColors.coral),
];

// ── Animated Uni Card ──
class _AnimatedUniCard extends StatefulWidget {
  final _UniCard uni;
  final Duration duration;
  final Duration delay;

  const _AnimatedUniCard({
    required this.uni,
    required this.duration,
    required this.delay,
  });

  @override
  State<_AnimatedUniCard> createState() => _AnimatedUniCardState();
}

class _AnimatedUniCardState extends State<_AnimatedUniCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _floatAnim = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _floatAnim.value),
        child: child,
      ),
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: widget.uni.color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.uni.color.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: widget.uni.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(widget.uni.emoji,
                    style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.uni.name,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.uni.location,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.muted,
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

// ── Login Page ──
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

    final delays = [
      Duration.zero,
      const Duration(milliseconds: 400),
      const Duration(milliseconds: 800),
      const Duration(milliseconds: 200),
      const Duration(milliseconds: 600),
      const Duration(milliseconds: 1000),
    ];

    final durations = [
      const Duration(milliseconds: 2800),
      const Duration(milliseconds: 3200),
      const Duration(milliseconds: 2600),
      const Duration(milliseconds: 3000),
      const Duration(milliseconds: 2900),
      const Duration(milliseconds: 3100),
    ];

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

                      // ── Top: Logo + Headline ──
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: CustomPaint(painter: UniBuddyLogoPainter()),
                                ),
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
                                      TextSpan(text: ' Buddy', style: TextStyle(color: Colors.white)),
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
                      ),

                      const Spacer(),

                      // ── Middle: University Cards Grid ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            for (int row = 0; row < 3; row++) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: _AnimatedUniCard(
                                      uni: _universities[row * 2],
                                      delay: delays[row * 2],
                                      duration: durations[row * 2],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _AnimatedUniCard(
                                      uni: _universities[row * 2 + 1],
                                      delay: delays[row * 2 + 1],
                                      duration: durations[row * 2 + 1],
                                    ),
                                  ),
                                ],
                              ),
                              if (row < 2) const SizedBox(height: 10),
                            ],
                          ],
                        ),
                      ),

                      const Spacer(),

                      // ── Bottom: Buttons ──
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
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
                                  border: Border.all(
                                      color: AppColors.coral.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  authState.error.toString(),
                                  style: GoogleFonts.inter(
                                      color: AppColors.coral, fontSize: 13),
                                ),
                              ),

                            _SocialButton(
                              onPressed: authState is AsyncLoading
                                  ? null
                                  : () => ref
                                      .read(authNotifierProvider.notifier)
                                      .signInWithGoogle(),
                              icon: const _GoogleIcon(),
                              label: 'Continue with Google',
                              backgroundColor: Colors.white,
                              textColor: AppColors.ink,
                              isLoading: authState is AsyncLoading,
                            ),

                            const SizedBox(height: 12),

                            _SocialButton(
                              onPressed: () => _showComingSoon(context, 'Apple'),
                              icon: const Icon(Icons.apple, color: Colors.white, size: 22),
                              label: 'Continue with Apple',
                              backgroundColor: Colors.transparent,
                              textColor: Colors.white,
                              borderColor: AppColors.muted.withValues(alpha: 0.4),
                            ),

                            const SizedBox(height: 12),

                            _SocialButton(
                              onPressed: () => _showComingSoon(context, 'Facebook'),
                              icon: const _FacebookIcon(),
                              label: 'Continue with Facebook',
                              backgroundColor: const Color(0xFF1877F2),
                              textColor: Colors.white,
                            ),

                            const SizedBox(height: 16),

                            Text(
                              'By continuing, you agree to our Terms & Privacy Policy',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.muted,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
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
}

// ── Social Button ──
class _SocialButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final bool isLoading;

  const _SocialButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: borderColor != null
                ? BorderSide(color: borderColor!)
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: textColor, strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Google Icon ──
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4285F4)),
    );
  }
}

// ── Facebook Icon ──
class _FacebookIcon extends StatelessWidget {
  const _FacebookIcon();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'f',
      style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white),
    );
  }
}

// ── Logo Painter ──
class UniBuddyLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 160;

    void drawHand(double x, double y, double w, double h, Color color) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x * s, y * s, w * s, h * s),
          Radius.circular(14 * s),
        ),
        Paint()..color = color,
      );
    }

    void drawConnector(double x, double y, double w, double h, Color color) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x * s, y * s, w * s, h * s),
          Radius.circular(6 * s),
        ),
        Paint()..color = color,
      );
    }

    drawHand(10, 10, 44, 44, const Color(0xFFFF5757));
    drawConnector(50, 22, 22, 12, const Color(0xFFFF5757));
    drawConnector(22, 50, 12, 22, const Color(0xFFFF5757));

    drawHand(106, 10, 44, 44, const Color(0xFF6C3BFF));
    drawConnector(88, 22, 22, 12, const Color(0xFF6C3BFF));
    drawConnector(126, 50, 12, 22, const Color(0xFF6C3BFF));

    drawHand(10, 106, 44, 44, const Color(0xFF00D4A0));
    drawConnector(50, 126, 22, 12, const Color(0xFF00D4A0));
    drawConnector(22, 88, 12, 22, const Color(0xFF00D4A0));

    drawHand(106, 106, 44, 44, const Color(0xFFFFB327));
    drawConnector(88, 126, 22, 12, const Color(0xFFFFB327));
    drawConnector(126, 88, 12, 22, const Color(0xFFFFB327));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(62 * s, 62 * s, 36 * s, 36 * s),
        Radius.circular(8 * s),
      ),
      Paint()..color = const Color(0xFF1A1033),
    );

    canvas.drawCircle(
      Offset(80 * s, 80 * s),
      3 * s,
      Paint()..color = const Color(0xFF6C3BFF),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}