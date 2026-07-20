import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

// DataSource Provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    firebaseAuth: FirebaseAuth.instance,
    // No googleSignIn override — let AuthRemoteDataSourceImpl use its
    // default which includes serverClientId, required for the native
    // account-picker flow on Android. Without it the plugin falls back
    // to a slow browser-based OAuth round-trip.
  );
});

// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  );
});

// Auth State Provider — streams the current user
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// Just the signed-in user's id (or null when signed out), collapsed via
// .select so this only notifies when the *uid itself* changes — not on
// every AsyncLoading/AsyncData transition for the same user. Per-user data
// providers (tasks, notes, planner, achievements) watch this so switching
// accounts invalidates their cached Firestore subscriptions instead of
// leaving them bound to whichever uid was signed in when they were first
// created — otherwise the previous account's data keeps streaming in until
// something forces a full provider-tree rebuild (e.g. an app restart).
final currentUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider.select((async) => async.value?.id));
});

// Auth Notifier
class AuthNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AsyncValue.data(null));

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    final result = await _authRepository.signInWithGoogle();
    result.fold(
      (failure) {
        // Silently ignore popup closed / cancelled errors
        if (failure.message.contains('popup') ||
            failure.message.contains('aborted') ||
            failure.message.contains('canceled') ||
            failure.message.contains('cancelled')) {
          state = const AsyncValue.data(null);
        } else {
          state = AsyncValue.error(failure.message, StackTrace.current);
        }
      },
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> signInWithFacebook() async {
    state = const AsyncValue.loading();
    final result = await _authRepository.signInWithFacebook();
    result.fold(
      (failure) {
        // Silently ignore popup closed / cancelled errors
        if (failure.message.contains('popup') ||
            failure.message.contains('aborted') ||
            failure.message.contains('canceled') ||
            failure.message.contains('cancelled')) {
          state = const AsyncValue.data(null);
        } else {
          state = AsyncValue.error(failure.message, StackTrace.current);
        }
      },
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    state = const AsyncValue.data(null);
  }

  Future<bool> deleteAccount() async {
    state = const AsyncValue.loading();
    final result = await _authRepository.deleteAccount();
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }
}

// Auth Notifier Provider
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserEntity?>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
