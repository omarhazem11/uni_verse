import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_colors.dart';
import 'core/widgets/uni_verse_logo.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/home/presentation/pages/main_shell.dart';
import 'features/notifications/presentation/providers/notification_provider.dart';
import 'features/onboarding/domain/entities/user_type.dart';
import 'features/onboarding/presentation/pages/coming_soon_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/onboarding/presentation/providers/onboarding_provider.dart';
import 'features/tasks/data/models/task_model.dart';
import 'features/tasks/presentation/pages/task_detail_page.dart';
import 'features/tasks/presentation/providers/task_provider.dart';
import 'firebase_options.dart';

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
      title: 'Uni-Verse',
      debugShowCheckedModeBanner: false,
      navigatorKey: NotificationService.navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.violet),
        useMaterial3: true,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: const {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const AuthGate(),
    );
  }
}

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
      data: (user) => user != null ? const _PostLoginRouter() : const LoginPage(),
    );
  }
}

class _PostLoginRouter extends ConsumerStatefulWidget {
  const _PostLoginRouter();

  @override
  ConsumerState<_PostLoginRouter> createState() => _PostLoginRouterState();
}

class _PostLoginRouterState extends ConsumerState<_PostLoginRouter> {
  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    final repository = ref.read(notificationRepositoryProvider);
    await NotificationService.initialize(
      repository: repository,
      onTapNavigate: _handleNotificationTap,
    );
    await NotificationService.requestPermission();

    // Wait for the first task list from cache/server, but don't block
    // notification setup indefinitely if the stream is slow to emit.
    final tasks = await ref
        .read(tasksStreamProvider.future)
        .timeout(const Duration(seconds: 5), onTimeout: () => []);
    await NotificationService.rescheduleAllReminders(tasks);
  }

  Future<void> _handleNotificationTap(String taskId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .doc(taskId)
          .get();
      if (!doc.exists) return;
      final task = TaskModel.fromFirestore(doc);
      NotificationService.navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => TaskDetailPage(task: task)),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final userTypeAsync = ref.watch(userTypeProvider);

    return userTypeAsync.when(
      loading: () => const SplashScreen(showSpinner: true),
      error: (_, __) => const OnboardingPage(),
      data: (userType) => switch (userType) {
        null => const OnboardingPage(),
        UserType.student => const MainShell(),
        UserType.searching => const ComingSoonPage(),
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.showSpinner = false});

  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        children: [
          const Center(child: UniVerseLogo(size: 90)),
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
                      TextSpan(text: '-Verse', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Egyptian University Discovery',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
                if (showSpinner) ...[
                  const SizedBox(height: 24),
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFA08FFF),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
