import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_verse/core/errors/failures.dart';
import 'package:uni_verse/features/achievements/presentation/providers/achievements_provider.dart';
import 'package:uni_verse/features/auth/domain/entities/user_entity.dart';
import 'package:uni_verse/features/auth/domain/repositories/auth_repository.dart';
import 'package:uni_verse/features/auth/presentation/pages/login_page.dart';
import 'package:uni_verse/features/auth/presentation/providers/auth_provider.dart';
import 'package:uni_verse/features/home/presentation/pages/dashboard_page.dart';
import 'package:uni_verse/features/notes/presentation/providers/note_provider.dart';
import 'package:uni_verse/features/onboarding/domain/entities/user_type.dart';
import 'package:uni_verse/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:uni_verse/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:uni_verse/features/planner/domain/entities/planner_settings_entity.dart';
import 'package:uni_verse/features/planner/domain/entities/schedule_item_entity.dart';
import 'package:uni_verse/features/planner/domain/repositories/planner_repository.dart';
import 'package:uni_verse/features/planner/presentation/providers/planner_provider.dart';
import 'package:uni_verse/features/tasks/domain/entities/task_entity.dart';
import 'package:uni_verse/features/tasks/presentation/providers/task_provider.dart';
import 'package:uni_verse/main.dart' as app;
import 'fakes/fake_achievements_datasource.dart';
import 'fakes/fake_note_datasource.dart';

const _user = UserEntity(id: '1', email: 's@t.com', displayName: 'Sara');

/// Simulates real FirebaseAuth: signOut/deleteAccount both push a null user
/// onto the same stream AuthGate watches, so tests can verify the app
/// reacts to that state change without needing a real Firebase backend.
class _FakeAuthRepository implements AuthRepository {
  // Single-subscription (not .broadcast()) — authStateProvider is the only
  // ever subscriber, and unlike broadcast controllers, a plain
  // StreamController correctly buffers events added before anything is
  // listening yet, so the initial user isn't silently dropped.
  final _controller = StreamController<UserEntity?>()..add(_user);
  bool deleteAccountCalled = false;
  bool deleteShouldSucceed = true;

  @override
  Stream<UserEntity?> get authStateChanges => _controller.stream;

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async => throw UnimplementedError();

  @override
  Future<Either<Failure, UserEntity>> signInWithFacebook() async => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> signOut() async {
    _controller.add(null);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    deleteAccountCalled = true;
    if (!deleteShouldSucceed) return const Left(AuthFailure('boom'));
    _controller.add(null);
    return const Right(null);
  }
}

/// In-memory stand-in for the Firestore-backed onboarding choice — no local
/// caching involved, matching production now that userType lives only in
/// Firestore.
class _FakeOnboardingRepository implements OnboardingRepository {
  UserType? userType;

  _FakeOnboardingRepository([this.userType]);

  @override
  Future<UserType?> getUserType() async => userType;

  @override
  Future<void> setUserType(UserType type) async => userType = type;
}

class _FakePlannerRepository implements PlannerRepository {
  @override
  Stream<List<ScheduleItemEntity>> watchItemsForDate(DateTime date) => Stream.value(const []);

  @override
  Stream<List<ScheduleItemEntity>> watchItemsInRange(DateTime start, DateTime end) => Stream.value(const []);

  @override
  Stream<PlannerSettingsEntity> watchSettings() => Stream.value(const PlannerSettingsEntity());

  @override
  Future<Either<Failure, void>> addItem(ScheduleItemEntity item) async => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> updateItem(ScheduleItemEntity item) async => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deleteItem(String itemId) async => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> duplicateItemsToDate(DateTime sourceDate, List<DateTime> targetDates) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> updateSettings(PlannerSettingsEntity settings) async => throw UnimplementedError();
}

