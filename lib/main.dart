import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uni Buddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C3BFF),
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

// AuthGate — forces minimum 2 second splash then routes based on auth state
class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _minSplashDone = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _minSplashDone = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    if (!_minSplashDone) return const SplashScreen();

    return authState.when(
      loading: () => const SplashScreen(),
      error: (_, __) => const LoginPage(),
      data: (user) => user != null ? const HomePlaceholder() : const LoginPage(),
    );
  }
}

// Splash Screen — logo centered, name at bottom like Instagram
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1033),
      body: Stack(
        children: [
          // Logo in the center
          Center(
            child: SizedBox(
              width: 90,
              height: 90,
              child: CustomPaint(painter: UniBuddyLogoPainter()),
            ),
          ),

          // Name at the bottom like Instagram
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.nunito(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                    children: const [
                      TextSpan(text: 'Uni', style: TextStyle(color: Color(0xFFA08FFF))),
                      TextSpan(text: ' Buddy', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Egyptian University Discovery',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF8B7FB8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Home placeholder — will be replaced with real HomeScreen after co-founder meeting
class HomePlaceholder extends ConsumerWidget {
  const HomePlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: CustomPaint(painter: UniBuddyLogoPainter()),
              ),
              const SizedBox(height: 16),
              const Text(
                'Welcome to Uni Buddy! 🎓',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1033),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Home screen coming soon...',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8B7FB8),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () =>
                    ref.read(authNotifierProvider.notifier).signOut(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C3BFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}