Future<_FakeAuthRepository> _pumpAuthGate(WidgetTester tester) async {
  tester.view.physicalSize = const Size(400, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final fakeAuth = _FakeAuthRepository();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeAuth),
        onboardingRepositoryProvider.overrideWithValue(_FakeOnboardingRepository(UserType.student)),
        tasksStreamProvider.overrideWith((ref) => Stream.value(const <TaskEntity>[])),
        plannerRepositoryProvider.overrideWithValue(_FakePlannerRepository()),
        achievementsRemoteDataSourceProvider.overrideWithValue(FakeAchievementsDataSource()),
        noteRemoteDataSourceProvider.overrideWithValue(FakeNoteRemoteDataSource()),
      ],
      child: const MaterialApp(home: app.AuthGate()),
    ),
  );
  // AuthGate holds a fixed 2s splash timer before it evaluates auth/onboarding state.
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
  return fakeAuth;
}

// Popping multiple stacked routes (popUntil) in immediate succession after a
// menu-close animation leaves overlapping route transitions that
// pumpAndSettle's "wait for zero pending frames" definition never quite
// reaches within its timeout, even though the app has already settled into
// the correct final state. Polling in bounded steps sidesteps that without
// masking a real hang (it still fails if the finder never appears).
Future<void> _pumpUntilFound(WidgetTester tester, Finder finder, {int maxIterations = 15}) async {
  for (var i = 0; i < maxIterations; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 300));
  }
}

// A SnackBar's default ~4s auto-dismiss timer means checking for its text
// must happen right after _pumpUntilFound (which returns as soon as it's
// first visible) — a long or unbounded pump afterward (pumpAndSettle
// included) would sit through the SnackBar's full lifetime and see it
// gone by the time an assertion runs. Call this only *after* such
// assertions, to drain any still-running timers (e.g. a badge-celebration
// toast on the page being left behind) before the test ends, since a timer
// still pending at teardown fails the test on its own.
Future<void> _drainTimers(WidgetTester tester) => tester.pump(const Duration(seconds: 5));

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('signing out from a pushed-on-top dashboard immediately shows the login page', (tester) async {
    await _pumpAuthGate(tester);
    expect(find.byType(DashboardPage), findsOneWidget);

    // Simulate reaching the dashboard via a pushed route (e.g. from
    // ComingSoonPage's "Go to Dashboard anyway" button) rather than as the
    // root — this is the scenario where stale routes used to hide LoginPage.
    final rootContext = tester.element(find.byType(DashboardPage));
    Navigator.of(rootContext).push(MaterialPageRoute(builder: (_) => const DashboardPage()));
    await tester.pumpAndSettle();
    // The bottom route goes offstage once the push transition settles, and
    // finders skip offstage elements by default — so exactly one
    // DashboardPage is "visible" here even though two are mounted. What
    // matters is that signing out from *this* (topmost, reachable-via-push)
    // one clears the whole stack, not just this single route.
    expect(find.byType(DashboardPage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign Out'));
    await _pumpUntilFound(tester, find.byType(LoginPage));
    // The just-popped route(s) are still mid-transition at the exact frame
    // LoginPage first appears; a few more short pumps lets them finish
    // disposing before asserting they're gone.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(DashboardPage), findsNothing);
    await _drainTimers(tester);
  });

  testWidgets('deleting the account clears data, deletes the auth user, and returns to login', (tester) async {
    final fakeAuth = await _pumpAuthGate(tester);
    expect(find.byType(DashboardPage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();

    expect(find.text('Delete your account?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await _pumpUntilFound(tester, find.textContaining('Your account has been deleted'));

    expect(fakeAuth.deleteAccountCalled, isTrue);
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.textContaining('Your account has been deleted'), findsOneWidget);

    // Local state tied to the deleted account must not survive. The
    // onboarding choice itself now lives only in Firestore (not
    // SharedPreferences) specifically so there's no local cache of it to
    // leak across accounts — this just confirms the general-purpose local
    // cache clear still ran.
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), isEmpty);
    await _drainTimers(tester);
  });

  testWidgets('a failed account deletion shows an error and keeps the user in the app', (tester) async {
    final fakeAuth = await _pumpAuthGate(tester);
    fakeAuth.deleteShouldSucceed = false;

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await _pumpUntilFound(tester, find.textContaining("Couldn't delete account"));

    expect(find.textContaining("Couldn't delete account"), findsOneWidget);
    // User stays in the app (not kicked to LoginPage) — they're on AccountSettingsPage.
    expect(find.byType(LoginPage), findsNothing);
    await _drainTimers(tester);
  });
}
